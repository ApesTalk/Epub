//
//  YLBookShelfCell.m
//  YLEpubReader
//
//  Created by ApesTalk on 2018/4/15.
//  Copyright © 2018年 https://github.com/ApesTalk. All rights reserved.
//

#import "YLBookShelfCell.h"
#import "Masonry.h"
#import "YLEpub.h"

@interface YLBookShelfCell ()
@property (nonatomic, strong, readwrite) UIImageView *coverImg;
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation YLBookShelfCell
- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        _coverImg = [[UIImageView alloc]init];
        _coverImg.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_coverImg];
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.backgroundColor = [UIColor whiteColor];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.font = [UIFont systemFontOfSize:15];
        _nameLabel.numberOfLines = 2;
        [self.contentView addSubview:_nameLabel];
        
        [_coverImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@([[self class]width])).priorityHigh();
            make.height.equalTo(@([[self class]width] * 4.0 / 3.0)).priorityHigh();
            make.top.equalTo(self.contentView).offset(10);
            make.left.right.equalTo(self.contentView);
        }];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@40).priorityHigh();
            make.top.equalTo(_coverImg.mas_bottom);
            make.left.right.equalTo(_coverImg);
            make.bottom.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)loadWithEpub:(YLEpub *)epub;
{
    _coverImg.image = [UIImage imageWithContentsOfFile:[epub coverPath]];
    _nameLabel.text = epub.title;
}

+ (CGFloat)width
{
    return 80 * [UIScreen mainScreen].bounds.size.width / 320.f;
}

+ (CGFloat)height
{
    return [self width] * 4.0 / 3.0 + 40 + 20;
}
@end
