//
//  OCTokenReader.h
//  OCParser
//
//  Created by sgcy on 2018/11/15.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OCToken;

@interface OCTokenReader : NSObject

@property (nonatomic, copy) NSArray *tokens;
@property (nonatomic, readonly) NSUInteger offset;

- (instancetype)initWithTokens:(NSArray *)tokens;

- (OCToken *)current;
- (OCToken *)read;

- (void)unread;
- (void)unread:(NSUInteger)count;

@end
