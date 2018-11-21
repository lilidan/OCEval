//
//  OCLiteralNode.m
//  OCParser
//
//  Created by sgcy on 2018/11/17.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCLiteralNode.h"
#import "OCToken.h"
#import "OCReturnNode.h"
#import "OCMethodNode.h"

@interface OCLiteralNode()

@property (nonatomic,assign) OCLiteralNodeType type;

@end


@implementation OCLiteralNode

- (instancetype)initWithReader:(OCTokenReader *)reader
{
    if (self = [super initWithReader:reader]) {
        [self.reader read];
        [self read];
    }
    return self;
}

- (void)read
{
    OCToken *token = [self.reader current];
    if (token.tokenType == OCTokenTypeNumber || token.tokenType == OCTokenTypeString) {
        self.type = OCLiteralNodeTypeSimple;
        [self addChild:[[OCSimpleNode alloc] initWithReader:self.reader]];
    }else if (token.tokenSubType == OCSymbolSubTypeLeftParen){
        self.type = OCLiteralNodeTypeExpression;
        [self addChild:[[OCReturnNode alloc] initWithReader:self.reader]];
    }else if (token.tokenSubType == OCSymbolSubTypeLeftSquare || token.tokenSubType == OCSymbolSubTypeLeftBrace){
        self.type = OCLiteralNodeTypeCollection;
        [self addChild:[[OCLiteralMethodNode alloc] initWithReader:self.reader]];
    }else if (token.tokenSubType == OCWordSubTypeSelector){
        self.type = OCLiteralNodeTypeSeletor;
    }
}

@end
