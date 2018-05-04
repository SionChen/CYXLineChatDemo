//
//  CYXPointerView.h
//  CYXLineChatDemo
//
//  Created by 超级腕电商 on 2018/5/4.
//  Copyright © 2018年 超级腕电商. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CYXPointerView : UIView
@property (nonatomic,assign) CGFloat minX;
@property (nonatomic,assign) CGFloat maxX;
/*当指针centerx发生变化的时候*/
@property (nonatomic,strong) void(^centerXChanged)(CGFloat centerX);
@end
