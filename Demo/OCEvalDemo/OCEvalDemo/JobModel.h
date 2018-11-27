//
//  JobModel.h
//  OCEvalDemo
//
//  Created by sgcy on 2018/11/27.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JobModel : NSObject

@property (nonatomic,copy) NSString *idd;
@property (nonatomic,copy) NSString *type;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *created_at;
@property (nonatomic,copy) NSString *company;
@property (nonatomic,copy) NSString *company_url;
@property (nonatomic,copy) NSString *location;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *descriptionn;
@property (nonatomic,copy) NSString *how_to_apply;
@property (nonatomic,copy) NSString *company_logo;


@end
