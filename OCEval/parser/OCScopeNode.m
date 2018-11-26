//
//  OCScopeNode.m
//  OCParser
//
//  Created by sgcy on 2018/11/15.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCScopeNode.h"
#import "OCToken.h"
#import "OCControlNode.h"
#import "OCLineNode.h"


@implementation OCScopeNode

- (instancetype)initWithReader:(OCTokenReader *)reader
{
    if (self = [super initWithReader:reader]) {
        OCToken *token = [self.reader read];
        NSAssert(token.tokenSubType == OCSymbolSubTypeLeftBrace, nil);
        while (!self.isFinished) {
            [self read];
        }
    }
    return self;
}

- (void)read
{
    OCToken *token = [self.reader current];
    if (token.tokenSubType == OCSymbolSubTypeRightBrace || token == [OCToken EOFToken]) {
        self.finished = YES;
        [self.reader read];
        return;
    }else if (token.tokenSubType >= OCWordSubTypeIf && token.tokenSubType <= OCWordSubTypeFor) {
        OCControlNode *controlNode = [[OCControlNode alloc] initWithReader:self.reader];
        [self addChild:controlNode];
    }else{
        OCLineNode *lineNode = [[OCLineNode alloc] initWithReader:self.reader];
        [self addChild:lineNode];
    }
}

- (id)excuteWithCtx:(NSDictionary *)ctx
{
//    NSMutableArray *toRemove = [[NSMutableArray alloc] init];
    for (OCNode *node in self.children) {
        if ([node isKindOfClass:[OCLineNode class]]) {
            OCLineNode *lineNode = (OCLineNode *)node;
//            if (lineNode.isStatement == YES) {
//                [toRemove addObject:lineNode.assigneeName];
//            }
        }
        EXCUTE(node,ctx);
    }
    // block delays the object releasing
//    for (NSString *assigneeName in toRemove) {
//        [ctx setValue:nil forKey:assigneeName];
//    }
    return nil;
}


@end


@implementation OCRootNode

- (id)excuteWithCtx:(NSDictionary *)ctx
{
    return [super excuteWithCtx:ctx];
}

@end
