//
//  ViewController.m
//  CYXLineChatDemo
//
//  Created by 超级腕电商 on 2018/5/4.
//  Copyright © 2018年 超级腕电商. All rights reserved.
//

#import "ViewController.h"
#import "CYXLineChartView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CYXLineChartView *chartView = [[CYXLineChartView alloc]initWithFrame:CGRectMake(10, 160, CGRectGetWidth([UIScreen mainScreen].bounds) - 20, 240)];
    [self.view addSubview:chartView];
    chartView.yValues = @[@(2000),@(3000),@(4000),@(5000),@(5500),@(2000),@(4000),@(3300),@(3400),@(2000),@(2000),@(2000),@(2000),@(2000),@(2000),@(2000),@(2000),@(5500),@(1100),@(2000),@(2000),@(2000),@(2000),@(3400),@(3400),@(4300),@(2000),@(2300)];
    [chartView drawChartWithMaxYValue:6000];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
