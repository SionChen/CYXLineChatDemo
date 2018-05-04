//
//  CYXPointerView.m
//  CYXLineChatDemo
//
//  Created by 超级腕电商 on 2018/5/4.
//  Copyright © 2018年 超级腕电商. All rights reserved.
//

#import "CYXPointerView.h"
#import "UIView+Size.h"
#import "Masonry.h"
@interface CYXPointerView()
/*线*/
@property (nonatomic,strong) UIView *lineView;
/*icon*/
@property (nonatomic,strong) UIImageView *iconImageView;
@end
@implementation CYXPointerView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.lineView];
        [self addSubview:self.iconImageView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.mas_offset(0);
            make.bottom.equalTo(self).offset(-10);
            make.width.mas_equalTo(1);
        }];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self);
            make.width.and.height.mas_equalTo(20);
        }];
    }
    return self;
}
/*一根或者多根手指开始触摸view，系统会自动调用view的下面方法*/
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"手指触摸开始");
}
/*一根或者多根手指在view上移动，系统会自动调用view的下面方法（随着手指的移动，会持续调用该方法）*/
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"手指移动");
    //实现拖动
    //获取touch
    UITouch * touch = [touches anyObject];
    //获取当前点
    CGPoint curretPoint = [touch locationInView:self];
    //获取上一个点
    CGPoint prePoint = [touch previousLocationInView:self];
    //x变化
    CGFloat offsetX = curretPoint.x - prePoint.x;
    //y变化
    //CGFloat offsetY =curretPoint.y - prePoint.y;
    //相对于上一次位置的形变  make相对于原始位置
    CGPoint point = self.frame.origin;
    if (point.x+offsetX<=self.maxX&&point.x+offsetX>=self.minX) {
        //self.transform = CGAffineTransformTranslate(self.transform, offsetX, 0);
        self.left = self.left+offsetX;
    }else if (point.x+offsetX>self.maxX){
        self.left = self.maxX;
    }else if (point.x+offsetX<self.minX){
        self.left = self.minX;
    }
    self.centerXChanged(self.centerX);
}
#pragma mark ---G
-(UIView*)lineView{
    if(!_lineView){
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor yellowColor];
    }
    return _lineView;
}
-(UIImageView*)iconImageView{
    if(!_iconImageView){
        _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chartPoint"]];
    }
    return _iconImageView;
}
@end
