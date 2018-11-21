//
//  OCReader.h
//  OCParser
//
//  Created by sgcy on 2018/11/14.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCReader : NSObject

@property (nonatomic, copy) NSString *string;
@property (nonatomic, readonly) NSUInteger offset;

- (instancetype)initWithString:(NSString *)s;

- (char)read;

- (void)unread;
- (void)unread:(NSUInteger)count;

- (NSString *)debugDescription;

@end
