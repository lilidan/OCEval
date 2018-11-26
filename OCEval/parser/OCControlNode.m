//
//  OCControlNode.m
//  OCParser
//
//  Created by sgcy on 2018/11/15.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCControlNode.h"
#import "OCToken.h"
#import "OCReturnNode.h"
#import "OCScopeNode.h"
#import "OCIterateNode.h"

@interface OCControlNode()

@property (nonatomic,strong) NSMutableArray *logics;
@property (nonatomic,strong) NSMutableArray *expressions;

@end

@implementation OCControlNode

- (instancetype)initWithReader:(OCTokenReader *)reader
{
    if (self = [super initWithReader:reader]) {
        _expressions = [[NSMutableArray alloc] init];
        _logics = [[NSMutableArray alloc] init];
        while (!self.isFinished) {
            [self read];
        }
    }
    return self;
}

- (void)readIf
{
    [self.logics addObject:@(OCWordSubTypeIf)];
    OCReturnNode *returnNode = [[OCReturnNode alloc] initWithReader:self.reader];
    [self.expressions addObject:returnNode];
    [self addChild:[[OCScopeNode alloc] initWithReader:self.reader]];
}

- (void)readElse
{
    [self.logics addObject:@(OCWordSubTypeElse)];
    [self.expressions addObject:[NSNull null]];
    [self addChild:[[OCScopeNode alloc] initWithReader:self.reader]];
}

- (void)readFor
{
    [self.logics addObject:@(OCWordSubTypeFor)];
    [self.expressions addObject:[OCIterateNode nodeWithReader:self.reader]];
    [self addChild:[[OCScopeNode alloc] initWithReader:self.reader]];
}


- (void)read
{
    OCToken *token = [self.reader read];
    if (token.tokenSubType == OCWordSubTypeIf) {
        [self readIf];
    }else if (token.tokenSubType == OCWordSubTypeElse){
        OCToken *token2 = [self.reader read];
        if (token2.tokenSubType == OCWordSubTypeIf) {
            [self readIf];
        }else{
            [self.reader unread];
            [self readElse];
        }
    }else if (token.tokenSubType == OCWordSubTypeFor){
        [self readFor];
    }else if (token.tokenSubType == OCWordSubTypeDo){
        [self.logics addObject:@(OCWordSubTypeDo)];
        [self addChild:[[OCScopeNode alloc] initWithReader:self.reader]];
        OCToken *token2 = [self.reader read];
        NSAssert(token2.tokenSubType == OCWordSubTypeWhile, nil); //do...while..
        [self.expressions addObject:[[OCReturnNode alloc] initWithReader:self.reader]];
    }else if (token.tokenSubType == OCWordSubTypeWhile){
        [self.logics addObject:@(OCWordSubTypeWhile)];
        [self.expressions addObject:[[OCReturnNode alloc] initWithReader:self.reader]];
        OCToken *token2 = [self.reader current];
        if (token2.tokenSubType == OCWordSubTypeDo) {
            [self.reader read];
        }
        [self addChild:[[OCScopeNode alloc] initWithReader:self.reader]];
    }else{
        [self.reader unread];
        self.finished = YES;
    }
}

- (id)excuteWithCtx:(NSDictionary *)ctx
{
//    NSAssert(self.children.count == self.logics.count == self.expressions.count,nil);
    for (int i = 0; i < self.logics.count; i++) {
        OCReturnNode *expression = self.expressions[i];
        OCNode *node = self.children[i];
        NSInteger logicType = [self.logics[i] integerValue];
        if (logicType == OCWordSubTypeIf) {
            id exp = [expression excuteWithCtx:ctx];
            if ([exp isKindOfClass:[NSNumber class]]) {
                if ([exp boolValue]) {
                    EXCUTE(node,ctx);
                }
            }else{
                if (exp != nil) {
                    EXCUTE(node,ctx);
                }
            }
        }else if (logicType == OCWordSubTypeElse){
            EXCUTE(node,ctx);
        }else if (logicType == OCWordSubTypeDo){
            do {
                EXCUTE(node,ctx);
            } while ([[expression excuteWithCtx:ctx] boolValue]);
        }else if (logicType == OCWordSubTypeWhile || logicType == OCWordSubTypeFor){
            while ([[expression excuteWithCtx:ctx] boolValue]) {
                EXCUTE(node,ctx);
            }
        }
    }
    return nil;
}

@end
