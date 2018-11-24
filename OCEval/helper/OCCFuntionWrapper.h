//
//  OCCFuntionWrapper.h
//  OCParser
//
//  Created by sgcy on 2018/11/21.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#if TARGET_OS_IPHONE
@import UIKit;
#else
@import AppKit;
#endif

@interface OCCFuntionWrapper : NSObject

+ (id)callCFunction:(NSString *)funcName arguments:(NSArray *)arguments;

@end
