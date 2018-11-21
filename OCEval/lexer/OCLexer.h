//
//  OCLexer.h
//  OCParser
//
//  Created by sgcy on 2018/11/14.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class OCToken;
@class OCLexer;

@interface OCLexer : NSObject

@property (nonatomic, copy) NSString *string;
@property (nonatomic, readonly) NSUInteger lineNumber;

+ (OCLexer *)lexer;
+ (OCLexer *)lexerWithString:(NSString *)s;
- (instancetype)initWithString:(NSString *)s;

- (OCToken *)nextToken;

- (NSArray *)allTokens;
- (NSArray *)allTokens:(BOOL)withWhiteSpace;

@end

