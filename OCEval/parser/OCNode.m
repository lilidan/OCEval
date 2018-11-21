//
//  OCNode.m
//  OCParser
//
//  Created by sgcy on 2018/11/15.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCNode.h"
#import "OCToken.h"

@interface OCNode()

@property (nonatomic,strong) NSMutableArray *allChilds;

@end

@implementation OCNode

- (instancetype)init
{
    if (self = [super init]) {
        _allChilds = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)initWithReader:(OCTokenReader *)reader
{
    if (self = [super init]) {
        _allChilds = [[NSMutableArray alloc] init];
        _reader = reader;
    }
    return self;
}

- (void)read
{
    
}

- (void)addChild:(OCNode *)node
{
    [self.allChilds addObject:node];
}

- (void)replaceLastChild:(OCNode *)node
{
    self.allChilds[self.allChilds.count - 1] = node;
}

- (NSArray *)children
{
    return [self.allChilds copy];
}

- (id)excuteWithCtx:(NSDictionary *)ctx
{
    for (OCNode *node in self.children) {
        EXCUTE(node,ctx);
    }
    return nil;
}

- (NSString *)description
{
    if (![self.children count]) {
        return NSStringFromClass(self.class);
    }
    
    NSMutableString *ms = [NSMutableString string];
    
    [ms appendFormat:@"(%@ ", NSStringFromClass(self.class)];
    
    NSInteger i = 0;
    for (OCNode *child in self.children) {
        NSString *fmt = 0 == i++ ? @"%@" : @" %@";
        [ms appendFormat:fmt, [child description]];
    }
    
    [ms appendString:@")"];
    return [ms copy];
}

@end


@implementation OCSimpleNode

- (instancetype)initWithReader:(OCTokenReader *)reader
{
    if (self = [super init]) {
        self.token = [reader read];
    }
    return self;
}

- (id)excuteWithCtx:(NSDictionary *)ctx
{
    return self.token.value;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Node:%@",self.token.value];
}

@end


@implementation OCSymbolNode

@end
