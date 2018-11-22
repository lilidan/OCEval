//
//  OCPropertyNode.m
//  OCParser
//
//  Created by sgcy on 2018/11/16.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCPropertyNode.h"
#import "OCTokenReader.h"
#import "OCToken.h"
#import "OCReturnNode.h"
#import "OCMethodNode.h"
#import "OCMethodNode+invoke.h"
#import "OCCfuntionHelper.h"

@interface OCVariableNode()


@end


@implementation OCVariableNode

- (id)excuteWithCtx:(NSDictionary *)ctx
{
    id variable = [ctx valueForKey:self.token.value];
    if (variable) {
        return variable;
    }
    
    switch (self.token.tokenSubType) {
        case OCWordSubTypeNil:
            return nil;
        case OCWordSubTypeYES:
            return @(YES);
        case OCWordSubTypeNO:
            return @(NO);
        default:
            break;
    }
    
    Class cls = NSClassFromString(self.token.value);
    if (cls) {
        return cls;
    }
    

//    abort();
    return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"VariableNode Name:%@",self.token.value];
}


@end

@interface OCPropertyNode()

@property (nonatomic,strong) NSMutableArray *propertyNames;
@property (nonatomic,assign) BOOL shouldBeWord; //The next token should be word or point.

@end

@implementation OCPropertyNode

- (instancetype)initWithReader:(OCTokenReader *)reader
{
    if (self = [super initWithReader:reader]) {
        self.reader = reader;
        self.propertyNames = [[NSMutableArray alloc] init];
        while (!self.isFinished) {
            [self readPropertys];
        }
    }
    return self;
}

- (void)readPropertys
{
    OCToken *token = [self.reader read];
    if (token.tokenSubType == OCSymbolSubTypeEqual) {
        // end by equal,it must be a setter method
        self.finished = YES;
        [self.reader unread:2];
        [self.propertyNames removeLastObject];
        return;
    }else if (token.tokenType == OCTokenTypeWord && self.shouldBeWord){
        [self.propertyNames addObject:token.value];
        self.shouldBeWord = NO;
    }else if (token.tokenSubType == OCSymbolSubTypePoint && !self.shouldBeWord){
        self.shouldBeWord = YES;
    }else{
        [self.reader unread];
        self.finished = YES;
    }
}

- (id)excuteWithCtx:(NSDictionary *)ctx
{
    id obj = [ctx objectForKey:self.token.value];
    for (NSString *propertyName in self.propertyNames) {
        obj = [OCMethodNode invokeWithCaller:obj selectorName:propertyName argments:@[]];
    }
    return obj;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"NodeName:%@.%@",self.token.value,self.propertyNames];
}

@end
