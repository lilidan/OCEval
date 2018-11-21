//
//  OCCFuntionWrapper.m
//  OCParser
//
//  Created by sgcy on 2018/11/21.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCCFuntionWrapper.h"
#import "OCMethodNode+invoke.h"

@implementation OCCFuntionWrapper

+ (id)callCFunction:(NSString *)funcName arguments:(NSArray *)arguments
{
    funcName = [funcName stringByAppendingString:@":"];
    return [OCMethodNode invokeWithCaller:self selectorName:funcName argments:@[arguments]];
}

+ (id)CGRectMake:(NSArray *)arguments
{
    return [NSValue valueWithCGRect:CGRectMake([arguments[0] doubleValue], [arguments[1] doubleValue], [arguments[2] doubleValue], [arguments[3] doubleValue])];
}

+ (id)CGRectZero:(NSArray *)arguments
{
    return [NSValue valueWithCGRect:CGRectZero];
}

+ (id)CGPointMake:(NSArray *)arguments
{
    return [NSValue valueWithCGPoint:CGPointMake([arguments[0] doubleValue], [arguments[1] doubleValue])];
}

+ (id)CGPointZero:(NSArray *)arguments
{
    return [NSValue valueWithCGPoint:CGPointZero];
}

+ (id)CGSizeMake:(NSArray *)arguments
{
    return [NSValue valueWithCGSize:CGSizeMake([arguments[0] doubleValue], [arguments[1] doubleValue])];
}

+ (id)CGSizeZero:(NSArray *)arguments
{
    return [NSValue valueWithCGSize:CGSizeZero];
}

+ (id)NSRangeMake:(NSArray *)arguments
{
    return [NSValue valueWithRange:NSMakeRange([arguments[0] integerValue], [arguments[1] integerValue])];
}

@end

