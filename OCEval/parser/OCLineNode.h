//
//  OCLineNode.h
//  OCParser
//
//  Created by sgcy on 2018/11/15.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCNode.h"

typedef NS_ENUM(NSUInteger, OCLineNodeType) {
    OCLineNodeTypeCallMethod = 0,
    OCLineNodeTypeAssign,
    OCLineNodeTypeAssignPoint,
    OCLineNodeTypeReturn,
};

@interface OCLineNode : OCNode

@property (nonatomic,assign) OCLineNodeType type;
@property (nonatomic,strong) NSString *assigneeName;

@end
