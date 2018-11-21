//
//  OCReader.m
//  OCParser
//
//  Created by sgcy on 2018/11/14.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCReader.h"

@interface OCReader()

@property (nonatomic) NSUInteger offset;
@property (nonatomic) NSUInteger length;

@end


@implementation OCReader


- (instancetype)initWithString:(NSString *)s {
    self = [super init];
    if (self) {
        self.string = s;
    }
    return self;
}

- (NSString *)debugDescription {
    NSString *buff = [NSString stringWithFormat:@"%@^%@", [_string substringToIndex:_offset], [_string substringFromIndex:_offset]];
    return [NSString stringWithFormat:@"<%@ %p `%@`>", [self class], self, buff];
}

- (void)setString:(NSString *)s {
    NSAssert(s, @"s != nil");
    
    if (_string != s) {
        _string = [s copy];
        self.length = [_string length];
    }
    // reset cursor
    self.offset = 0;
}


- (char)read {
    char result = EOF;
    
    if (_length && _offset < _length) {
        result = [_string characterAtIndex:self.offset];
    }
    self.offset ++;
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
