//
//  OCFastCalculateNode.m
//  OCEval
//
//  Created by sgcy on 2018/11/26.
//

#import "OCFastCalculateNode.h"
#import "OCReturnNode.h"

@implementation OCFastCalculateNode

- (instancetype)initWithReader:(OCTokenReader *)reader
{
    if (self = [super initWithReader:reader]) {
        [self read];
    }
    return self;
}


- (void)read
{
    OCToken *current = [self.reader read];
    if (current.tokenType == OCTokenTypeWord) {
        self.assigneeName = current.value;
        OCToken *current = [self.reader read];
        self.subType = current.tokenSubType;
        if (self.subType != OCSymbolSubTypeAddAdd && self.subType != OCSymbolSubTypeMinusMinus) {
            [self addChild:[[OCReturnNode alloc] initWithReader:self.reader]];
        }
    }else if(current.tokenType == OCTokenTypeSymbol){
        self.subType = current.tokenSubType;
        OCToken *current = [self.reader read];
        self.assigneeName = current.value;
    }
}

- (id)excuteWithCtx:(NSDictionary *)ctx
{
    NSNumber *base = [ctx valueForKey:self.assigneeName];
    switch (self.subType) {
        case OCSymbolSubTypeAddAdd:
            [ctx setValue:@(base.integerValue + 1) forKey:self.assigneeName];
            break;
        case OCSymbolSubTypeMinusMinus:
            [ctx setValue:@(base.integerValue - 1) forKey:self.assigneeName];
            break;
        case OCSymbolSubTypeAddEqual:
            [ctx setValue:@(base.doubleValue + [[self.children[0] excuteWithCtx:ctx] doubleValue]) forKey:self.assigneeName];
            break;
        case OCSymbolSubTypeMinusEqual:
            [ctx setValue:@(base.doubleValue - [[self.children[0] excuteWithCtx:ctx] doubleValue]) forKey:self.assigneeName];
            break;
        default:
            break;
    }
    return nil;
}

@end
