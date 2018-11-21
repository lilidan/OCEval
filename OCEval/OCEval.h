//
//  OCEval.h
//  OCParser
//
//  Created by sgcy on 2018/11/21.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCEval : NSObject

+ (id)eval:(NSString *)str;

+ (id)eval:(NSString *)str context:(NSMutableDictionary *)context;

+ (void)hookClass:(Class)cls
         selector:(SEL)selector
         argNames:(NSArray<__kindof NSString *> *)argNames //original parameters variable name
          isClass:(BOOL)isClass //hook class method or instance method
   implementation:(NSString *)imp;

@end
