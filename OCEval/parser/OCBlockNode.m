//
//  OCBlockNode.m
//  OCParser
//
//  Created by sgcy on 2018/11/19.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCBlockNode.h"
#import "OCToken.h"
#import "OCScopeNode.h"
#import "OCBlockWrapper.h"
#import "OCReturnNode.h"
#import "OCMethodNode+invoke.h"
#import "OCCfuntionHelper.h"

@interface OCBlockNode()

@property (nonatomic,strong) OCBlockWrapper *wrapper;

@end

@implementation OCBlockNode


- (instancetype)initWithReader:(OCTokenReader *)reader
{
    if (self = [super initWithReader:reader]) {
        _typeNames = [[NSMutableArray alloc] init];
        _paramNames = [[NSMutableArray alloc] init];
        [reader read];
        [self read];
    }
    return self;
}

- (void)read
{
    OCToken *current = [self.reader read];
    if (current.tokenType == OCTokenTypeWord) {
        [self.typeNames addObject:current.value];
        current = [self.reader read];
    }else{
        [self.typeNames addObject:@"void"];
    }
    NSAssert(current.tokenSubType == OCSymbolSubTypeLeftParen, nil);
    [self readParam];
    [self addChild:[[OCScopeNode alloc] initWithReader:self.reader]];
    self.wrapper = [OCBlockWrapper blockWrapperWithNode:self]; //won't be a retain cycle.
}

- (void)readParam
{
    OCToken *current = [self.reader read];
    if (current.tokenSubType == OCSymbolSubTypeRightParen) {
        return;
    }else if (current.tokenSubType == OCSymbolSubTypeComma){
        [self readParam];
    }else{
        [self.typeNames addObject:current.value];
        current = [self.reader read];
        while (current.tokenSubType == OCSymbolSubTypeStar || current.tokenSubType == OCWordSubTypeNonnull || current.tokenSubType == OCWordSubTypenullable) {
            current = [self.reader read];
        }
        NSAssert(current.tokenType == OCTokenTypeWord, nil);
        [self.paramNames addObject:current.value];
        [self readParam];
    }
}

- (id)excuteWithCtx:(NSDictionary *)ctx
{
    return [self.wrapper blockPtrWithCtx:ctx];
}

@end

@interface OCBlockCallNode()

@property (nonatomic,strong) NSString *blockName;

@end


@implementation OCBlockCallNode

- (instancetype)initWithReader:(OCTokenReader *)reader
{
    self = [super initWithReader:reader];
    self.blockName = [reader read].value;
    NSAssert([reader read].tokenSubType == OCSymbolSubTypeLeftParen, nil);
    while (!self.isFinished) {
        [self read];
    }
    return self;
}

- (void)read
{
    OCToken *token = [self.reader read];
    if (token.tokenSubType == OCSymbolSubTypeRightParen) {
        self.finished = YES;
        return;
    }else if (token.tokenSubType == OCSymbolSubTypeComma){
        return;
    }
    [self.reader unread];
    [self addChild:[[OCReturnNode alloc] initWithReader:self.reader]];
}

- (id)excuteWithCtx:(NSDictionary *)ctx
{
    id block = [ctx valueForKey:self.blockName];
    NSMutableArray *argumentsList = [[NSMutableArray alloc] init];
    [self.children enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id result = [obj excuteWithCtx:ctx];
        if (result == nil) {
            result = [OCMethodNode nilObj];
        }
        [argumentsList addObject:result];
    }];
    if (block) { // call block
        return [OCBlockWrapper excuteBlock:block withParams:[argumentsList copy]];
    }else{ // call C funtion
        return [OCCfuntionHelper callCFunction:self.blockName arguments:[argumentsList copy]];
    }

}

@end
