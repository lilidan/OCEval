//
//  OCLineNode.m
//  OCParser
//
//  Created by sgcy on 2018/11/15.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCLineNode.h"
#import "OCToken.h"
#import "OCMethodNode.h"
#import "OCReturnNode.h"
#import "OCPropertyNode.h"
#import "OCBlockNode.h"

@interface OCLineNode()



@end


@implementation OCLineNode

- (instancetype)initWithReader:(OCTokenReader *)reader
{
    if (self = [super initWithReader:reader]) {
        while (!self.isFinished) {
            [self read];
        }
    }
    return self;
}

- (void)read
{
    OCToken *token = [self.reader current];
    
    //end by semi ;
    if (token.tokenSubType == OCSymbolSubTypeSemi || token == [OCToken EOFToken] || token.tokenSubType == OCSymbolSubTypeRightParen) {
        [self.reader read];
        self.finished = YES;
        return;
    }
    
    if (token.tokenSubType == OCSymbolSubTypeLeftSquare) {
        self.type = OCLineNodeTypeCallMethod;
        [self addChild:[[OCMethodNode alloc] initWithReader:self.reader]];
    }else if (token.tokenSubType == OCWordSubTypeReturn){
        self.type = OCLineNodeTypeReturn;
        [self.reader read];
        [self addChild:[[OCReturnNode alloc] initWithReader:self.reader]];
    }else{
        OCToken *token1 = [self.reader read];
        if (token1.tokenSubType <= OCWordSubTypeBlock && token1.tokenSubType >= OCWordSubTypeWeak) {
            token1 = [self.reader read];
        }
        
        OCToken *token2 = [self.reader read];
        
        if (token2.tokenSubType == OCSymbolSubTypePoint){
            //method setter
            self.type = OCLineNodeTypeCallMethod;
            [self.reader unread:2];
            [self addChild:[[OCPointSetterNode alloc] initWithReader:self.reader]];
        }
        
        if (token2.tokenSubType == OCSymbolSubTypeStar) {
            token2 = [self.reader read];
        }
        
        //local variable setter
        if (token2.tokenType == OCTokenTypeWord) {
            self.type = OCLineNodeTypeAssign;
            self.assigneeName = token2.value;
            NSAssert([self.reader read].tokenSubType == OCSymbolSubTypeEqual, nil);
            [self addChild:[[OCReturnNode alloc] initWithReader:self.reader]];
        }else if (token2.tokenSubType == OCSymbolSubTypeEqual){
            self.type = OCLineNodeTypeAssign;
            self.assigneeName = token1.value;
            [self addChild:[[OCReturnNode alloc] initWithReader:self.reader]];
        }else if (token2.tokenSubType == OCSymbolSubTypeLeftSquare){
            //subscript setter like array[1] = ...
            self.type = OCLineNodeTypeCallMethod;
            OCSubscriptMethodNode *methodNode = [[OCSubscriptMethodNode alloc] init];
            methodNode.isSetter = YES;
            OCVariableNode *variableNode = [[OCVariableNode alloc] init];
            variableNode.token = token1;
            methodNode.caller = variableNode;
            [methodNode addChild:[[OCReturnNode alloc] initWithReader:self.reader]];
            NSAssert([self.reader read].tokenSubType == OCSymbolSubTypeRightSquare, nil);
            NSAssert([self.reader read].tokenSubType == OCSymbolSubTypeEqual, nil);
            [methodNode addChild:[[OCReturnNode alloc] initWithReader:self.reader]];
            [self addChild:methodNode];
        }else if (token2.tokenSubType == OCSymbolSubTypeLeftParen){
            if ([self.reader read].tokenSubType == OCSymbolSubTypeCaret) {
                //define block
                self.assigneeName = [self.reader read].value;
                while ([self.reader read].tokenSubType != OCSymbolSubTypeEqual) {}
                self.type = OCLineNodeTypeAssign;
                [self addChild:[[OCReturnNode alloc] initWithReader:self.reader]];
            }else{
                //call block
                [self.reader unread:3];
                self.type = OCLineNodeTypeCallMethod;
                [self addChild:[[OCBlockCallNode alloc] initWithReader:self.reader]];
            }
        }
    }
}

- (id)excuteWithCtx:(NSDictionary *)ctx
{
    if (self.children.count == 0) {
        return nil;
    }
    if (self.type == OCLineNodeTypeCallMethod) {
        EXCUTE(self.children[0],ctx);
    }else if (self.type == OCLineNodeTypeReturn){
        return [self.children[0] excuteWithCtx:ctx];
    }else if (self.type == OCLineNodeTypeAssign){
        //set context.
        OCNode *node = self.children[0];
        id value = [node excuteWithCtx:ctx];
        [ctx setValue:value forKey:self.assigneeName];
    }
    return nil;
}

@end
