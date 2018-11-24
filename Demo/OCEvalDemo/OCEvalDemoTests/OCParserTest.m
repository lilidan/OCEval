//
//  OCParserTest.m
//  OCParserTest
//
//  Created by sgcy on 2018/11/15.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMethodNode.h"
#import "OCReturnNode.h"
#import "OCScopeNode.h"
#import "OCControlNode.h"
#import "OCLexer.h"
#import "OCEval.h"

@interface OCParserTest : XCTestCase

@end

@implementation OCParserTest

- (void)testReturnNode {
    NSString *inputStr = @"(follow);";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    OCReturnNode *rootNode = [[OCReturnNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:[lexer allTokens:NO]]];
    NSLog(@"%@",rootNode);
}

- (void)testReturnNodeExpression {
    NSString *inputStr = @"return 5-(1+2*4);";
    NSNumber *result = [OCEval eval:inputStr];
    NSAssert([result integerValue] == -4, nil);
}

- (void)testReturnNodePredicate {
    NSString *inputStr = @"return alpha + 3 <= 4 && 6 + 3 < 10;";
    NSNumber *result = [OCEval eval:inputStr context:[@{@"alpha":@(0)} mutableCopy]];
    NSAssert([result boolValue] == YES, nil);
}

- (void)testReturnNodeMethod {
    NSString *inputStr = @"return alpha + 3 <= 4 && [NSString string] != nil;";
    NSNumber *result = [OCEval eval:inputStr context:[@{@"alpha":@(0)} mutableCopy]];
    NSAssert([result boolValue] == YES, nil);
}

- (void)testScopeVariable{
    // you can modify a variable's value. but you can't use the variable outside the scope.
    NSString *inputStr = @"{    NSString *str = [NSString string];\
    if (str.length == 0) {\
        str = nil;\
        NSString *strr = [NSString string];\
    }\
        return str;\
    }";
    NSString *result = [OCEval eval:inputStr];
    NSAssert(result == nil, nil);
}

- (void)testPointSetter{
    NSString *inputStr = @"{     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];\
    formatter.dateFormat = @\"HH:MM:SS\";\
    return [formatter stringFromDate:[NSDate date]];}";
    NSString *result = [OCEval eval:inputStr];
    NSAssert(result != nil, nil);
}

- (void)testPointGetter{
    NSString *inputStr = @"{     NSView *view = [[NSView alloc] init];\
    NSRect frame = [view bounds];\
    return frame;}";
    NSValue *result = [OCEval eval:inputStr];
    NSAssert([result rectValue].origin.x == 0, nil);
}


- (void)testLine{
    NSString *inputStr = @"{;;;;}";
    NSString *result = [OCEval eval:inputStr];
}




@end
