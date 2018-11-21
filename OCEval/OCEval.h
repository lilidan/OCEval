//
//  OCEval.h
//  OCParser
//
//  Created by sgcy on 2018/11/21.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCLexer.h"
#import "OCToken.h"
#import "OCScopeNode.h"
#import "OCTokenReader.h"

@interface OCEval : NSObject

+ (id)eval:(NSString *)str;

+ (id)eval:(NSString *)str context:(NSMutableDictionary *)context;

@end
