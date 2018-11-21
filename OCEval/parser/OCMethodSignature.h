//
//  OCMethodSignature.h
//  OCParser
//
//  Created by sgcy on 2018/11/19.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ffi.h"

@interface OCMethodSignature : NSObject

@property (nonatomic, strong) NSString *types;
@property (nonatomic, strong) NSArray *argumentTypes;
@property (nonatomic, strong) NSString *returnType;

- (instancetype)initWithBlockTypeNames:(NSArray *)typeNames;
- (instancetype)initWithObjCTypes:(NSString *)objCTypes;

+ (ffi_type *)ffiTypeWithEncodingChar:(const char *)c;
+ (NSString *)typeEncodeWithTypeName:(NSString *)typeName;

@end
