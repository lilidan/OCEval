//
//  OCExtension.h
//  OCParser
//
//  Created by sgcy on 2018/11/21.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#if TARGET_OS_IPHONE
@import UIKit;
#else
@import AppKit;
#endif

@interface OCExtension : NSObject

+ (int)sizeOfStructTypes:(NSString *)structTypes;
+ (void)getStructDataWidthDict:(void *)structData dict:(NSDictionary *)dict structDefine:(NSDictionary *)structDefine;
+ (NSDictionary *)getDictOfStruct:(void *)structData structDefine:(NSDictionary *)structDefine;

+ (NSMutableDictionary *)registeredStruct;

+ (NSString *)extractStructName:(NSString *)typeEncodeString;
+ (void)defineStruct:(NSDictionary *)defineDict;

@end

