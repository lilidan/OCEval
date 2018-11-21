//
//  JPBlockWrapper.h
//  JSPatch
//
//  Created by bang on 1/19/17.
//  Copyright © 2017 bang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OCBlockNode;

@interface OCBlockWrapper : NSObject

+ (instancetype)blockWrapperWithNode:(OCBlockNode *)node;

- (void *)blockPtrWithCtx:(NSDictionary *)ctx;

+ (id)excuteBlock:(id)block withParams:(NSArray *)params;

@end
