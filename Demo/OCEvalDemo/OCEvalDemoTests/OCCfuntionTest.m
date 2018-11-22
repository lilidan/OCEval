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

@interface OCCfuntionTest : XCTestCase

@end

@implementation OCCfuntionTest

- (void)testCfuntionCall {
    NSString *inputStr = @"{\
    [OCCfuntionHelper defineCFunction:@\"NSClassFromString\" types:@\"Class, NSString *\"];\
    Class cls = NSClassFromString(@\"NSObject\");\
    return cls;\
    }";
    id result = [OCEval eval:inputStr];
    NSAssert(result == [NSObject class],nil);
}


- (void)testCfuntionCallWithStruct{
    NSString *inputStr = @"{\
    CGPoint point = CGPointMake(1, 2);\
    return point;\
    }";
    CGPoint result = [[OCEval eval:inputStr] CGPointValue];
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
