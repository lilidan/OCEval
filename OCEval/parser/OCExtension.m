//
//  OCExtension.m
//  OCParser
//
//  Created by sgcy on 2018/11/21.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCExtension.h"

#if CGFLOAT_IS_DOUBLE
#define CGFloatValue doubleValue
#else
#define CGFloatValue floatValue
#endif

static NSMutableDictionary *_registeredStruct;

@implementation OCExtension

+ (void)load
{
    _registeredStruct = [[NSMutableDictionary alloc] init];
}

+ (void)defineStruct:(NSDictionary *)defineDict
{
    [_registeredStruct setObject:defineDict forKey:defineDict[@"name"]];
}


#pragma mark - Struct

static int sizeOfStructTypes(NSString *structTypes)
{
    const char *types = [structTypes cStringUsingEncoding:NSUTF8StringEncoding];
    int index = 0;
    int size = 0;
    while (types[index]) {
        switch (types[index]) {
#define JP_STRUCT_SIZE_CASE(_typeChar, _type)   \
case _typeChar: \
size += sizeof(_type);  \
break;
                
                JP_STRUCT_SIZE_CASE('c', char)
                JP_STRUCT_SIZE_CASE('C', unsigned char)
                JP_STRUCT_SIZE_CASE('s', short)
                JP_STRUCT_SIZE_CASE('S', unsigned short)
                JP_STRUCT_SIZE_CASE('i', int)
                JP_STRUCT_SIZE_CASE('I', unsigned int)
                JP_STRUCT_SIZE_CASE('l', long)
                JP_STRUCT_SIZE_CASE('L', unsigned long)
                JP_STRUCT_SIZE_CASE('q', long long)
                JP_STRUCT_SIZE_CASE('Q', unsigned long long)
                JP_STRUCT_SIZE_CASE('f', float)
                JP_STRUCT_SIZE_CASE('F', CGFloat)
                JP_STRUCT_SIZE_CASE('N', NSInteger)
                JP_STRUCT_SIZE_CASE('U', NSUInteger)
                JP_STRUCT_SIZE_CASE('d', double)
                JP_STRUCT_SIZE_CASE('B', BOOL)
                JP_STRUCT_SIZE_CASE('*', void *)
                JP_STRUCT_SIZE_CASE('^', void *)
                
            case '{': {
                NSString *structTypeStr = [structTypes substringFromIndex:index];
                NSUInteger end = [structTypeStr rangeOfString:@"}"].location;
                if (end != NSNotFound) {
                    NSString *subStructName = [structTypeStr substringWithRange:NSMakeRange(1, end - 1)];
                    NSDictionary *subStructDefine = [OCExtension registeredStruct][subStructName];
                    NSString *subStructTypes = subStructDefine[@"types"];
                    size += sizeOfStructTypes(subStructTypes);
                    index += (int)end;
                    break;
                }
            }
                
            default:
                break;
        }
        index ++;
    }
    return size;
}

static void getStructDataWithDict(void *structData, NSDictionary *dict, NSDictionary *structDefine)
{
    NSArray *itemKeys = structDefine[@"keys"];
    const char *structTypes = [structDefine[@"types"] cStringUsingEncoding:NSUTF8StringEncoding];
    int position = 0;
    for (NSString *itemKey in itemKeys) {
        switch(*structTypes) {
#define JP_STRUCT_DATA_CASE(_typeStr, _type, _transMethod) \
case _typeStr: { \
int size = sizeof(_type);    \
_type val = [dict[itemKey] _transMethod];   \
memcpy(structData + position, &val, size);  \
position += size;    \
break;  \
}
                
                JP_STRUCT_DATA_CASE('c', char, charValue)
                JP_STRUCT_DATA_CASE('C', unsigned char, unsignedCharValue)
                JP_STRUCT_DATA_CASE('s', short, shortValue)
                JP_STRUCT_DATA_CASE('S', unsigned short, unsignedShortValue)
                JP_STRUCT_DATA_CASE('i', int, intValue)
                JP_STRUCT_DATA_CASE('I', unsigned int, unsignedIntValue)
                JP_STRUCT_DATA_CASE('l', long, longValue)
                JP_STRUCT_DATA_CASE('L', unsigned long, unsignedLongValue)
                JP_STRUCT_DATA_CASE('q', long long, longLongValue)
                JP_STRUCT_DATA_CASE('Q', unsigned long long, unsignedLongLongValue)
                JP_STRUCT_DATA_CASE('f', float, floatValue)
                JP_STRUCT_DATA_CASE('F', CGFloat, CGFloatValue)
                JP_STRUCT_DATA_CASE('d', double, doubleValue)
                JP_STRUCT_DATA_CASE('B', BOOL, boolValue)
                JP_STRUCT_DATA_CASE('N', NSInteger, integerValue)
                JP_STRUCT_DATA_CASE('U', NSUInteger, unsignedIntegerValue)
                
            case '*':
            case '{': {
                NSString *subStructName = [NSString stringWithCString:structTypes encoding:NSASCIIStringEncoding];
                NSUInteger end = [subStructName rangeOfString:@"}"].location;
                if (end != NSNotFound) {
                    subStructName = [subStructName substringWithRange:NSMakeRange(1, end - 1)];
                    NSDictionary *subStructDefine = [OCExtension registeredStruct][subStructName];
                    NSDictionary *subDict = dict[itemKey];
                    int size = sizeOfStructTypes(subStructDefine[@"types"]);
                    getStructDataWithDict(structData + position, subDict, subStructDefine);
                    position += size;
                    structTypes += end;
                    break;
                }
            }
            default:
                break;
                
        }
        structTypes ++;
    }
}

static NSDictionary *getDictOfStruct(void *structData, NSDictionary *structDefine)
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    NSArray *itemKeys = structDefine[@"keys"];
    const char *structTypes = [structDefine[@"types"] cStringUsingEncoding:NSUTF8StringEncoding];
    int position = 0;
    
    for (NSString *itemKey in itemKeys) {
        switch(*structTypes) {
#define JP_STRUCT_DICT_CASE(_typeName, _type)   \
case _typeName: { \
size_t size = sizeof(_type); \
_type *val = malloc(size);   \
memcpy(val, structData + position, size);   \
[dict setObject:@(*val) forKey:itemKey];    \
free(val);  \
position += size;   \
break;  \
}
                JP_STRUCT_DICT_CASE('c', char)
                JP_STRUCT_DICT_CASE('C', unsigned char)
                JP_STRUCT_DICT_CASE('s', short)
                JP_STRUCT_DICT_CASE('S', unsigned short)
                JP_STRUCT_DICT_CASE('i', int)
                JP_STRUCT_DICT_CASE('I', unsigned int)
                JP_STRUCT_DICT_CASE('l', long)
                JP_STRUCT_DICT_CASE('L', unsigned long)
                JP_STRUCT_DICT_CASE('q', long long)
                JP_STRUCT_DICT_CASE('Q', unsigned long long)
                JP_STRUCT_DICT_CASE('f', float)
                JP_STRUCT_DICT_CASE('F', CGFloat)
                JP_STRUCT_DICT_CASE('N', NSInteger)
                JP_STRUCT_DICT_CASE('U', NSUInteger)
                JP_STRUCT_DICT_CASE('d', double)
                JP_STRUCT_DICT_CASE('B', BOOL)
                
            case '*':

            case '{': {
                NSString *subStructName = [NSString stringWithCString:structTypes encoding:NSASCIIStringEncoding];
                NSUInteger end = [subStructName rangeOfString:@"}"].location;
                if (end != NSNotFound) {
                    subStructName = [subStructName substringWithRange:NSMakeRange(1, end - 1)];
                    NSDictionary *subStructDefine = [OCExtension registeredStruct][subStructName];
                    int size = sizeOfStructTypes(subStructDefine[@"types"]);
                    NSDictionary *subDict = getDictOfStruct(structData + position, subStructDefine);
                    [dict setObject:subDict forKey:itemKey];
                    position += size;
                    structTypes += end;
                    break;
                }
            }
        }
        structTypes ++;
    }
    return dict;
}

static NSString *extractStructName(NSString *typeEncodeString)
{
    NSArray *array = [typeEncodeString componentsSeparatedByString:@"="];
    NSString *typeString = array[0];
    int firstValidIndex = 0;
    for (int i = 0; i< typeString.length; i++) {
        char c = [typeString characterAtIndex:i];
        if (c == '{' || c=='_') {
            firstValidIndex++;
        }else {
            break;
        }
    }
    return [typeString substringFromIndex:firstValidIndex];
}

#pragma mark - Utils


+ (NSString *)extractStructName:(NSString *)typeEncodeString
{
    return extractStructName(typeEncodeString);
}

static NSString *trim(NSString *string)
{
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (int)sizeOfStructTypes:(NSString *)structTypes
{
    return sizeOfStructTypes(structTypes);
}

+ (void)getStructDataWidthDict:(void *)structData dict:(NSDictionary *)dict structDefine:(NSDictionary *)structDefine
{
    return getStructDataWithDict(structData, dict, structDefine);
}

+ (NSDictionary *)getDictOfStruct:(void *)structData structDefine:(NSDictionary *)structDefine
{
    return getDictOfStruct(structData, structDefine);
}

+ (NSMutableDictionary *)registeredStruct
{
    return _registeredStruct;
}

@end
