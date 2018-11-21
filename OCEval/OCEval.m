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
#import "Aspects.h"
#import <objc/runtime.h>

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

+ (void)hookClass:(Class)class
         selector:(SEL)selector
         argNames:(NSArray<__kindof NSString *> *)argNames
          isClass:(BOOL)isClass
   implementation:(NSString *)imp
{
    if (isClass) {
         class = objc_getMetaClass([NSStringFromClass(class) UTF8String]);
    }
    
    OCLexer *lexer = [OCLexer lexerWithString:imp];
    OCRootNode *rootNode = [[OCRootNode alloc] initWithReader:[[OCTokenReader alloc] initWithTokens:[lexer allTokens:NO]]];
    
    NSError *error;
    [class aspect_hookSelector:selector withOptions:AspectPositionInstead usingBlock:^(id<AspectInfo> aspectInfo) {
        NSMutableDictionary *context = [[NSMutableDictionary alloc] init];
        [context setObject:aspectInfo.instance forKey:@"self"];
        [context setObject:aspectInfo.originalInvocation forKey:@"originalInvocation"];
        NSAssert(aspectInfo.arguments.count == argNames.count, @"Error: Method params count must be same.");
        [aspectInfo.arguments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *name = argNames[idx];
            [context setObject:obj forKey:name];
        }];
        id result = [rootNode excuteWithCtx:context];
        [aspectInfo.originalInvocation setReturnValue:&result];
    } error:&error];
}

@end
