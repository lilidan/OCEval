//
//  OCFastCalculateNode.h
//  OCEval
//
//  Created by sgcy on 2018/11/26.
//

#import "OCToken.h"
#import "OCNode.h"

@interface OCFastCalculateNode : OCNode

@property (nonatomic,assign) OCTokenSubType subType;
@property (nonatomic,strong) NSString *assigneeName;

@end


