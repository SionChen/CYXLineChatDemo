//
//  CYXLineChartView.h
//  CYXLineChatDemo
//
//  Created by 超级腕电商 on 2018/5/4.
//  Copyright © 2018年 超级腕电商. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYXLineChartView : UIView
/*y值列表*/
@property (nonatomic,strong) NSArray *yValues;
/*画线开始*/
-(void)drawChartWithMaxYValue:(CGFloat)maxYValue;
@end
