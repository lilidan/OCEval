//
//  JobCellTableViewCell.m
//  OCEvalDemo
//
//  Created by sgcy on 2018/11/27.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "JobCell.h"

@interface JobCell()
//
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *typeLabel;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UILabel *companyNameLabel;
@property (nonatomic,strong) UILabel *locationLabel;
@property (nonatomic,strong) UILabel *descriptionLabel;
@property (nonatomic,strong) UIImageView *companyLogoImgView;

@end

@implementation JobCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel = [[UILabel alloc] init];
    [self addSubview:self.titleLabel];
    
    self.typeLabel = [[UILabel alloc] init];
    [self addSubview:self.typeLabel];
    
    self.companyNameLabel = [[UILabel alloc] init];
    [self addSubview:self.companyNameLabel];
    
    self.locationLabel = [[UILabel alloc] init];
    [self addSubview:self.locationLabel];
    
    self.descriptionLabel = [[UILabel alloc] init];
    [self addSubview:self.descriptionLabel];
    
    self.timeLabel = [[UILabel alloc] init];
    [self addSubview:self.timeLabel];
    
    self.companyLogoImgView = [[UIImageView alloc] init];
    [self addSubview:self.companyLogoImgView];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

- (void)setModel:(JobModel *)model
{
    self.titleLabel.text = model.title;
    self.typeLabel.text = model.type;
    self.timeLabel.text = model.created_at;
    self.companyNameLabel.text = model.company;
    self.locationLabel.text = model.location;
    self.descriptionLabel.text = model.descriptionn;
}

@end
