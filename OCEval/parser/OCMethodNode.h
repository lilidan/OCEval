//
//  OCMethodNode.h
//  OCParser
//
//  Created by sgcy on 2018/11/15.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCNode.h"

@class OCReturnNode;

@interface OCMethodNode : OCNode

@property (nonatomic,strong) OCNode *caller;
@property (nonatomic,strong) NSMutableString *selectorName;
@property (nonatomic,assign) BOOL isSuper;

@end

@interface OCSubscriptMethodNode : OCMethodNode

@property (nonatomic,assign) BOOL isSetter;

@end

@interface OCLiteralMethodNode : OCNode


@end

@interface OCPointSetterNode : OCNode

@end
