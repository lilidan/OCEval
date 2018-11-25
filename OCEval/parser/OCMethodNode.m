//
//  OCMethodNode.m
//  OCParser
//
//  Created by sgcy on 2018/11/15.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCMethodNode.h"
#import "OCToken.h"
#import "OCTokenReader.h"
#import "OCPropertyNode.h"
#import "OCMethodNode+invoke.h"

#import "OCReturnNode.h"
#import <objc/message.h>

@interface OCMethodNode()


@end


@implementation OCMethodNode


- (instancetype)initWithReader:(OCTokenReader *)reader
{
    if (self = [super initWithReader:reader]) {
        _selectorName = [NSMutableString string];
        OCToken *token = [self.reader current];
        if (token.tokenSubType == OCSymbolSubTypeLeftSquare) {
            //call method
            [self.reader read];
            self.caller = [[OCReturnNode alloc] initWithReader:self.reader];
            while (!self.isFinished) {
                [self read];
            }
        }else if (token.tokenType == OCTokenTypeWord){
            [reader read];
            //method setter
            self.caller = [[OCReturnNode alloc] initWithReader:self.reader]; // read caller until it was equal symbol, and unread
            OCToken *token2 = [self.reader read];
            NSAssert(token2.tokenSubType == OCSymbolSubTypePoint,nil);
            OCToken *selName = [self.reader read];
            NSString *firstStr = [selName.value substringToIndex:1];
            _selectorName = [[NSString stringWithFormat:@"set%@%@:",firstStr.uppercaseString,[selName.value substringFromIndex:1]] mutableCopy];
            NSAssert([self.reader read].tokenSubType == OCSymbolSubTypeEqual,nil);
            OCReturnNode *param = [[OCReturnNode alloc] initWithReader:self.reader];
            [self addChild:param];
        }else{
            abort();
        }
    }
    return self;
}

- (void)read
{
    OCToken *token = [self.reader read];
    if (token.tokenSubType == OCSymbolSubTypeRightSquare) {
        self.finished = YES;
        return;
    }else if (token.tokenSubType == OCSymbolSubTypeColon){
        OCReturnNode *param = [[OCReturnNode alloc] initWithReader:self.reader];
        [self addChild:param];
        [self.selectorName appendString:@":"];
    }else if (token.tokenSubType == OCSymbolSubTypeComma){
        OCReturnNode *param = [[OCReturnNode alloc] initWithReader:self.reader];
        [self addChild:param];
    }else{
        [self.selectorName appendString:token.value];
    }
}


static id (*new_msgSend1)(id, SEL,...) = (id (*)(id, SEL, ...)) objc_msgSend;

- (id)excuteWithCtx:(NSDictionary *)ctx
{
    id caller = [self.caller excuteWithCtx:ctx];
    if (caller == NSString.class) {
        return new_msgSend1(caller,NSSelectorFromString(self.selectorName),@"aaaa%@,%@%@",@"aa",@"bb",@"cc");
    }else{
        NSMutableArray *argumentsList = [[NSMutableArray alloc] init];
        [self.children enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id result = [obj excuteWithCtx:ctx];
            if (result == nil) {
                result = [OCMethodNode nilObj];
            }
            [argumentsList addObject:result];
        }];
        return [[self class] invokeWithCaller:caller selectorName:self.selectorName.copy argments:[argumentsList copy]];
    }
 
}
@end



@implementation OCSubscriptMethodNode


- (id)excuteWithCtx:(NSDictionary *)ctx
{
    id caller = [self.caller excuteWithCtx:ctx];
    BOOL isArray = [caller isKindOfClass:[NSArray class]];
    NSString *selectorName = (isArray ? (self.isSetter ? @"setObject:atIndex:" : @"objectAtIndex:") : (self.isSetter ? @"setObject:forKey:" : @"objectForKey:"));
    NSArray *argumentsList;
    if (self.children.count == 1) {
        argumentsList = @[[self.children[0] excuteWithCtx:ctx]];
    }else{
        argumentsList = @[[self.children[1] excuteWithCtx:ctx],[self.children[0] excuteWithCtx:ctx]];
    }
    return [[self class] invokeWithCaller:caller selectorName:selectorName argments:argumentsList];
}

@end


@interface OCLiteralMethodNode()

@property (nonatomic,assign) BOOL isArray;

@end


@implementation OCLiteralMethodNode

- (instancetype)initWithReader:(OCTokenReader *)reader
{
    if (self = [super initWithReader:reader]) {
        OCToken *currentToken = [self.reader read];
        self.isArray = (currentToken.tokenSubType == OCSymbolSubTypeLeftSquare);
        [self addChild:[[OCReturnNode alloc] initWithReader:self.reader]];
        while (!self.isFinished) {
            [self read];
        }
    }
    return self;
}

- (void)read
{
    OCToken *currentToken = [self.reader read];
    if (currentToken.tokenSubType == OCSymbolSubTypeRightSquare || currentToken.tokenSubType == OCSymbolSubTypeRightBrace) {
        self.finished = YES;        return;
    }else if (currentToken.tokenSubType == OCSymbolSubTypeComma){
        [self addChild:[[OCReturnNode alloc] initWithReader:self.reader]];
    }else if (currentToken.tokenSubType == OCSymbolSubTypeColon){
        [self addChild:[[OCReturnNode alloc] initWithReader:self.reader]];
    }
}

- (id)excuteWithCtx:(NSDictionary *)ctx
{
    if (self.isArray) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (OCNode *node in self.children) {
            id result = [node excuteWithCtx:ctx];
            if (result == nil) {
                result = [OCMethodNode nilObj];
            }
            [array addObject:result];
        }
        return [array copy];
    }else{
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSInteger count = self.children.count / 2;
        for (int i = 0; i < count; i++) {
            id key = [self.children[i * 2] excuteWithCtx:ctx];
            id value = [self.children[i * 2 + 1] excuteWithCtx:ctx];
            [dic setValue:value forKey:key];
        }
        return [dic copy];
    }
}


@end


@interface OCPointSetterNode()

@property (nonatomic,strong) OCReturnNode *returnNode;

@end


@implementation OCPointSetterNode

- (instancetype)initWithReader:(OCTokenReader *)reader
{
    if (self = [super initWithReader:reader]) {
        [self addChild:[[OCVariableNode alloc] initWithReader:self.reader]];
        [self read];
    }
    return self;
}

- (void)read
{
    OCToken *current = [self.reader current];
    if (current.tokenType == OCTokenTypeWord) {
        [self addChild:[[OCSimpleNode alloc] initWithReader:self.reader]];
        [self read];
    }else if (current.tokenSubType == OCSymbolSubTypeEqual){
        [self.reader read];
        self.returnNode = [[OCReturnNode alloc] initWithReader:self.reader];
    }else if (current.tokenSubType == OCSymbolSubTypePoint){
        [self.reader read];
        [self read];
    }
}

- (id)excuteWithCtx:(NSDictionary *)ctx
{
    NSArray *children = self.children;
    id obj = [children[0] excuteWithCtx:ctx];
    for (int i = 1; i < children.count - 1; i++) {
        OCSimpleNode *node = children[i];
        obj = [OCMethodNode invokeWithCaller:obj selectorName:node.token.value argments:@[]];
    }
    
    OCToken *selName = [children.lastObject token];
    NSString *firstStr = [selName.value substringToIndex:1];
    NSString *selectorName = [[NSString stringWithFormat:@"set%@%@:",firstStr.uppercaseString,[selName.value substringFromIndex:1]] mutableCopy];
    id returnvalue = [self.returnNode excuteWithCtx:ctx];
    return [OCMethodNode invokeWithCaller:obj selectorName:selectorName argments:@[returnvalue]];
}

@end
