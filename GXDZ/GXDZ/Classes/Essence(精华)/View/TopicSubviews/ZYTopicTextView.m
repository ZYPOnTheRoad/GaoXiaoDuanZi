//
//  ZYTopicTextView.m
//  GXDZ
//
//  Created by ZYP OnTheRoad on 2020/6/20.
//  Copyright © 2020 ZYP OnTheRoad. All rights reserved.
//头像, 名称, 发帖时间, 更多按钮, 正文

#import "ZYTopicTextView.h"
#import "ZYTopicItem.h"
#import "NSDate+ZYDate.h"

@interface ZYTopicTextView ()
/// 发帖时间
@property (nonatomic ,strong) UILabel *timeLabel;
/// 名称
@property (nonatomic ,strong) UILabel *nameLabel;
/// 正文
@property (nonatomic ,strong) UILabel *textLabel;
/// 更多按钮
@property (nonatomic ,strong) UIButton *moreButton;
/// 头像
@property (nonatomic ,strong) UIImageView *iconView;

@end

@implementation ZYTopicTextView

#pragma mark- 懒加载
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
    } return _nameLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
         _timeLabel.textColor = UIColor.grayColor;
        _timeLabel.font = [UIFont systemFontOfSize:13];
    } return _timeLabel;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:15];
        _textLabel.numberOfLines = 0;
       
    } return _textLabel;
}

- (UIButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_moreButton setTitle:@"•••" forState:UIControlStateNormal];
        [_moreButton setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
        [_moreButton setTitleColor:UIColor.redColor forState:UIControlStateHighlighted];
        [_moreButton addTarget:self action:@selector(moreButtonClick) forControlEvents:UIControlEventTouchUpInside];
    } return _moreButton;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
    } return _iconView;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //iconView 
        [self addSubview:self.iconView];
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@40);
            make.left.top.equalTo(self);
        }];
       //nameLabel
        [self addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconView.mas_right).offset(kTOPIC_MARGIN);
            make.top.equalTo(self.iconView);
        }];
        //timeLabel
        [self addSubview:self.timeLabel];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconView.mas_right).offset(kTOPIC_MARGIN);
            make.bottom.equalTo(self.iconView);
        }];
        //textLabel
        [self addSubview:self.textLabel];
        [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.iconView.mas_bottom).offset(kTOPIC_MARGIN);
            make.right.left.bottom.equalTo(self);
        
        }];
        //rightButton
        [self addSubview:self.moreButton];
        [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.iconView);
            make.right.mas_equalTo(-kTOPIC_MARGIN);
        }];
    }  return self;
}

#pragma mark - 按钮点击
- (void)moreButtonClick {
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:0];
    
    UIAlertAction *cance = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *report = [UIAlertAction actionWithTitle:@"举报" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    
    UIAlertAction *collect = [UIAlertAction actionWithTitle:@"收藏" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
    }];
    
    [alertVc addAction:cance];
    [alertVc addAction:report];
    [alertVc addAction:collect];
    
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:alertVc animated:YES completion:nil];
}

- (void)setTopicItem:(ZYTopicItem *)topicItem {
    
    _topicItem = topicItem;
    
    [self setUpIcon:topicItem];
    [self setUpTime:topicItem];
    
    _nameLabel.text = topicItem.name;
    _textLabel.text = topicItem.text;
}

#pragma mark - 加载头像
- (void)setUpIcon:(ZYTopicItem *)topicItem {
    
    [_iconView sd_setImageWithURL:[NSURL URLWithString:topicItem.icon] placeholderImage:[UIImage imageNamed:@"defaultUserIcon"]  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
         //处理 CGContextAddPath: invalid context 0x0 的问题
        if(image.size.height <= 0 || image.size.width <= 0) return;
        
        CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
        //1 开启位图上下文
        UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
        
        //2 设置裁剪区域
        //2.1 创建一个圆形路径
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
        //2.2将圆形路径设置为裁剪区域
        [path addClip];
        
        //3 把图片绘制到上下文当中
        [image drawAtPoint:CGPointZero];
        
        //4 从上下文当中生成一张图片
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        //5 关闭上下文
        UIGraphicsEndImageContext();
        
        self.iconView.image = image;
    }];
}

#pragma mark - 设置发帖时间
- (void)setUpTime:(ZYTopicItem *)topicItem {
    //创建时间格式器
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //设置时间格式器
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    //发帖时间字符串转换成发布时间
    NSDate *publishDate = [formatter dateFromString:topicItem.time];
    
    //判断是否今年
    if (!publishDate.isThisYear) {//非今年
        _timeLabel.text = topicItem.time;
        return;
    }
    
    //今年
    //判断是否昨天以前(非今天,非昨天)
    if (!(publishDate.isYesterday || publishDate.isToday)) {//昨天以前
        formatter.dateFormat = @"MM-dd HH:mm";
        _timeLabel.text = [formatter stringFromDate:publishDate];
        return;
    }
    
    
    //判断是否昨天
    if (publishDate.isYesterday) {//昨天
        formatter.dateFormat = @"昨天 HH:mm";
        _timeLabel.text = [formatter stringFromDate:publishDate];
        return;
    }
    
    //今天
    //获取发帖时间与现在的时差
    NSDateComponents *difference = [publishDate timeDistanceWithNow];
    
    if (difference.hour >= 1) {//一小时前
        _timeLabel.text = [NSString stringWithFormat:@"%li小时前",difference.hour];
    }
    else if (difference.minute >= 1) {//一分钟前
        _timeLabel.text = [NSString stringWithFormat:@"%li分钟前",difference.minute];
    }
    else {
        _timeLabel.text = @"刚刚";
    }
}
@end
