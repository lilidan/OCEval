//
//  OCTokenReader.m
//  OCParser
//
//  Created by sgcy on 2018/11/15.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCTokenReader.h"
#import "OCToken.h"

@interface OCTokenReader()

@property (nonatomic) NSUInteger offset;
@property (nonatomic) NSUInteger length;

@end


@implementation OCTokenReader


- (instancetype)initWithTokens:(NSArray *)tokens
{
    if (self = [super init]) {
        self.tokens = tokens;
    }
    return self;
}

- (void)setTokens:(NSArray *)tokens
{
    _tokens = tokens;
    _length = tokens.count;
    _offset = 0;
}

- (OCToken *)read
{
    OCToken *result = [OCToken EOFToken];
    if (_length && _offset < _length) {
        result = [self.tokens objectAtIndex:self.offset];
    }
    self.offset ++;
//    NSLog(@"READ:%@",result.value);
    return result;
}

- (OCToken *)current
{
    OCToken *result = [OCToken EOFToken];
    if (_length && _offset < _length) {
        result = [self.tokens objectAtIndex:self.offset];
    }
    return result;
}

- (void)unread {
    self.offset = (0 == _offset) ? 0 : _offset - 1;
}

- (void)unread:(NSUInteger)count {
    for (NSUInteger i = 0; i < count; i++) {
        [self unread];
    }
}

@end
