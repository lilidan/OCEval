//
//  OCToken.m
//  OCParser
//
//  Created by sgcy on 2018/11/14.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCToken.h"

@interface OCTokenEOF : OCToken

@property (nonatomic,strong) NSDictionary *subTypeDictionary;
+ (OCTokenEOF *)instance;

@end

@implementation OCTokenEOF

static OCTokenEOF *EOFToken = nil;

+ (OCTokenEOF *)instance {
    @synchronized(self) {
        if (!EOFToken) {
            EOFToken = [[self alloc] initWithTokenType:OCTokenTypeEOF stringValue:@"«EOF»" doubleValue:0.0];
            NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
            [SUB_TYPES enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [mutDic setObject:@(idx + 1) forKey:obj];
            }];
            EOFToken.subTypeDictionary = [mutDic copy];
        }
    }
    return EOFToken;
}
- (NSString *)description {
    return [self stringValue];
}
- (NSString *)debugDescription {
    return [self description];
}

@end

@interface OCToken ()

- (BOOL)isEqual:(id)obj ignoringCase:(BOOL)ignoringCase;

@property (nonatomic, readwrite) double doubleValue;
@property (nonatomic, readwrite, copy) NSString *stringValue;
@property (nonatomic, readwrite) OCTokenType tokenType;
@property (nonatomic, readwrite, copy) id value;

@end

@implementation OCToken

+ (OCToken *)EOFToken {
    return [OCTokenEOF instance];
}


+ (instancetype)tokenWithTokenType:(OCTokenType)t stringValue:(NSString *)s doubleValue:(double)n {
    return [[self alloc] initWithTokenType:t stringValue:s doubleValue:n];
}


// designated initializer
- (instancetype)initWithTokenType:(OCTokenType)t stringValue:(NSString *)s doubleValue:(double)n {
    //NSParameterAssert(s);
    self = [super init];
    if (self) {
        self.tokenType = t;
        self.stringValue = s;
        self.doubleValue = n;
        self.offset = NSNotFound;
        self.lineNumber = NSNotFound;
        if (t == OCTokenTypeWord || t == OCTokenTypeSymbol) {
            NSNumber *subType = [[OCTokenEOF instance].subTypeDictionary objectForKey:s];
            if (subType) {
                self.tokenSubType = [subType integerValue];
            }
        }
    }
    return self;
}


- (NSUInteger)hash {
    return [_stringValue hash];
}


- (BOOL)isEqual:(id)obj {
    return [self isEqual:obj ignoringCase:NO];
}


- (BOOL)isEqualIgnoringCase:(id)obj {
    return [self isEqual:obj ignoringCase:YES];
}


- (BOOL)isEqual:(id)obj ignoringCase:(BOOL)ignoringCase {
    if (![obj isMemberOfClass:[OCToken class]]) {
        return NO;
    }
    
    OCToken *tok = (OCToken *)obj;
    if (_tokenType != tok->_tokenType) {
        return NO;
    }
    
    if (self.tokenType == OCTokenTypeNumber) {
        return _doubleValue == tok->_doubleValue;
    } else {
        if (ignoringCase) {
            return (NSOrderedSame == [_stringValue caseInsensitiveCompare:tok->_stringValue]);
        } else {
            return [_stringValue isEqualToString:tok->_stringValue];
        }
    }
}


- (BOOL)isEOF {
    return NO;
}


- (id)value {
    if (!_value) {
        id v = nil;
        if (self.tokenType == OCTokenTypeNumber) {
            v = [NSNumber numberWithDouble:_doubleValue];
        } else {
            v = _stringValue;
        }
        self.value = v;
    }
    return _value;
}


- (NSString *)debugDescription {
    NSString *typeString = [@(self.tokenType) stringValue];
    return [NSString stringWithFormat:@"%@ %C%@%C", typeString, (unichar)0x00AB, self.value, (unichar)0x00BB];
}


- (NSString *)description {
    NSArray *types = @[@"EOF",@"Number",@"String",@"Symbol",@"Word",@"WhiteSpace",@"Comment"];
    return [NSString stringWithFormat:@"%@ - %@ - ", types[self.tokenType], self.value];
}


@end
