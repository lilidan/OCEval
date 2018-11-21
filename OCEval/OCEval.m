//
//  OCEval.m
//  OCParser
//
//  Created by sgcy on 2018/11/21.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCEval.h"
#import "OCLexer.h"
#import "OCToken.h"
#import "OCScopeNode.h"
#import "OCTokenReader.h"

@implementation OCEval

+ (id)eval:(NSString *)str
{
    return [self eval:str context:[@{} mutableCopy]];
}

+ (id)eval:(NSString *)str context:(NSMutableDictionary *)context
{
    if (![[str substringToIndex:1] isEqualToString:@"{"]) {
        str = [NSString stringWithFormat:@"{%@}",str];
    }
    OCLexer *lexer = [OCLexer lexerWithString:str];
    OCRootNode *rootNode = [[OCRootNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:[lexer allTokens:NO]]];
    return [rootNode excuteWithCtx:context];;
}

@end
