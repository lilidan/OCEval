//
//  NSValue+struct.m
//  OCEval
//
//  Created by sgcy on 2018/11/27.
//


#import "NSValue+struct.h"


#if TARGET_OS_IPHONE
#define pointValue [self CGPointValue]
#define valueWithPoint(point) [NSValue valueWithCGPoint:point]
#define sizeValue [self CGSizeValue]
#define valueWithSize(size) [NSValue valueWithCGSize:size]
#define rectValue [self CGRectValue]
#define valueWithRect(rect) [NSValue valueWithCGRect:rect]

#else
#define pointValue [self pointValue]
#define valueWithPoint(point) [NSValue valueWithPoint:point]
#define sizeValue [self sizeValue]
#define valueWithSize(size) [NSValue valueWithSize:size]
#define rectValue [self rectValue]
#define valueWithRect(rect) [NSValue valueWithRect:rect]

#endif

#define rangeValue [self rangeValue]
#define valueWithRange(range) [NSValue valueWithRange:range]
#define offsetValue [self UIOffsetValue]
#define valueWithOffset(offset) [NSValue valueWithUIOffset:offset]

@implementation NSValue(structt)

//CGPoint,CGSize,CGRect
- (id)setX:(CGFloat)x
{
    return valueWithPoint(CGPointMake(x, pointValue.y));
}

- (CGFloat)x
{
    return pointValue.x;
}

- (id)setY:(CGFloat)y
{
    return valueWithPoint(CGPointMake(pointValue.x, y));
}

- (CGFloat)y
{
    return pointValue.y;
}

- (id)setWidth:(CGFloat)width
{
    return valueWithSize(CGSizeMake(width, sizeValue.width));
}

- (CGFloat)width
{
    return sizeValue.width;
}

- (id)setHeight:(CGFloat)height
{
    return valueWithSize(CGSizeMake(sizeValue.width, height));
}

- (CGFloat)height
{
    return sizeValue.height;
}

- (id)setOrigin:(CGPoint)origin
{
    return valueWithRect(CGRectMake(origin.x, origin.y, rectValue.size.width, rectValue.size.height));
}

- (id)setSize:(CGSize)size
{
    return valueWithRect(CGRectMake(rectValue.origin.x, rectValue.origin.y, size.width, size.height));
}

- (CGPoint)origin
{
    return rectValue.origin;
}

- (CGSize)size
{
    return rectValue.size;
}

//NSRange
- (id)setLocation:(NSUInteger)location
{
    return valueWithRange(NSMakeRange(location, rangeValue.length));
}

- (NSUInteger)location
{
    return rangeValue.location;
}

- (id)setLength:(NSUInteger)length
{
    return valueWithRange(NSMakeRange(rangeValue.location, length));
}

- (NSUInteger)length
{
    return rangeValue.length;
}

//UIOffset
- (id)setHorizontal:(CGFloat)horizontal
{
#if TARGET_OS_IPHONE
    return valueWithOffset(UIOffsetMake(horizontal,offsetValue.vertical));
#endif
    return nil;
}
- (CGFloat)horizontal
{
#if TARGET_OS_IPHONE
    return offsetValue.horizontal;
#endif
    return 0;
}

- (id)setVertical:(CGFloat)vertical
{
#if TARGET_OS_IPHONE
    return valueWithOffset(UIOffsetMake(offsetValue.horizontal,vertical));
#endif
    return nil;
}
- (CGFloat)vertical
{
#if TARGET_OS_IPHONE
    return offsetValue.vertical;
#endif
    return 0;
}


////UIEdgeInsets
//
//- (id)setTop:(CGFloat)top;
//- (CGFloat)top;
//- (id)setLeading:(CGFloat)leading;
//- (CGFloat)leading;
//- (id)setBottom:(CGFloat)bottom;
//- (CGFloat)bottom;
//- (id)setTrailing:(CGFloat)trailing;
//- (CGFloat)trailing;


@end
