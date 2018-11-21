//
//  OCMethodNode+invoke.h
//  OCParser
//
//  Created by sgcy on 2018/11/18.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCMethodNode.h"

@interface OCMethodNode(invoke)

+ (id)nilObj;
+ (id)invokeWithCaller:(id)caller selectorName:(NSString *)selectorName argments:(NSArray *)arguments;
+ (id)invokeWithInvocation:(NSInvocation *)invocation argments:(NSArray *)arguments;

@end
