//
//  OCEval.m
//  OCParser
//
//  Created by sgcy on 2018/11/21.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCEval.h"
#import "OCLexer.h"
#import "OCToken.h"
#import "OCScopeNode.h"
#import "OCTokenReader.h"
#import "OCMethodNode+invoke.h"

#import "Aspects.h"
#import <objc/runtime.h>

@implementation OCEval

+ (id)eval:(NSString *)str
{
    return [self eval:str context:[@{} mutableCopy]];
}

+ (id)eval:(NSString *)str context:(NSMutableDictionary *)context
{
    if (![[str substringToIndex:1] isEqualToString:@"{"]) {
        str = [NSString stringWithFormat:@"{%@}",str];
    }
    OCLexer *lexer = [OCLexer lexerWithString:str];
    OCRootNode *rootNode = [[OCRootNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:[lexer allTokens:NO]]];
    return [rootNode excuteWithCtx:context];;
}

+ (void)hookClass:(NSString *)clsName
         selector:(NSString *)selName
         argNames:(NSArray<__kindof NSString *> *)argNames
          isClass:(BOOL)isClass
   implementation:(NSString *)imp
{
    Class class = NSClassFromString(clsName);
    SEL selector = NSSelectorFromString(selName);
    
    if (isClass) {
         class = objc_getMetaClass([NSStringFromClass(class) UTF8String]);
    }
    
    OCLexer *lexer = [OCLexer lexerWithString:imp];
    OCRootNode *rootNode = [[OCRootNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:[lexer allTokens:NO]]];
    
    NSError *error;
    [class aspect_hookSelector:selector withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo) {
        NSMutableDictionary *context = [[NSMutableDictionary alloc] init];
        [context setObject:aspectInfo.instance forKey:@"self"];
        [context setObject:aspectInfo.originalInvocation forKey:@"originalInvocation"];
        NSAssert(aspectInfo.arguments.count == argNames.count, @"Error: Method params count must be same.");
        [aspectInfo.arguments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *name = argNames[idx];
            [context setObject:obj forKey:name];
        }];
        
        id result = [rootNode excuteWithCtx:context];
        
        const char *argumentType = aspectInfo.originalInvocation.methodSignature.methodReturnType;
        
        switch (argumentType[0] == 'r' ? argumentType[1] : argumentType[0]) {
                
#define OC_CALL_ARG_CASE(_typeString, _type, _selector) \
case _typeString: {                              \
_type value = [result _selector];                     \
[aspectInfo.originalInvocation setReturnValue:&value];\
break; \
}
                OC_CALL_ARG_CASE('c', char, charValue)
                OC_CALL_ARG_CASE('C', unsigned char, unsignedCharValue)
                OC_CALL_ARG_CASE('s', short, shortValue)
                OC_CALL_ARG_CASE('S', unsigned short, unsignedShortValue)
                OC_CALL_ARG_CASE('i', int, intValue)
                OC_CALL_ARG_CASE('I', unsigned int, unsignedIntValue)
                OC_CALL_ARG_CASE('l', long, longValue)
                OC_CALL_ARG_CASE('L', unsigned long, unsignedLongValue)
                OC_CALL_ARG_CASE('q', long long, longLongValue)
                OC_CALL_ARG_CASE('Q', unsigned long long, unsignedLongLongValue)
                OC_CALL_ARG_CASE('f', float, floatValue)
                OC_CALL_ARG_CASE('d', double, doubleValue)
                OC_CALL_ARG_CASE('B', BOOL, boolValue)
                
            case ':': {
                SEL value = nil;
                if (result != [OCMethodNode nilObj]) {
                    value = NSSelectorFromString(result);
                }
                [aspectInfo.originalInvocation setReturnValue:&value];
                break;
            }
            case '{': {
                void *pointer = NULL;
                [result getValue:&pointer];
                [aspectInfo.originalInvocation setReturnValue:&pointer];
                break;
            }
            default: {
                if (result == [OCMethodNode nilObj] ||
                    ([result isKindOfClass:[NSNumber class]] && strcmp([result objCType], "c") == 0 && ![result boolValue])) {
                    result = nil;
                    [aspectInfo.originalInvocation setReturnValue:&result];
                    break;
                }
                if (result) {
                    [aspectInfo.originalInvocation setReturnValue:&result];
                }
            }
        }
        
    } error:&error];
}

@end
