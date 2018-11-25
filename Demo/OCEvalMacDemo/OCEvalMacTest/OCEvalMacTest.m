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
    
    
    CGFloat a = 0;
    CGFloat b = 0;
    CGFloat c = 0;
    
    for (int i = 0; i < 100; i++) {
        
        NSDate *date = [NSDate date];

        NSMutableString *mutaStr = [[NSMutableString alloc] init];
        [mutaStr appendFormat:@"1"];
        [mutaStr appendFormat:@"+"];
        [mutaStr appendFormat:@"%d",1];
        
        NSMutableString *mutaStr2 = [[NSMutableString alloc] init];
        [mutaStr2 appendFormat:@"1"];
        [mutaStr2 appendFormat:@"=="];
        [mutaStr2 appendFormat:@"%d",1];
        
        a += [[NSDate date] timeIntervalSinceDate:date];
        date = [NSDate date];
        
        NSExpression *exp = [NSExpression expressionWithFormat:[mutaStr copy]];
        NSNumber *number = [exp expressionValueWithObject:nil context:nil];
        
        b += [[NSDate date] timeIntervalSinceDate:date];
        date = [NSDate date];

        NSPredicate *pre = [NSPredicate predicateWithFormat:[mutaStr2 copy]];
        [pre evaluateWithObject:nil];
        c += [[NSDate date] timeIntervalSinceDate:date];

//        j++;
    }
    NSLog(@"------%f----%f----%f",a,b,c);
    
    
    NSString *inputStr = @"{\
    [OCCfuntionHelper defineCFunction:@\"NSLog\" types:@\"void, NSString *,float\"];\
    NSDate *date = [NSDate date];\
    int j = 0;\
    for (int i = 0; i < 100; i = i + 1) {\
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
     for (var i=0;i<10000;i++)\
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

    
    NSString *inputStr = @"{\
    NSDate *date = [NSDate date];\
    [NSString stringWithFormat:@\"aaaa%@\",@\"a\"];\
    return [[NSDate date] timeIntervalSinceDate:date];\
    }";
    NSNumber *value = [OCEval eval:inputStr];
    NSLog(@"======%f",value.doubleValue);
    
    
    JSContext *ctx = [[JSContext alloc] init];
    ctx.exceptionHandler = ^(JSContext *con, JSValue *exception) {
        NSLog(@"%@", exception);
        con.exception = exception;
    };

//    ctx[@"go"] = ^() {
//        [NSString stringWithFormat:@"aaaa%@",@"a"];
//    };
    
     [ctx evaluateScript:@"function go() { var date = \"a\" + \"b\"}"];
    NSDate * date = [NSDate date];
    [ctx evaluateScript:@"\
     for (var i=0;i<100;i++)\
     {\
     go(); \
     }"];
    NSLog(@"xxxxxxx%f",[[NSDate date] timeIntervalSinceDate:date]);
    
    
    date = [NSDate date];
    for (int i = 0; i < 100; i++) {
        [NSString stringWithFormat:@"aaaa%@",@"a"];
    }
    NSLog(@"------%f",[[NSDate date] timeIntervalSinceDate:date]);
    
}

@end
