//
//  OCBlockTest.m
//  OCParserTest
//
//  Created by sgcy on 2018/11/19.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OCMethodNode.h"
#import "OCReturnNode.h"
#import "OCScopeNode.h"
#import "OCControlNode.h"
#import "OCLexer.h"

@interface OCBlockTest : XCTestCase

@end

@implementation OCBlockTest

- (void)testBlock {
    NSString *inputStr = @"{NSArray *content = @[@6,@7,@8,@9,@1,@2,@3,@4];\
    NSComparisonResult (^comparison)(id obj1, id obj2) = ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {\
    return [obj1 doubleValue] > [obj2 doubleValue];\
    };\
    [content sortedArrayUsingComparator:comparison];\
    return content;\
    }";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    NSArray *tokens = [lexer allTokens:NO];
    OCRootNode *rootNode = [[OCRootNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:tokens]];
    NSArray *result = [rootNode excuteWithCtx:@{}];
    NSAssert([result[6] intValue] == 8, nil);
    
}


- (void)testBlock2{
    NSString *inputStr = @"{NSArray *content = @[@6,@7,@8,@9,@1,@2,@3,@4];\
    __block NSInteger result = 0;\
    [content enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {\
    result = result + 1;\
    }];\
    return result;\
    }";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    NSArray *tokens = [lexer allTokens:NO];
    OCRootNode *rootNode = [[OCRootNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:tokens]];
    NSNumber *result = [rootNode excuteWithCtx:@{}];
    NSAssert(result.doubleValue == 8, nil);
}

- (void)testBlock3{
    NSString *inputStr = @"{__block NSInteger result = 0;\
    void(^blk)(NSInteger toAdd) = ^(NSInteger toAdd){\
    result = result + toAdd;\
    };\
    blk(3);\
    return result;\
    }";
    OCLexer *lexer = [OCLexer lexerWithString:inputStr];
    NSArray *tokens = [lexer allTokens:NO];
    OCRootNode *rootNode = [[OCRootNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:tokens]];
    NSNumber *result = [rootNode excuteWithCtx:@{}];
    NSAssert(result.doubleValue == 3, nil);
}

@end
