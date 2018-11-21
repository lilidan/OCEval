//
//  OCLiteralNode.h
//  OCParser
//
//  Created by sgcy on 2018/11/17.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCNode.h"

typedef NS_ENUM(NSUInteger, OCLiteralNodeType) {
    OCLiteralNodeTypeSimple = 0,
    OCLiteralNodeTypeExpression,
    OCLiteralNodeTypeCollection,
    OCLiteralNodeTypeSeletor // TODO
};


@interface OCLiteralNode : OCNode

@end
