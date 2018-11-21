//
//  OCCfuntionTest.m
//  OCParserTest
//
//  Created by sgcy on 2018/11/20.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCEval.h"

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
    NSAssert(result == [NSObject class], nil);
}


CGRect (*_CGRectMake)(CGFloat x, CGFloat y, CGFloat width, CGFloat height) = CGRectMake;
CGPoint (*_CGPointMake)(CGFloat x, CGFloat y) = CGPointMake;

- (void)testCfuntionCallWithStruct{
    NSString *inputStr = @"{\
    CGPoint point = CGPointMake(1, 2);\
    return point;\
    }";
    id result = [OCEval eval:inputStr];
    NSAssert(result.x == 1, nil);
}


@end
