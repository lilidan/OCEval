//
//  OCIterateNode.m
//  OCParser
//
//  Created by sgcy on 2018/11/16.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCIterateNode.h"
#import "OCToken.h"
#import "OCNode.h"
#import "OCReturnNode.h"
#import "OCLineNode.h"

@interface OCFastEnumIterateNode:OCIterateNode

@property (nonatomic,strong) NSString *variableName;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,strong) NSArray *array;

@end

@implementation OCFastEnumIterateNode

- (instancetype)initWithReader:(OCTokenReader *)reader
{
    if (self = [super initWithReader:reader]) {
        self.variableName = [reader read].value;
        NSAssert([reader read].tokenSubType == OCWordSubTypeIn, nil);
        [self read];
        NSAssert([reader read].tokenSubType == OCSymbolSubTypeRightParen, nil);
    }
    return self;
}

- (void)read
{
    [self addChild:[[OCReturnNode alloc] initWithReader:self.reader]];
}

- (id)excuteWithCtx:(NSDictionary *)ctx
{
    if (!self.array) {
        self.array = [self.children[0] excuteWithCtx:ctx];
    }
    BOOL valid = self.index < self.array.count;
    //task 1: set variable
    if (valid) {
        [ctx setValue:self.array[self.index] forKey:self.variableName];
    }
    self.index ++;
    //task 2: return BOOL
    return @(valid);
}

@end

@interface OCNormalEnumIterateNode:OCIterateNode

@property (nonatomic,assign) BOOL hasInit;

@end

@implementation OCNormalEnumIterateNode

- (instancetype)initWithReader:(OCTokenReader *)reader
{
    if (self = [super initWithReader:reader]) {
        [self addChild:[[OCLineNode alloc] initWithReader:reader]];
        [self addChild:[[OCReturnNode alloc] initWithReader:reader]];
        NSAssert([reader read].tokenSubType == OCSymbolSubTypeSemi, nil);
        [self addChild:[[OCLineNode alloc] initWithReader:reader]];
    }
    return self;
}

- (id)excuteWithCtx:(NSDictionary *)ctx
{
    if (!self.hasInit) {
        [self.children[0] excuteWithCtx:ctx];
        self.hasInit = YES;
        return [self.children[1] excuteWithCtx:ctx];
    }
    
    [self.children[2] excuteWithCtx:ctx];
    return [self.children[1] excuteWithCtx:ctx];
}

@end


@interface OCIterateNode()

@end


@implementation OCIterateNode

+ (instancetype)nodeWithReader:(OCTokenReader *)reader
{
    NSAssert([reader read].tokenSubType == OCSymbolSubTypeLeftParen, nil);
    [reader read];
    OCToken *current = [reader read];
    if (current.tokenSubType == OCSymbolSubTypeStar){
        current = [reader read];
    }
    current = [reader read];
    if (current.tokenSubType == OCWordSubTypeIn) {
        [reader unread:2];
        return [[OCFastEnumIterateNode alloc] initWithReader:reader];
    }else{
        [reader unread:2];
        return [[OCNormalEnumIterateNode alloc] initWithReader:reader];
    }
}

@end
