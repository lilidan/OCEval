//
//  NSValue+struct.h
//  OCEval
//
//  Created by sgcy on 2018/11/27.
//

#if TARGET_OS_IPHONE
@import UIKit;
#else
@import AppKit;
#endif


@interface NSValue(structt)

//CGPoint,CGSize,CGRect
- (id)setX:(CGFloat)x;
- (CGFloat)x;
- (id)setY:(CGFloat)y;
- (CGFloat)y;

- (id)setWidth:(CGFloat)width;
- (CGFloat)width;
- (id)setHeight:(CGFloat)height;
- (CGFloat)height;

- (id)setOrigin:(CGPoint)origin;
- (id)setSize:(CGSize)size;
- (CGPoint)origin;
- (CGSize)size;

//NSRange
- (id)setLocation:(NSUInteger)location;
- (NSUInteger)location;
- (id)setLength:(NSUInteger)length;
- (NSUInteger)length;

//UIOffset
- (id)setHorizontal:(CGFloat)horizontal;
- (CGFloat)horizontal;
- (id)setVertical:(CGFloat)vertical;
- (CGFloat)vertical;


//UIEdgeInsets

- (id)setTop:(CGFloat)top;
- (CGFloat)top;
- (id)setLeading:(CGFloat)leading;
- (CGFloat)leading;
- (id)setBottom:(CGFloat)bottom;
- (CGFloat)bottom;
- (id)setTrailing:(CGFloat)trailing;
- (CGFloat)trailing;

//NSDirectionalEdgeInsets
//CGVector
//CGAffineTransform

@end
