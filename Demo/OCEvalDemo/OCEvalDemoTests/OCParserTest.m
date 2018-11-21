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
    NSString *inputStr = @"5-(1+2*4);";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    OCReturnNode *rootNode = [[OCReturnNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:[lexer allTokens:NO]]];
    NSAssert([[rootNode excuteWithCtx:@{}] integerValue] == -4, nil);
    NSLog(@"%@",rootNode);
}

- (void)testReturnNodePredicate {
    NSString *inputStr = @"alpha + 3 <= 4 && 6 + 3 < 10;";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    OCReturnNode *rootNode = [[OCReturnNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:[lexer allTokens:NO]]];
    NSAssert([[rootNode excuteWithCtx:@{@"alpha":@(0)}] boolValue] == YES, nil);
    NSLog(@"%@",rootNode);
}

- (void)testReturnNodeMethod {
    NSString *inputStr = @"alpha + 3 <= 4 && [NSString string] != nil;";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    OCReturnNode *rootNode = [[OCReturnNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:[lexer allTokens:NO]]];
    NSAssert([[rootNode excuteWithCtx:@{@"alpha":@(0)}] boolValue] == YES, nil);
    NSLog(@"%@",rootNode);
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
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    NSArray *tokens = [lexer allTokens:NO];
    OCRootNode *rootNode = [[OCRootNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:tokens]];
    NSString *result = [rootNode excuteWithCtx:@{}];
    NSAssert(result == nil, nil);
}

- (void)testPointSetter{
    NSString *inputStr = @"{     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];\
    formatter.dateFormat = @\"HH:MM:SS\";\
    return [formatter stringFromDate:[NSDate date]];}";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    NSArray *tokens = [lexer allTokens:NO];
    OCRootNode *rootNode = [[OCRootNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:tokens]];
    NSString *result = [rootNode excuteWithCtx:@{}];
    NSAssert(result != nil, nil);
}


- (void)testLine{
    NSString *inputStr = @"{;;;;}";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    NSArray *tokens = [lexer allTokens:NO];
    OCRootNode *rootNode = [[OCRootNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:tokens]];
    [rootNode excuteWithCtx:@{}];
}




@end
