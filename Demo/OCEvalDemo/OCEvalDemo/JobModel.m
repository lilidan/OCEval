//
//  JobModel.m
//  OCEvalDemo
//
//  Created by sgcy on 2018/11/27.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "JobModel.h"

@implementation JobModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) {
        [self setValue:value forKey:@"idd"];
    }else if ([key isEqualToString:@"description"]) {
        [self setValue:value forKey:@"descriptionn"];
    }else{
        [super setValue:value forUndefinedKey:key];
    }
}

@end
