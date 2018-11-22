//
//  OCLexer.m
//  OCParser
//
//  Created by sgcy on 2018/11/14.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCLexer.h"
#import "OCReader.h"
#import "OCToken.h"

@interface OCLexer()

@property (nonatomic, strong) OCReader *reader;
@property (nonatomic, readwrite) NSUInteger lineNumber;

@property (nonatomic, assign) OCTokenType lastTokenType;
@property (nonatomic, assign) OCTokenType currentTokenType;
@property (nonatomic, strong) NSMutableString *stringbuf;

@end

@implementation OCLexer


+ (OCLexer *)lexer {
    return [self lexerWithString:nil];
}


+ (OCLexer *)lexerWithString:(NSString *)s {
    return [[self alloc] initWithString:s];
}


- (instancetype)init {
    return [self initWithString:nil];
}

- (instancetype)initWithString:(NSString *)s {
    self = [super init];
    if (self) {
        self.string = s;
        self.reader = [[OCReader alloc] init];
    }
    return self;
}


- (void)setReader:(OCReader *)r {
    if (_reader != r) {
        _reader = r;
        _reader.string = _string;
    }
}


- (void)setString:(NSString *)s {
    if (_string != s) {
        _string = [s copy];
    }
    _reader.string = _string;
}

- (OCToken *)nextToken {
    NSAssert(_reader, @"");
    char c = [_reader read]; //NSLog(@"%@", [[[NSString alloc] initWithBytes:&c length:1 encoding:4] autorelease]);
    
    OCToken *result = nil;
    
    if (EOF == c) {
        result = [OCToken EOFToken];
    } else {
        result = [self tokenFor:c];
    }
    
    return result;
}

- (NSArray *)allTokens
{
    return [self allTokens:YES];
}

- (NSArray *)allTokens:(BOOL)withWhiteSpace
{
    NSMutableArray *allTokens = [[NSMutableArray alloc] init];
    OCToken *token;
    while (token != [OCToken EOFToken]){
        token = [self nextToken];
        token.lineNumber = self.lineNumber;
        token.offset = self.reader.offset;
        if (token != [OCToken EOFToken] && (withWhiteSpace || token.tokenType != OCTokenTypeWhitespace)) {
            [allTokens addObject:token];
        }
    }
    return [allTokens copy];
}

#pragma mark -

- (OCToken *)tokenFor:(unichar)c{
    self.stringbuf = [[NSMutableString alloc] init];
    [self.stringbuf appendFormat:@"%C", (unichar)c];
    switch (c) {
        case '0': case '1': case '2': case '3': case '4':
        case '5': case '6': case '7': case '8': case '9':
            //读取后面是小数点的情况。
            return [self readNumberToken];
            
        case 'A': case 'B': case 'C': case 'D': case 'E': case 'F': case 'G':
        case 'H': case 'I': case 'J': case 'K': case 'L': case 'M': case 'N':
        case 'O': case 'P': case 'Q': case 'R': case 'S': case 'T': case 'U':
        case 'V': case 'W': case 'X': case 'Y': case 'Z':
        case 'a': case 'b': case 'c': case 'd': case 'e': case 'f': case 'g':
        case 'h': case 'i': case 'j': case 'k': case 'l': case 'm': case 'n':
        case 'o': case 'p': case 'q': case 'r': case 's': case 't': case 'u':
        case 'v': case 'w': case 'x': case 'y': case 'z':
        case '_':
            //考虑为词
            return [self readWordToken];
            
        case '"': case '\'':
            self.stringbuf = [[NSMutableString alloc] init];
            return [self readQuote:c];
            
        case'?': case'[': case']':case '(':case ')':case '{':case '}':
        case '.'://肯定不为数字，考虑为. 语法
        case '%': case ',':case '@':case '~':case ';':
            //都是单一symbol
            return [OCToken tokenWithTokenType:OCTokenTypeSymbol stringValue:self.stringbuf doubleValue:0];
            
        case '*': case '+': case '-':  case '^'://考虑++，+= 和单独+的情况。
        case '/'://可以是除法，可以是注释。二期考虑注释。
        case '<': case '>': case '!':            //考虑单独出现和等于出现的情况。考虑位移计算的情况。
        case '|': case '&': //考虑为指针转换和逻辑运算符情况。
        case ':': //单独出现和连续出现的情况
        case '=':
            return [self readSymbol:c];
        case ' ':
            return [self readWhiteSpace];
        case '\n':
            self.lineNumber += 1;
            return [self readWhiteSpace];
        default:
            break;
    }
    return [OCToken EOFToken];
}

- (OCToken *)readNumberToken
{
    unichar c = [self.reader read];
    if (isdigit(c) || (c == '.')) { //二期区分
        [_stringbuf appendFormat:@"%C", (unichar)c];
        return [self readNumberToken];
    }else{
        [self.reader unread];
        return [OCToken tokenWithTokenType:OCTokenTypeNumber stringValue:self.stringbuf doubleValue:self.stringbuf.doubleValue];
    }
}

- (OCToken *)readWordToken
{
    unichar c = [self.reader read];
    if (c == '_' || [[NSCharacterSet alphanumericCharacterSet] characterIsMember:c]) {
        [_stringbuf appendFormat:@"%C", (unichar)c];
        return [self readWordToken];
    }else{
        [self.reader unread];
        return [OCToken tokenWithTokenType:OCTokenTypeWord stringValue:self.stringbuf doubleValue:0];
    }
}
- (OCToken *)readQuote:(unichar)c
{
    unichar c2 = [self.reader read];
    if (c2 != c) {
        [_stringbuf appendFormat:@"%C", (unichar)c2];
        return [self readQuote:c];
    }else{
        return [OCToken tokenWithTokenType:OCTokenTypeString stringValue:self.stringbuf doubleValue:0];
    }
}


- (OCToken *)readSymbol:(unichar)c
{
    unichar c2 = [self.reader read];
    if (c2 == c || c2 == '=') {
        [_stringbuf appendFormat:@"%C", (unichar)c2];
        return [OCToken tokenWithTokenType:OCTokenTypeSymbol stringValue:self.stringbuf doubleValue:0];
    }else{
        [self.reader unread];
        return [OCToken tokenWithTokenType:OCTokenTypeSymbol stringValue:self.stringbuf doubleValue:0];
    }
}

- (OCToken *)readWhiteSpace
{
    unichar c = [self.reader read];
    if (c == ' ' || c == '\n') {
        [_stringbuf appendFormat:@"%C", (unichar)c];
        if (c == '\n') {
            self.lineNumber += 1;
        }
        return [self readWhiteSpace];
    }else{
        [self.reader unread];
        return [OCToken tokenWithTokenType:OCTokenTypeWhitespace stringValue:self.stringbuf doubleValue:0];
    }
}


@end
