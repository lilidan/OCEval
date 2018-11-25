//
//  OCEvalMacTest.m
//  OCEvalMacTest
//
//  Created by sgcy on 2018/11/24.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCEval.h"
#import <JavaScriptCore/JavaScriptCore.h>


@interface OCEvalMacTest : XCTestCase

@end

@implementation OCEvalMacTest


- (void)testPerformance {
    // This is an example of a performance test case.
    NSDate *date = [NSDate date];
    int j = 0;
    for (int i = 0; i < 100000000; i++) {
        j++;
    }
    NSLog(@"------%f",[[NSDate date] timeIntervalSinceDate:date]);
    
    
    NSString *inputStr = @"{\
    [OCCfuntionHelper defineCFunction:@\"NSLog\" types:@\"void, NSString *,float\"];\
    NSDate *date = [NSDate date];\
    int j = 0;\
    for (int i = 0; i< 10000; i = i + 1) {\
        j = j + i;\
    }\
    return [[NSDate date] timeIntervalSinceDate:date];\
    }";
    NSNumber *value = [OCEval eval:inputStr];
    NSLog(@"======%f",value.doubleValue);
    
    JSContext *ctx = [[JSContext alloc] init];
    ctx.exceptionHandler = ^(JSContext *con, JSValue *exception) {
        NSLog(@"%@", exception);
        con.exception = exception;
    };
    
    
    
    [ctx evaluateScript:@"function go() {var j = 0;\
     for (var i=0;i<100000000;i++)\
     {\
     j = j+1; \
     }\
     return j;\
     }"];
    date = [NSDate date];
    JSValue *n = [ctx[@"go"] callWithArguments:@[]];
    NSLog(@"xxxxxxx%f xxxxxx%d",[[NSDate date] timeIntervalSinceDate:date],[n toInt32]);
}


- (void)testPerformance2 {
    // This is an example of a performance test case.
    NSDate *date = [NSDate date];
    NSDate *date1 = [NSDate date];
    date1 = [NSDate date];
    date1 = [NSDate date];
    date1 =  [NSDate date];
    date1 = [NSDate date];
    date1 = [NSDate date];
    date1 = [NSDate date];
    date1 = [NSDate date];
    date1 = [NSDate date];
    date1 = [NSDate date];
    NSLog(@"------%f",[[NSDate date] timeIntervalSinceDate:date]);
    
    
    NSString *inputStr = @"{\
    NSDate *date = [NSDate date];\
    NSDate *date1 = [NSDate date];\
    NSDate *date1 = [NSDate date];\
    NSDate *date1 = [NSDate date];\
    NSDate *date1 = [NSDate date];\
    NSDate *date1 = [NSDate date];\
    NSDate *date1 = [NSDate date];\
    NSDate *date1 = [NSDate date];\
    NSDate *date1 = [NSDate date];\
    NSDate *date1 = [NSDate date];\
    NSDate *date1 = [NSDate date];\
    return [[NSDate date] timeIntervalSinceDate:date];\
    }";
    NSNumber *value = [OCEval eval:inputStr];
    NSLog(@"======%f",value.doubleValue);
    
    
    JSContext *ctx = [[JSContext alloc] init];
    ctx.exceptionHandler = ^(JSContext *con, JSValue *exception) {
        NSLog(@"%@", exception);
        con.exception = exception;
    };

    ctx[@"go"] = ^() {
        NSDate *date = [NSDate date];
    };
    
//     [ctx evaluateScript:@"function go() { var date = Date()}"];
    date = [NSDate date];
    [ctx evaluateScript:@"\
     for (var i=0;i<10;i++)\
     {\
     go(); \
     }"];
    NSLog(@"xxxxxxx%f",[[NSDate date] timeIntervalSinceDate:date]);
    
}

@end
