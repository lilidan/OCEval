//
//  OCReturnNode.m
//  OCParser
//
//  Created by sgcy on 2018/11/15.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCReturnNode.h"
#import "OCToken.h"
#import "OCTokenReader.h"
#import "OCMethodNode.h"
#import "OCPropertyNode.h"
#import "OCLiteralNode.h"
#import "OCBlockNode.h"


@interface OCReturnNode()

@property (nonatomic,assign) BOOL canBeWord;
@property (nonatomic,assign) BOOL hasParen;

@end

@implementation OCReturnNode

- (instancetype)initWithReader:(OCTokenReader *)reader
{
    if (self = [super initWithReader:reader]) {
        self.canBeWord = YES;
        while (!self.isFinished) {
            [self read];
        }
    }
    return self;
}

- (void)read
{
    OCToken *token = [self.reader current];
    
    //return node read finished
    if (token.tokenSubType == OCSymbolSubTypeRightSquare || token.tokenSubType == OCSymbolSubTypeLeftBrace || token.tokenSubType == OCSymbolSubTypeSemi || token.tokenSubType == OCSymbolSubTypeColon || token.tokenSubType == OCSymbolSubTypeComma || token.tokenSubType == OCSymbolSubTypeRightBrace){
        self.finished = YES;
        return;
    }else if(token.tokenSubType == OCSymbolSubTypeRightParen) {
        if (self.hasParen) {
            [self.reader read];
        }
        self.finished = YES;
        return;
    }else if (token.tokenType == OCTokenTypeWord && !self.canBeWord) {
        self.finished = YES;
        return;
    }
    
    //read each child
    if (token.tokenSubType == OCSymbolSubTypeLeftParen) {
        self.hasParen = YES;
        // (a+b) + c, wrap (a + b) as a child
        [self.reader read];
        [self addChild:[[OCReturnNode alloc] initWithReader:self.reader]];
        self.canBeWord = NO;
        return;
    }else if (token.tokenSubType == OCSymbolSubTypeLeftSquare) {
        //method child
        if (self.canBeWord) {
            [self addChild:[[OCMethodNode alloc] initWithReader:self.reader]];
        }else{
            //like array[3]
            [self.reader read];
            OCReturnNode *node = [[OCReturnNode alloc] initWithReader:self.reader];
            OCSubscriptMethodNode *methodNode = [[OCSubscriptMethodNode alloc] init];
            [methodNode addChild:node];
            methodNode.caller = self.children.lastObject;
            [self replaceLastChild:methodNode];
            NSAssert([self.reader read].tokenSubType == OCSymbolSubTypeRightSquare,nil);
        }
        self.canBeWord = NO;
        return;
    }else if(token.tokenType == OCTokenTypeWord){
        token = [self.reader read];
        OCToken *token2 = [self.reader current];
        [self.reader unread];
        if (token2.tokenSubType == OCSymbolSubTypePoint){
            // like a.b.c
            [self addChild:[[OCPropertyNode alloc] initWithReader:self.reader]];
            self.canBeWord = NO;
            return;
        }else if (token2.tokenSubType == OCSymbolSubTypeLeftParen){
            // call Cfuntion
            [self addChild:[[OCBlockCallNode alloc] initWithReader:self.reader]];
            self.canBeWord = NO;
            return;
        }else{
            // variable child
            [self addChild:[[OCVariableNode alloc] initWithReader:self.reader]];
            self.canBeWord = NO;
            return;
        }
    }else if (token.tokenType == OCTokenTypeNumber || token.tokenType == OCTokenTypeString){
        [self addChild:[[OCSimpleNode alloc] initWithReader:self.reader]];
        self.canBeWord = NO;
    }else if (token.tokenType == OCTokenTypeSymbol){
        if (token.tokenSubType == OCSymbolSubTypeAmp && self.children.count == 0){
            token = [self.reader read];
            OCVariableNode *node = [[OCVariableNode alloc] initWithReader:self.reader];
            [self addChild:node];
            self.finished = YES;
            return;
        }else if ((token.tokenSubType <= OCSymbolSubTypePipe && token.tokenSubType >= OCSymbolSubTypeAdd)) {
            self.type |= OCReturnNodeTypeExpression;
        }else if (token.tokenSubType <= OCSymbolSubTypePipepipe && token.tokenSubType >= OCSymbolSubTypeExclaim){
            self.type |= OCReturnNodeTypeNSPredicate; //current not supports (a > 0)&&(b > 0)
        }else if (token.tokenSubType == OCTokenSubTypeNone){
            self.type |= OCReturnNodeTypeNSPredicate; //current not supports (a > 0)&&(b > 0)
        }else if (token.tokenSubType == OCSymbolSubTypeAt){
            // @() @[] @"" @{} @selector(), can not be used to caculate
            [self addChild:[[OCLiteralNode alloc] initWithReader:self.reader]];
            self.finished = YES;
            return;
        }else if (token.tokenSubType == OCSymbolSubTypeCaret){
            // block ^(){};
            [self addChild:[[OCBlockNode alloc] initWithReader:self.reader]];
            return;
        }else{
            abort();
        }
        
        [self addChild:[[OCSymbolNode alloc] initWithReader:self.reader]];
        self.canBeWord = YES;
    }
}


- (id)excuteWithCtx:(NSDictionary *)ctx
{
    if (self.type & OCReturnNodeTypeNSPredicate || self.type & OCReturnNodeTypeExpression) {
        NSMutableString *mutablestr = [[NSMutableString alloc] init];
        for (OCNode *node in self.children) {
            id result = [node excuteWithCtx:ctx];
            if ([result isKindOfClass:[NSNumber class]] || [node isKindOfClass:[OCSymbolNode class]]) {
                [mutablestr appendFormat:@"%@ ",result];
            }else{
                //if not number and not symbol, then must be objects compare.Objects compare with address.
                [mutablestr appendFormat:@"%p ",result]; // a == nil
            }
        }
        
        if (self.type & OCReturnNodeTypeNSPredicate) {
            NSPredicate *pre = [NSPredicate predicateWithFormat:[mutablestr copy]];
            return @([pre evaluateWithObject:nil]);
        }else{
            NSExpression *exp = [NSExpression expressionWithFormat:[mutablestr copy]];
            return [exp expressionValueWithObject:nil context:nil];
        }
    }else{
        return [self.children[0] excuteWithCtx:ctx];
    }
}


@end


