//
//  OCBlockNode.h
//  OCParser
//
//  Created by sgcy on 2018/11/19.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "OCNode.h"

@interface OCBlockNode : OCNode

@property (nonatomic,strong) NSMutableArray *typeNames;
@property (nonatomic,strong) NSMutableArray *paramNames;

@end

@interface OCBlockCallNode : OCNode


@end
