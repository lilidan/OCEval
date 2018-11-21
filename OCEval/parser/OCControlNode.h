//
//  OCControlNode.h
//  OCParser
//
//  Created by sgcy on 2018/11/15.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCNode.h"

typedef NS_ENUM(NSUInteger, OCControlNodeType) {
    OCControlNodeTypeIfElse = 0,
    OCControlNodeTypeDoWhile = 1,
    OCControlNodeTypeForIn = 2,
    OCControlNodeTypeSwitchCase = 3,
};

@interface OCControlNode : OCNode



@end
