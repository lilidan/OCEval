//
//  OCReturnNode.h
//  OCParser
//
//  Created by sgcy on 2018/11/15.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCNode.h"

typedef NS_OPTIONS(NSUInteger, OCReturnNodeType) {
    OCReturnNodeTypeSimple = 1 << 0,
    OCReturnNodeTypeExpression = 1 << 1,
    OCReturnNodeTypeNSPredicate = 1 << 2,
};

@interface OCReturnNode : OCNode

@end
