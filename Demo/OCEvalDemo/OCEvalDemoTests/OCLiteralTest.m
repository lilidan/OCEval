//
//  OCLiteralTest.m
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

@interface OCLiteralTest : XCTestCase

@end

@implementation OCLiteralTest

- (void)testNSString {
    NSString *inputStr = @"{ NSString *str = @\"a\";\
    NSString *str2 = [str stringByAppendingString:@\"b\"];\
    return str2;\
    }";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    NSArray *tokens = [lexer allTokens:NO];
    OCRootNode *rootNode = [[OCRootNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:tokens]];
    NSString *result = [rootNode excuteWithCtx:@{}];
    NSAssert([result isEqualToString:@"ab"], nil);
}

- (void)testNSNumber{
    NSString *inputStr = @"{ NSString *str = @\"a\";\
    NSString *str2 = [str stringByAppendingFormat:@\"%@,%@\",@\"2\",@(4 + 5*2)];\
    return str2;\
    }";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    NSArray *tokens = [lexer allTokens:NO];
    OCRootNode *rootNode = [[OCRootNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:tokens]];
    NSString *result = [rootNode excuteWithCtx:@{}];
    NSAssert([result isEqualToString:@"a2,14"], nil);
    //TODO format:%d
}

- (void)testNSArray{
    NSString *inputStr = @"{NSArray *array = @[@\"a\",[NSNull null],@\"c\",[NSString string],@(5)];\
    NSMutableArray *mutaArray = [array mutableCopy];\
    mutaArray[5] = @\"d\";\
    return mutaArray[5];\
    }";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    NSArray *tokens = [lexer allTokens:NO];
    OCRootNode *rootNode = [[OCRootNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:tokens]];
    NSString *result = [rootNode excuteWithCtx:@{}];
    NSAssert([result isEqualToString:@"d"], nil);
}

- (void)testNSDictionary{
    NSString *inputStr = @"{NSDictionary *dic = @{@\"aaa\":@(1),@\"6666\":[NSArray array]};\
    NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:@1,@\"go2\",@\"go3\",@\"go4\", nil];\
    NSMutableDictionary *mutaDic = [dic mutableCopy];\
    mutaDic[@\"w\"] = @\"xyz\";\
    return mutaDic[@\"w\"];\
    }";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    NSArray *tokens = [lexer allTokens:NO];
    OCRootNode *rootNode = [[OCRootNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:tokens]];
    NSString *result = [rootNode excuteWithCtx:@{}];
    NSAssert([result isEqualToString:@"xyz"], nil);
}



@end
