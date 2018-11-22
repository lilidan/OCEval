//
//  OCMethodNode+invoke.m
//  OCParser
//
//  Created by sgcy on 2018/11/18.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCMethodNode+invoke.h"
#import <objc/message.h>
#import "OCExtension.h"

@implementation OCMethodNode(invoke)

static NSObject *_nilObj;

+ (void)initialize
{
    _nilObj = [[NSObject alloc] init];
}

+ (id)nilObj
{
    return _nilObj;
}

+ (id)invokeWithCaller:(id)caller selectorName:(NSString *)selectorName argments:(NSArray *)arguments
{
    SEL selector = NSSelectorFromString(selectorName);
    NSInvocation *invocation;
    NSMethodSignature *methodSignature = [caller methodSignatureForSelector:selector];
    invocation= [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setTarget:caller];
    [invocation setSelector:selector];
    NSUInteger numberOfArguments = methodSignature.numberOfArguments;
    NSInteger inputArguments = [arguments count];
    if (inputArguments > numberOfArguments - 2) {
        id result = invokeVariableParameterMethod(arguments, methodSignature, caller, selector);
        return result;
    }
    return [self invokeWithInvocation:invocation argments:arguments];
}

+ (id)invokeWithInvocation:(NSInvocation *)invocation argments:(NSArray *)arguments
{
    // change NSValue,NSNumber to invocation type
    NSMethodSignature *methodSignature = invocation.methodSignature;
    NSString *selectorName = NSStringFromSelector(invocation.selector);
    NSUInteger adjustment = (selectorName == nil ? 1 : 0);
    for (NSUInteger i = 2; i < arguments.count + 2; i++) {
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:i - adjustment];
        id valObj = arguments[i-2];
        switch (argumentType[0] == 'r' ? argumentType[1] : argumentType[0]) {
                
                #define JP_CALL_ARG_CASE(_typeString, _type, _selector) \
                case _typeString: {                              \
                _type value = [valObj _selector];                     \
                [invocation setArgument:&value atIndex:i - adjustment];\
                break; \
                }
                
                JP_CALL_ARG_CASE('c', char, charValue)
                JP_CALL_ARG_CASE('C', unsigned char, unsignedCharValue)
                JP_CALL_ARG_CASE('s', short, shortValue)
                JP_CALL_ARG_CASE('S', unsigned short, unsignedShortValue)
                JP_CALL_ARG_CASE('i', int, intValue)
                JP_CALL_ARG_CASE('I', unsigned int, unsignedIntValue)
                JP_CALL_ARG_CASE('l', long, longValue)
                JP_CALL_ARG_CASE('L', unsigned long, unsignedLongValue)
                JP_CALL_ARG_CASE('q', long long, longLongValue)
                JP_CALL_ARG_CASE('Q', unsigned long long, unsignedLongLongValue)
                JP_CALL_ARG_CASE('f', float, floatValue)
                JP_CALL_ARG_CASE('d', double, doubleValue)
                JP_CALL_ARG_CASE('B', BOOL, boolValue)
                
                
            case ':': {
                SEL value = nil;
                if (valObj != _nilObj) {
                    value = NSSelectorFromString(valObj);
                }
                [invocation setArgument:&value atIndex:i];
                break;
            }
            case '{': {
                void *pointer = NULL;
                [valObj getValue:&pointer];
                [invocation setArgument:&pointer atIndex:i];
                break;
            }
            default: {
                if (valObj == _nilObj ||
                    ([valObj isKindOfClass:[NSNumber class]] && strcmp([valObj objCType], "c") == 0 && ![valObj boolValue])) {
                    valObj = nil;
                    [invocation setArgument:&valObj atIndex:i];
                    break;
                }
                [invocation setArgument:&valObj atIndex:i];
            }
        }
    }
    
    [invocation invoke];

    char returnType[255];
    strcpy(returnType, [methodSignature methodReturnType]);
    
    
    id returnValue;
    if (strncmp(returnType, "v", 1) != 0) {
        if (strncmp(returnType, "@", 1) == 0) {
            void *result;
            [invocation getReturnValue:&result];
            
            //For performance, ignore the other methods prefix with alloc/new/copy/mutableCopy
            if ([selectorName isEqualToString:@"alloc"] || [selectorName isEqualToString:@"new"] ||
                [selectorName isEqualToString:@"copy"] || [selectorName isEqualToString:@"mutableCopy"]) {
                returnValue = (__bridge_transfer id)result;
            } else {
                returnValue = (__bridge id)result;
            }
            return returnValue;
            
        } else {
            switch (returnType[0] == 'r' ? returnType[1] : returnType[0]) {
                    
#define JP_CALL_RET_CASE(_typeString, _type) \
case _typeString: {                              \
_type tempResultSet; \
[invocation getReturnValue:&tempResultSet];\
returnValue = @(tempResultSet); \
break; \
}
                    
                    JP_CALL_RET_CASE('c', char)
                    JP_CALL_RET_CASE('C', unsigned char)
                    JP_CALL_RET_CASE('s', short)
                    JP_CALL_RET_CASE('S', unsigned short)
                    JP_CALL_RET_CASE('i', int)
                    JP_CALL_RET_CASE('I', unsigned int)
                    JP_CALL_RET_CASE('l', long)
                    JP_CALL_RET_CASE('L', unsigned long)
                    JP_CALL_RET_CASE('q', long long)
                    JP_CALL_RET_CASE('Q', unsigned long long)
                    JP_CALL_RET_CASE('f', float)
                    JP_CALL_RET_CASE('d', double)
                    JP_CALL_RET_CASE('B', BOOL)
                case '{': {
                    void *result;
                    [invocation getReturnValue:&result];
                    return  [NSValue value:&result withObjCType:returnType];
                    break;
                }
                case '#': {
                    Class result;
                    [invocation getReturnValue:&result];
                    returnValue = result;
                    break;
                }
            }
            return returnValue;
        }
    }
    return nil;
}

static id (*new_msgSend1)(id, SEL, id,...) = (id (*)(id, SEL, id,...)) objc_msgSend;
static id (*new_msgSend2)(id, SEL, id, id,...) = (id (*)(id, SEL, id, id,...)) objc_msgSend;
static id (*new_msgSend3)(id, SEL, id, id, id,...) = (id (*)(id, SEL, id, id, id,...)) objc_msgSend;
static id (*new_msgSend4)(id, SEL, id, id, id, id,...) = (id (*)(id, SEL, id, id, id, id,...)) objc_msgSend;
static id (*new_msgSend5)(id, SEL, id, id, id, id, id,...) = (id (*)(id, SEL, id, id, id, id, id,...)) objc_msgSend;
static id (*new_msgSend6)(id, SEL, id, id, id, id, id, id,...) = (id (*)(id, SEL, id, id, id, id, id, id,...)) objc_msgSend;
static id (*new_msgSend7)(id, SEL, id, id, id, id, id, id, id,...) = (id (*)(id, SEL, id, id, id, id, id, id,id,...)) objc_msgSend;
static id (*new_msgSend8)(id, SEL, id, id, id, id, id, id, id, id,...) = (id (*)(id, SEL, id, id, id, id, id, id, id, id,...)) objc_msgSend;
static id (*new_msgSend9)(id, SEL, id, id, id, id, id, id, id, id, id,...) = (id (*)(id, SEL, id, id, id, id, id, id, id, id, id, ...)) objc_msgSend;
static id (*new_msgSend10)(id, SEL, id, id, id, id, id, id, id, id, id, id,...) = (id (*)(id, SEL, id, id, id, id, id, id, id, id, id, id,...)) objc_msgSend;

static id invokeVariableParameterMethod(NSArray *origArgumentsList, NSMethodSignature *methodSignature, id sender, SEL selector) {
    
    NSInteger inputArguments = [(NSArray *)origArgumentsList count];
    NSUInteger numberOfArguments = methodSignature.numberOfArguments;
    
    NSMutableArray *argumentsList = [[NSMutableArray alloc] init];
    for (NSUInteger j = 0; j < inputArguments; j++) {
        NSInteger index = MIN(j + 2, numberOfArguments - 1);
        const char *argumentType = [methodSignature getArgumentTypeAtIndex:index];
        id valObj = origArgumentsList[j];
        char argumentTypeChar = argumentType[0] == 'r' ? argumentType[1] : argumentType[0];
        if (argumentTypeChar == '@') {
            [argumentsList addObject:valObj];
        } else {
            return nil;
        }
    }
    
    id results = nil;
    numberOfArguments = numberOfArguments - 2;
    
    //If you want to debug the macro code below, replace it to the expanded code:
    //https://gist.github.com/bang590/ca3720ae1da594252a2e
#define JP_G_ARG(_idx) getArgument(argumentsList[_idx])
#define JP_CALL_MSGSEND_ARG1(_num) results = new_msgSend##_num(sender, selector, JP_G_ARG(0));
#define JP_CALL_MSGSEND_ARG2(_num) results = new_msgSend##_num(sender, selector, JP_G_ARG(0), JP_G_ARG(1));
#define JP_CALL_MSGSEND_ARG3(_num) results = new_msgSend##_num(sender, selector, JP_G_ARG(0), JP_G_ARG(1), JP_G_ARG(2));
#define JP_CALL_MSGSEND_ARG4(_num) results = new_msgSend##_num(sender, selector, JP_G_ARG(0), JP_G_ARG(1), JP_G_ARG(2), JP_G_ARG(3));
#define JP_CALL_MSGSEND_ARG5(_num) results = new_msgSend##_num(sender, selector, JP_G_ARG(0), JP_G_ARG(1), JP_G_ARG(2), JP_G_ARG(3), JP_G_ARG(4));
#define JP_CALL_MSGSEND_ARG6(_num) results = new_msgSend##_num(sender, selector, JP_G_ARG(0), JP_G_ARG(1), JP_G_ARG(2), JP_G_ARG(3), JP_G_ARG(4), JP_G_ARG(5));
#define JP_CALL_MSGSEND_ARG7(_num) results = new_msgSend##_num(sender, selector, JP_G_ARG(0), JP_G_ARG(1), JP_G_ARG(2), JP_G_ARG(3), JP_G_ARG(4), JP_G_ARG(5), JP_G_ARG(6));
#define JP_CALL_MSGSEND_ARG8(_num) results = new_msgSend##_num(sender, selector, JP_G_ARG(0), JP_G_ARG(1), JP_G_ARG(2), JP_G_ARG(3), JP_G_ARG(4), JP_G_ARG(5), JP_G_ARG(6), JP_G_ARG(7));
#define JP_CALL_MSGSEND_ARG9(_num) results = new_msgSend##_num(sender, selector, JP_G_ARG(0), JP_G_ARG(1), JP_G_ARG(2), JP_G_ARG(3), JP_G_ARG(4), JP_G_ARG(5), JP_G_ARG(6), JP_G_ARG(7), JP_G_ARG(8));
#define JP_CALL_MSGSEND_ARG10(_num) results = new_msgSend##_num(sender, selector, JP_G_ARG(0), JP_G_ARG(1), JP_G_ARG(2), JP_G_ARG(3), JP_G_ARG(4), JP_G_ARG(5), JP_G_ARG(6), JP_G_ARG(7), JP_G_ARG(8), JP_G_ARG(9));
#define JP_CALL_MSGSEND_ARG11(_num) results = new_msgSend##_num(sender, selector, JP_G_ARG(0), JP_G_ARG(1), JP_G_ARG(2), JP_G_ARG(3), JP_G_ARG(4), JP_G_ARG(5), JP_G_ARG(6), JP_G_ARG(7), JP_G_ARG(8), JP_G_ARG(9), JP_G_ARG(10));
    
#define JP_IF_REAL_ARG_COUNT(_num) if([argumentsList count] == _num)
    
#define JP_DEAL_MSGSEND(_realArgCount, _defineArgCount) \
if(numberOfArguments == _defineArgCount) { \
JP_CALL_MSGSEND_ARG##_realArgCount(_defineArgCount) \
}
    
    JP_IF_REAL_ARG_COUNT(1) { JP_CALL_MSGSEND_ARG1(1) }
    JP_IF_REAL_ARG_COUNT(2) { JP_DEAL_MSGSEND(2, 1) JP_DEAL_MSGSEND(2, 2) }
    JP_IF_REAL_ARG_COUNT(3) { JP_DEAL_MSGSEND(3, 1) JP_DEAL_MSGSEND(3, 2) JP_DEAL_MSGSEND(3, 3) }
    JP_IF_REAL_ARG_COUNT(4) { JP_DEAL_MSGSEND(4, 1) JP_DEAL_MSGSEND(4, 2) JP_DEAL_MSGSEND(4, 3) JP_DEAL_MSGSEND(4, 4) }
    JP_IF_REAL_ARG_COUNT(5) { JP_DEAL_MSGSEND(5, 1) JP_DEAL_MSGSEND(5, 2) JP_DEAL_MSGSEND(5, 3) JP_DEAL_MSGSEND(5, 4) JP_DEAL_MSGSEND(5, 5) }
    JP_IF_REAL_ARG_COUNT(6) { JP_DEAL_MSGSEND(6, 1) JP_DEAL_MSGSEND(6, 2) JP_DEAL_MSGSEND(6, 3) JP_DEAL_MSGSEND(6, 4) JP_DEAL_MSGSEND(6, 5) JP_DEAL_MSGSEND(6, 6) }
    JP_IF_REAL_ARG_COUNT(7) { JP_DEAL_MSGSEND(7, 1) JP_DEAL_MSGSEND(7, 2) JP_DEAL_MSGSEND(7, 3) JP_DEAL_MSGSEND(7, 4) JP_DEAL_MSGSEND(7, 5) JP_DEAL_MSGSEND(7, 6) JP_DEAL_MSGSEND(7, 7) }
    JP_IF_REAL_ARG_COUNT(8) { JP_DEAL_MSGSEND(8, 1) JP_DEAL_MSGSEND(8, 2) JP_DEAL_MSGSEND(8, 3) JP_DEAL_MSGSEND(8, 4) JP_DEAL_MSGSEND(8, 5) JP_DEAL_MSGSEND(8, 6) JP_DEAL_MSGSEND(8, 7) JP_DEAL_MSGSEND(8, 8) }
    JP_IF_REAL_ARG_COUNT(9) { JP_DEAL_MSGSEND(9, 1) JP_DEAL_MSGSEND(9, 2) JP_DEAL_MSGSEND(9, 3) JP_DEAL_MSGSEND(9, 4) JP_DEAL_MSGSEND(9, 5) JP_DEAL_MSGSEND(9, 6) JP_DEAL_MSGSEND(9, 7) JP_DEAL_MSGSEND(9, 8) JP_DEAL_MSGSEND(9, 9) }
    JP_IF_REAL_ARG_COUNT(10) { JP_DEAL_MSGSEND(10, 1) JP_DEAL_MSGSEND(10, 2) JP_DEAL_MSGSEND(10, 3) JP_DEAL_MSGSEND(10, 4) JP_DEAL_MSGSEND(10, 5) JP_DEAL_MSGSEND(10, 6) JP_DEAL_MSGSEND(10, 7) JP_DEAL_MSGSEND(10, 8) JP_DEAL_MSGSEND(10, 9) JP_DEAL_MSGSEND(10, 10) }
    
    return results;
}

NSMethodSignature *block_methodSignatureForSelector(id self, SEL _cmd, SEL aSelector) {
    uint8_t *p = (uint8_t *)((__bridge void *)self);
    p += sizeof(void *) * 2 + sizeof(int32_t) *2 + sizeof(uintptr_t) * 2;
    const char **signature = (const char **)p;
    return [NSMethodSignature signatureWithObjCTypes:*signature];
}


static id getArgument(id valObj){
    if (valObj == _nilObj ||
        ([valObj isKindOfClass:[NSNumber class]] && strcmp([valObj objCType], "c") == 0 && ![valObj boolValue])) {
        return nil;
    }
    return valObj;
}

@end
