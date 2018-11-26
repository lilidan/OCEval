//
//  OCCfuntionTest.m
//  OCParserTest
//
//  Created by sgcy on 2018/11/20.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCEval.h"
#import <objc/runtime.h>
#import <dlfcn.h>
@interface OCCfuntionTest : XCTestCase

@end

@implementation OCCfuntionTest

- (void)testCfunctionSearch{
    // in mac they are different
    const char *funcName = "NSClassFromString";
    void* functionPtr = dlsym(RTLD_DEFAULT,funcName); //might be rejected by AppStore
    void* functionPtr2 = NULL;
}

- (void)testCfuntionCall {
    NSString *inputStr = @"{\
    [OCCfuntionHelper defineCFunction:@\"NSClassFromString\" types:@\"Class, NSString *\"];\
    Class cls = NSClassFromString(@\"NSObject\");\
    return cls;\
    }";
    id result = [OCEval eval:inputStr];
    NSAssert(result == [NSObject class],nil);
}

- (void)testNSSelectorFromString{
    NSString *inputStr = @"{\
    [OCCfuntionHelper defineCFunction:@\"NSSelectorFromString\" types:@\"SEL,NSString *\"];\
    SEL sel = NSSelectorFromString(@\"alloc\");\
    return sel;\
    }";
    NSValue *result = [OCEval eval:inputStr];
    SEL sel = [result pointerValue];
    NSAssert([NSStringFromSelector(sel) isEqualToString:@"alloc"],nil);
}

- (void)testGetMethodImp{
    NSString *inputStr = @"{\
    [OCCfuntionHelper defineCFunction:@\"NSClassFromString\" types:@\"Class, NSString *\"];\
    [OCCfuntionHelper defineCFunction:@\"NSSelectorFromString\" types:@\"SEL,NSString *\"];\
    [OCCfuntionHelper defineCFunction:@\"class_getMethodImplementation\" types:@\"IMP,Class,SEL\"];\
    Class cls = NSClassFromString(@\"NSObject\");\
    SEL sel = NSSelectorFromString(@\"copy\");\
    IMP imp = class_getMethodImplementation(cls,sel);\
    return imp;\
    }";
    NSValue *result = [OCEval eval:inputStr];
    IMP imp = [result pointerValue];
    Method m = class_getInstanceMethod(NSObject.class, @selector(copy));
    IMP imp2 = method_getImplementation(m);
    NSAssert(imp == imp2, nil);
}

- (void)testAddMethod{

#if TARGET_OS_IPHONE
    NSString *inputStr = @"{\
    [OCCfuntionHelper defineCFunction:@\"NSClassFromString\" types:@\"Class, NSString *\"];\
    [OCCfuntionHelper defineCFunction:@\"NSSelectorFromString\" types:@\"SEL,NSString *\"];\
    [OCCfuntionHelper defineCFunction:@\"class_getMethodImplementation\" types:@\"IMP,Class,SEL\"];\
    [OCCfuntionHelper defineCFunction:@\"class_addMethod\" types:@\"BOOL,Class,SEL,IMP,char *\"];\
    Class cls = NSClassFromString(@\"UIView\");\
    SEL sel = NSSelectorFromString(@\"setNeedsDisplay\");\
    IMP imp = class_getMethodImplementation(cls,sel);\
    Class cls2 = NSClassFromString(@\"NSObject\");\
    BOOL didAdd = class_addMethod(cls2,sel,imp,\"v:\")\
    return didAdd;\
    }";
#else
    NSString *inputStr = @"{\
    [OCCfuntionHelper defineCFunction:@\"NSClassFromString\" types:@\"Class, NSString *\"];\
    [OCCfuntionHelper defineCFunction:@\"NSSelectorFromString\" types:@\"SEL,NSString *\"];\
    [OCCfuntionHelper defineCFunction:@\"class_getMethodImplementation\" types:@\"IMP,Class,SEL\"];\
    [OCCfuntionHelper defineCFunction:@\"class_addMethod\" types:@\"BOOL,Class,SEL,IMP,char *\"];\
    Class cls = NSClassFromString(@\"NSView\");\
    SEL sel = NSSelectorFromString(@\"display\");\
    IMP imp = class_getMethodImplementation(cls,sel);\
    Class cls2 = NSClassFromString(@\"NSObject\");\
    BOOL didAdd = class_addMethod(cls2,sel,imp,\"v:\")\
    return didAdd;\
    }";
#endif

    NSNumber* didAdd2 = [OCEval eval:inputStr];
    NSAssert(didAdd2.boolValue, nil);
//    NSObject *obj = [[NSObject alloc] init];

#if TARGET_OS_IPHONE
    NSMethodSignature *methodSignature = [NSObject instanceMethodSignatureForSelector:NSSelectorFromString(@"setNeedsDisplay")];
#else
    NSMethodSignature *methodSignature = [NSObject instanceMethodSignatureForSelector:NSSelectorFromString(@"display")];
#endif

    NSAssert(methodSignature != nil, nil);

//    [obj performSelector:@selector(setNeedsLayout)];
}

- (void)testCfuntionCallWithStruct{
    NSString *inputStr = @"{\
    CGPoint point = CGPointMake(1, 2);\
    return point;\
    }";
#if TARGET_OS_IPHONE
    CGPoint result = [[OCEval eval:inputStr] CGPointValue];
#else
    CGPoint result = [[OCEval eval:inputStr] pointValue];
#endif

    NSAssert(result.x == 1, nil);
}

- (void)testAssocateObject{
    NSString *inputStr = @"\
    [OCCfuntionHelper defineCFunction:@\"objc_setAssociatedObject\" types:@\"void,id,void *,id,unsigned int\"];\
    [OCCfuntionHelper defineCFunction:@\"objc_getAssociatedObject\" types:@\"id,id,void *\"];\
    NSObject *object = [[NSObject alloc] init];\
    objc_setAssociatedObject(object, [@\"key\" UTF8String], @\"3\", 1);\
    return objc_getAssociatedObject(object, [@\"key\" UTF8String]);\
    ";
    NSObject *object = [[NSObject alloc] init];
    objc_setAssociatedObject(object, [@"key" UTF8String], @"3", 1);
    NSString *result2 = objc_getAssociatedObject(object, [@"key" UTF8String]);
    NSString *result = [OCEval eval:inputStr context:[@{@"object":object} mutableCopy]];
    NSAssert([result isEqualToString:result2], nil);
}


@end
