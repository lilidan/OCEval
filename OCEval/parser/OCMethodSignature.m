//
//  OCMethodSignature.m
//  OCParser
//
//  Created by sgcy on 2018/11/19.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCMethodSignature.h"
#import "OCExtension.h"

@implementation OCMethodSignature{
    NSArray *_typeNames;
}

- (instancetype)initWithBlockTypeNames:(NSArray *)typeNames
{
    if (self = [super init]) {
        _typeNames = typeNames;
        [self parseTypeNames];
        [self parse];
    }
    return self;
}

- (instancetype)initWithObjCTypes:(NSString *)objCTypes
{
    self = [super init];
    if (self) {
        _types = objCTypes;
        [self parse];
    }
    return self;
}

- (void)parse
{
    NSMutableArray *argumentTypes = [[NSMutableArray alloc] init];
    int i = 0;
    while (i < _types.length) {
        unichar c = [_types characterAtIndex:i];
        NSString *arg;
        
        if (isdigit(c)) {
            i++;
            continue;
        }
        
        BOOL skipNext = NO;
        if (c == '^') {
            skipNext = YES;
            arg = [_types substringWithRange:NSMakeRange(i, 2)];
            
        } else if (c == '?') {
            // @? is block
            arg = [_types substringWithRange:NSMakeRange(i - 1, 2)];
            [argumentTypes removeLastObject];
        } else if (c == '{') {
            int semaphore = 1;
            int j = i + 1;
            while (semaphore > 0) {
                arg = [_types substringWithRange:NSMakeRange(i, j - i)];
                unichar c2 = [_types characterAtIndex:j];
                if (c2 == '{') {
                    semaphore ++;
                }else if (c2 == '}') {
                    semaphore --;
                }
                j++;
            }
            arg = [_types substringWithRange:NSMakeRange(i, j - i)];
            if (i == 0) {
                _returnType = arg;
            } else {
                [argumentTypes addObject:arg];
            }
            i = (int)j;
            continue;
        } else {
            
            arg = [_types substringWithRange:NSMakeRange(i, 1)];
        }
        
        if (i == 0) {
            _returnType = arg;
        } else {
            [argumentTypes addObject:arg];
        }
        i ++;
        if (skipNext) i++;
    }
    self.argumentTypes = [argumentTypes copy];
}

- (void)parseTypeNames
{
    NSMutableString *encodeStr = [[NSMutableString alloc] init];
    NSArray *typeArr = _typeNames;
    for (NSInteger i = 0; i < typeArr.count; i++) {
        NSString *typeStr = trim([typeArr objectAtIndex:i]);
        NSString *encode = [OCMethodSignature typeEncodeWithTypeName:typeStr];
        if (!encode) {
            NSString *argClassName = trim([typeStr stringByReplacingOccurrencesOfString:@"*" withString:@""]);
            if (NSClassFromString(argClassName) != NULL) {
                encode = @"@";
            } else {
                NSCAssert(NO, @"unreconized type %@", typeStr);
                return;
            }
        }
        [encodeStr appendString:encode];
        int length = [OCMethodSignature typeLengthWithTypeName:typeStr];
        [encodeStr appendString:[NSString stringWithFormat:@"%d", length]];
        
        if (i == 0) {
            // Blocks are passed one implicit argument - the block, of type "@?".
            [encodeStr appendString:@"@?0"];
        }
    }
    _types = encodeStr;
}

#pragma mark - class methods

+ (ffi_type *)ffiTypeWithEncodingChar:(const char *)c
{
    switch (c[0]) {
        case 'v':
            return &ffi_type_void;
        case 'c':
            return &ffi_type_schar;
        case 'C':
            return &ffi_type_uchar;
        case 's':
            return &ffi_type_sshort;
        case 'S':
            return &ffi_type_ushort;
        case 'i':
            return &ffi_type_sint;
        case 'I':
            return &ffi_type_uint;
        case 'l':
            return &ffi_type_slong;
        case 'L':
            return &ffi_type_ulong;
        case 'q':
            return &ffi_type_sint64;
        case 'Q':
            return &ffi_type_uint64;
        case 'f':
            return &ffi_type_float;
        case 'd':
            return &ffi_type_double;
        case 'F':
#if CGFLOAT_IS_DOUBLE
            return &ffi_type_double;
#else
            return &ffi_type_float;
#endif
        case 'B':
            return &ffi_type_uint8;
        case '^':
            return &ffi_type_pointer;
        case '@':
            return &ffi_type_pointer;
        case '#':
            return &ffi_type_pointer;
        case '{': //c struct support ?
        {
            NSString *typeStr = [NSString stringWithCString:c encoding:NSASCIIStringEncoding];
            NSUInteger end = [typeStr rangeOfString:@"="].location;
            if (end != NSNotFound) {
                NSString *structName = [typeStr substringWithRange:NSMakeRange(1, end - 1)];
                ffi_type *type = malloc(sizeof(ffi_type));
                type->alignment = 0;
                type->size = 0;
                type->type = FFI_TYPE_STRUCT;
                NSDictionary *structDefine = [OCExtension registeredStruct][structName];
                NSUInteger subTypeCount = [structDefine[@"keys"] count];
                NSString *subTypes = structDefine[@"types"];
                ffi_type **sub_types = malloc(sizeof(ffi_type *) * (subTypeCount + 1));
                for (NSUInteger i=0; i<subTypeCount; i++) {
                    const char c = [subTypes cStringUsingEncoding:NSASCIIStringEncoding][i];
                    ffi_type *type = [self ffiTypeWithEncodingChar:&c];
                    sub_types[i] = type;
                }
                sub_types[subTypeCount] = NULL;
                type->elements = sub_types;
                printf("number of test.elements: %d\n", (int)(sizeof(sub_types) / sizeof(ffi_type *)));
                return type;
            }
        }
    }
    return NULL;
}

static NSMutableDictionary *_typeEncodeDict;
static NSMutableDictionary *_typeLengthDict;

+ (int)typeLengthWithTypeName:(NSString *)typeName
{
    if (!typeName) return 0;
    if (!_typeLengthDict) {
        _typeLengthDict = [[NSMutableDictionary alloc] init];
        
#define JP_DEFINE_TYPE_LENGTH(_type) \
[_typeLengthDict setObject:@(sizeof(_type)) forKey:@#_type];\

        JP_DEFINE_TYPE_LENGTH(id);
        JP_DEFINE_TYPE_LENGTH(BOOL);
        JP_DEFINE_TYPE_LENGTH(int);
        JP_DEFINE_TYPE_LENGTH(void);
        JP_DEFINE_TYPE_LENGTH(char);
        JP_DEFINE_TYPE_LENGTH(short);
        JP_DEFINE_TYPE_LENGTH(unsigned short);
        JP_DEFINE_TYPE_LENGTH(unsigned int);
        JP_DEFINE_TYPE_LENGTH(long);
        JP_DEFINE_TYPE_LENGTH(unsigned long);
        JP_DEFINE_TYPE_LENGTH(long long);
        JP_DEFINE_TYPE_LENGTH(unsigned long long);
        JP_DEFINE_TYPE_LENGTH(float);
        JP_DEFINE_TYPE_LENGTH(double);
        JP_DEFINE_TYPE_LENGTH(bool);
        JP_DEFINE_TYPE_LENGTH(size_t);
        JP_DEFINE_TYPE_LENGTH(CGFloat);
        JP_DEFINE_TYPE_LENGTH(CGSize);
        JP_DEFINE_TYPE_LENGTH(CGRect);
        JP_DEFINE_TYPE_LENGTH(CGPoint);
        JP_DEFINE_TYPE_LENGTH(CGVector);
        JP_DEFINE_TYPE_LENGTH(NSRange);
        JP_DEFINE_TYPE_LENGTH(NSInteger);
        JP_DEFINE_TYPE_LENGTH(NSUInteger);
        JP_DEFINE_TYPE_LENGTH(NSComparisonResult);
        JP_DEFINE_TYPE_LENGTH(Class);
        JP_DEFINE_TYPE_LENGTH(SEL);
        JP_DEFINE_TYPE_LENGTH(void*);
        JP_DEFINE_TYPE_LENGTH(void *);
        JP_DEFINE_TYPE_LENGTH(id *);
    }
    return [_typeLengthDict[typeName] intValue];
}

+ (NSString *)typeEncodeWithTypeName:(NSString *)typeName
{
    if (!typeName) return nil;
    if (!_typeEncodeDict) {
        _typeEncodeDict = [[NSMutableDictionary alloc] init];
#define JP_DEFINE_TYPE_ENCODE_CASE(_type) \
[_typeEncodeDict setObject:[NSString stringWithUTF8String:@encode(_type)] forKey:@#_type];\

        JP_DEFINE_TYPE_ENCODE_CASE(id);
        JP_DEFINE_TYPE_ENCODE_CASE(BOOL);
        JP_DEFINE_TYPE_ENCODE_CASE(int);
        JP_DEFINE_TYPE_ENCODE_CASE(void);
        JP_DEFINE_TYPE_ENCODE_CASE(char);
        JP_DEFINE_TYPE_ENCODE_CASE(short);
        JP_DEFINE_TYPE_ENCODE_CASE(unsigned short);
        JP_DEFINE_TYPE_ENCODE_CASE(unsigned int);
        JP_DEFINE_TYPE_ENCODE_CASE(long);
        JP_DEFINE_TYPE_ENCODE_CASE(unsigned long);
        JP_DEFINE_TYPE_ENCODE_CASE(long long);
        JP_DEFINE_TYPE_ENCODE_CASE(unsigned long long);
        JP_DEFINE_TYPE_ENCODE_CASE(float);
        JP_DEFINE_TYPE_ENCODE_CASE(double);
        JP_DEFINE_TYPE_ENCODE_CASE(bool);
        JP_DEFINE_TYPE_ENCODE_CASE(size_t);
        JP_DEFINE_TYPE_ENCODE_CASE(CGFloat);
        JP_DEFINE_TYPE_ENCODE_CASE(CGSize);
        JP_DEFINE_TYPE_ENCODE_CASE(CGRect);
        JP_DEFINE_TYPE_ENCODE_CASE(CGPoint);
        JP_DEFINE_TYPE_ENCODE_CASE(CGVector);
        JP_DEFINE_TYPE_ENCODE_CASE(NSRange);
        JP_DEFINE_TYPE_ENCODE_CASE(NSInteger);
        JP_DEFINE_TYPE_ENCODE_CASE(NSUInteger);
        JP_DEFINE_TYPE_ENCODE_CASE(NSComparisonResult);
        JP_DEFINE_TYPE_ENCODE_CASE(Class);
        JP_DEFINE_TYPE_ENCODE_CASE(SEL);
        JP_DEFINE_TYPE_ENCODE_CASE(void*);
        JP_DEFINE_TYPE_ENCODE_CASE(void *);
        [_typeEncodeDict setObject:@"@?" forKey:@"block"];
        [_typeEncodeDict setObject:@"^@" forKey:@"id*"];
    }
    return _typeEncodeDict[typeName];
}

static NSString *trim(NSString *string)
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
