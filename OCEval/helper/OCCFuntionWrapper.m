//
//  OCCFuntionWrapper.m
//  OCParser
//
//  Created by sgcy on 2018/11/21.
//  Copyright © 2018年 sgcy. All rights reserved.
//


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
#if TARGET_OS_IPHONE
    return [NSValue valueWithCGRect:CGRectMake([arguments[0] doubleValue], [arguments[1] doubleValue], [arguments[2] doubleValue], [arguments[3] doubleValue])];
#else
    return [NSValue valueWithRect:CGRectMake([arguments[0] doubleValue], [arguments[1] doubleValue], [arguments[2] doubleValue], [arguments[3] doubleValue])];
#endif
}

+ (id)CGRectZero:(NSArray *)arguments
{
#if TARGET_OS_IPHONE
    return [NSValue valueWithCGRect:CGRectZero];
#else
    return [NSValue valueWithRect:CGRectZero];
#endif
}

+ (id)CGPointMake:(NSArray *)arguments
{
#if TARGET_OS_IPHONE
    return [NSValue valueWithCGPoint:CGPointMake([arguments[0] doubleValue], [arguments[1] doubleValue])];
#else
    return [NSValue valueWithPoint:CGPointMake([arguments[0] doubleValue], [arguments[1] doubleValue])];
#endif
}

+ (id)CGPointZero:(NSArray *)arguments
{
#if TARGET_OS_IPHONE
    return [NSValue valueWithCGPoint:CGPointZero];
#else
    return [NSValue valueWithPoint:CGPointZero];
#endif
}

+ (id)CGSizeMake:(NSArray *)arguments
{
#if TARGET_OS_IPHONE
    return [NSValue valueWithCGSize:CGSizeMake([arguments[0] doubleValue], [arguments[1] doubleValue])];
#else
    return [NSValue valueWithSize:CGSizeMake([arguments[0] doubleValue], [arguments[1] doubleValue])];
#endif
}

+ (id)CGSizeZero:(NSArray *)arguments
{
#if TARGET_OS_IPHONE
    return [NSValue valueWithCGSize:CGSizeZero];
#else
    return [NSValue valueWithSize:CGSizeZero];
#endif
}

+ (id)NSRangeMake:(NSArray *)arguments
{
    return [NSValue valueWithRange:NSMakeRange([arguments[0] integerValue], [arguments[1] integerValue])];
}

@end

