//
//  OCParserTest.m
//  OCParserTest
//
//  Created by sgcy on 2018/11/14.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCLexer.h"
#import "OCToken.h"

@interface OCLexerTest : XCTestCase

@end

@implementation OCLexerTest

- (void)testSymbol1 {
    NSString *inputStr = @":@(YES)";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    XCTAssert([lexer allTokens].count == 5);
}

- (void)testSymbol2 {
    NSString *inputStr = @"1 += 2";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    XCTAssert([lexer allTokens].count == 5);
}

- (void)testWhiteSpace {
    NSString *inputStr = @"1 += 2";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    XCTAssert([lexer allTokens:NO].count == 3);
}

- (void)testQuotedString {
    NSString *inputStr = @"\"aaa\"";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    OCToken *token = [lexer allTokens:NO][0];
    XCTAssert([token.value isEqualToString:@"aaa"]);
}


- (void)testSingleLineComment{
//    NSString *inputStr = @" \\\\[[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:skey];\
//    1 += 2";
//    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
//    XCTAssert([lexer allTokens:NO].count == 3);
}

@end
