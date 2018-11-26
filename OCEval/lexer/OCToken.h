//
//  OCToken.h
//  OCParser
//
//  Created by sgcy on 2018/11/14.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, OCTokenType) {
    OCTokenTypeEOF = 0,
    OCTokenTypeNumber = 1,
    OCTokenTypeString = 2,
    OCTokenTypeSymbol = 3,
    OCTokenTypeWord = 4,
    OCTokenTypeWhitespace = 5,
    OCTokenTypeComment = 6
};

#define SUB_TYPES @[@"if",@"else",@"do",@"while",@"for",@"in",@"continue",@"break",@"return",@"selector",@"self",@"super",@"nil",@"YES",@"NO",@"__weak",@"__strong",@"__block",@"_Nonnull",@"_Nullable",\
@"(",@")",@"[",@"]",@"{",@"}",@";",@"=",@".",@",",@":",@"+",@"-",@"*",@"/",@"&",@"|",@"!",@">",@">=",@"<",@"<=",@"==",@"!=",@"&&",@"||",@"@",@"^",@"++",@"--",@"+=",@"-="\
]

typedef NS_ENUM(NSUInteger, OCTokenSubType) {
    OCTokenSubTypeNone = 0,
    OCWordSubTypeIf,
    OCWordSubTypeElse,
    OCWordSubTypeDo,
    OCWordSubTypeWhile,
    OCWordSubTypeFor,
    OCWordSubTypeIn,
    OCWordSubTypeContinue,
    OCWordSubTypeBreak,
    OCWordSubTypeReturn,
    OCWordSubTypeSelector,
    OCWordSubTypeSelf,
    OCWordSubTypeSuper,
    OCWordSubTypeNil,
    OCWordSubTypeYES,
    OCWordSubTypeNO,
    OCWordSubTypeWeak,
    OCWordSubTypeStrong,
    OCWordSubTypeBlock,
    OCWordSubTypeNonnull,
    OCWordSubTypenullable,
    //
    OCSymbolSubTypeLeftParen,
    OCSymbolSubTypeRightParen,
    OCSymbolSubTypeLeftSquare,
    OCSymbolSubTypeRightSquare,
    OCSymbolSubTypeLeftBrace,
    OCSymbolSubTypeRightBrace,
    OCSymbolSubTypeSemi,
    OCSymbolSubTypeEqual,
    OCSymbolSubTypePoint,
    OCSymbolSubTypeComma,
    OCSymbolSubTypeColon,
    OCSymbolSubTypeAdd,
    OCSymbolSubTypeMinus,
    OCSymbolSubTypeStar,
    OCSymbolSubTypeSlash,
    OCSymbolSubTypeAmp,
    OCSymbolSubTypePipe,
    OCSymbolSubTypeExclaim,
    OCSymbolSubTypeGreaterThan,
    OCSymbolSubTypeGreaterThanOrEqual,
    OCSymbolSubTypeLessThan,
    OCSymbolSubTypeLessThanOrEqual,
    OCSymbolSubTypeEqualEqual,
    OCSymbolSubTypeExclaimEqual,
    OCSymbolSubTypeAmpAmp,
    OCSymbolSubTypePipepipe,
    OCSymbolSubTypeAt,
    OCSymbolSubTypeCaret,
    OCSymbolSubTypeAddAdd,
    OCSymbolSubTypeMinusMinus,
    OCSymbolSubTypeAddEqual,
    OCSymbolSubTypeMinusEqual,
};



@interface OCToken : NSObject

@property (nonatomic, readonly) OCTokenType tokenType;
@property (nonatomic, assign) OCTokenSubType tokenSubType;

@property (nonatomic, readonly) double doubleValue;
@property (nonatomic, readonly, copy) NSString *stringValue;
@property (nonatomic, readonly, copy) id value;

@property (nonatomic, assign) NSUInteger offset;
@property (nonatomic, assign) NSUInteger lineNumber;

+ (OCToken *)EOFToken;

+ (instancetype)tokenWithTokenType:(OCTokenType)t stringValue:(NSString *)s doubleValue:(double)n;
- (instancetype)initWithTokenType:(OCTokenType)t stringValue:(NSString *)s doubleValue:(double)n;

- (BOOL)isEqualIgnoringCase:(id)obj;

- (NSString *)debugDescription;

@end

