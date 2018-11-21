//
//  OCControlTest.m
//  OCParserTest
//
//  Created by sgcy on 2018/11/17.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMethodNode.h"
#import "OCReturnNode.h"
#import "OCScopeNode.h"
#import "OCControlNode.h"
#import "OCLexer.h"


@interface OCControlTest : XCTestCase

@end

@implementation OCControlTest


- (void)testIf{
    NSString *inputStr = @"{    NSString *str = [NSString string];\
    if (str.length == 0) {\
    return str;\
    }}";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    NSArray *tokens = [lexer allTokens:NO];
    OCRootNode *rootNode = [[OCRootNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:tokens]];
    NSString *result = [rootNode excuteWithCtx:@{}];
    NSAssert([result isEqualToString:@""], nil);
}

- (void)testIfElse{
    NSString *inputStr = @"{    NSString *str = [NSString string];\
    if (str.length == 2) {\
    return nil;\
    }else if(str.length == 0){\
    return str;\
    }";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    NSArray *tokens = [lexer allTokens:NO];
    OCRootNode *rootNode = [[OCRootNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:tokens]];
    NSString *result = [rootNode excuteWithCtx:@{}];
    NSAssert([result isEqualToString:@""], nil);
}


- (void)testElseIf{
    NSString *inputStr = @"{    NSString *str = [NSString string];\
    if (str.length == 2) {\
    return nil;\
    }else if(str.length == 0){\
    return str;\
    }else{}}";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    NSArray *tokens = [lexer allTokens:NO];
    OCRootNode *rootNode = [[OCRootNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:tokens]];
    NSString *result = [rootNode excuteWithCtx:@{}];
    NSAssert([result isEqualToString:@""], nil);
}

- (void)testDoWhile{
    NSString *inputStr = @"{    int j = 4;\
    do {\
        i = i + 1;\
    } while (i < 10);\
    return i;}";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    NSArray *tokens = [lexer allTokens:NO];
    OCRootNode *rootNode = [[OCRootNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:tokens]];
    NSNumber *result = [rootNode excuteWithCtx:@{}];
    NSAssert(result.integerValue == 10, nil);
}

- (void)testWhileDo{
    NSString *inputStr = @"{    int i = -4;\
    while (i < 10) do {\
        i = i + 1;\
    }\
    return i;}";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    NSArray *tokens = [lexer allTokens:NO];
    OCRootNode *rootNode = [[OCRootNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:tokens]];
    NSNumber *result = [rootNode excuteWithCtx:@{}];
    NSAssert(result.integerValue == 10, nil);
}

- (void)testForIn{

    NSString *inputStr = @"{     NSArray *nums = @[@(1),@(2),@(3)];\
    NSInteger value = 0;\
    for (NSNumber *num in nums) {\
        value = value + num;\
    }\
    return value;}";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    NSArray *tokens = [lexer allTokens:NO];
    OCRootNode *rootNode = [[OCRootNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:tokens]];
    NSNumber *result = [rootNode excuteWithCtx:@{}];
    NSAssert(result.integerValue == 6, nil);
}

- (void)testFor{
    NSString *inputStr = @"{     NSArray *nums = @[@(1),@(2),@(3)];\
    int j = -4;\
    for (int i = 0; i< nums.count; i = i + 1) {\
        j = j + i;\
    }\
    return j;}";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    NSArray *tokens = [lexer allTokens:NO];
    OCRootNode *rootNode = [[OCRootNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:tokens]];
    NSNumber *result = [rootNode excuteWithCtx:@{}];
    NSAssert(result.integerValue == -1, nil);
    //TODO i++,i+=1
}

@end
