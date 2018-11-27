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
//@property (nonatomic,strong) UILabel *titleLabel;
//@property (nonatomic,strong) UILabel *typeLabel;
//@property (nonatomic,strong) UILabel *timeLabel;
//@property (nonatomic,strong) UILabel *companyName;
//@property (nonatomic,strong) UILabel *locationLabel;
//@property (nonatomic,strong) UILabel *descriptionLabel;
//@property (nonatomic,strong) UIImageView *companyLogo;

@end

@implementation JobCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)setModel:(JobModel *)model
{
//    self.titleLabel.text = model.title;
//    self.typeLabel.text = model.type;
//    self.timeLabel.text = model.created_at;
//    self.companyName.text = model.company;
//    self.locationLabel.text = model.location;
//
    
    self.textLabel.text = model.title;
//    NSAttributedString *attributedString = [[NSAttributedString alloc]
//                                            initWithData: [model.descriptionn dataUsingEncoding:NSUnicodeStringEncoding]
//                                            options: @{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
//                                            documentAttributes: nil
//                                            error: nil
//                                            ];
    self.detailTextLabel.text = model.descriptionn;
    
}

@end
