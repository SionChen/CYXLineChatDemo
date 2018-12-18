//
//  CYXLineChartView.m
//  CYXLineChatDemo
//
//  Created by 超级腕电商 on 2018/5/4.
//  Copyright © 2018年 超级腕电商. All rights reserved.
//

#import "CYXLineChartView.h"
#import "UIView+Size.h"
#import "CYXPointerView.h"

static int xCount = 4;  // x轴格子数
static int yCount = 3;//y轴线的个数
static CGRect myFrame; //坐标
#define kDrawMarginTop 20
#define kDrawMarginLeft 30
#define kDrawMarginBottom 37
#define kDrawMarginRight 10

#define kZeroMarginLeft 40
#define kZeroMarginRight 20
@interface CYXLineChartView ()<CAAnimationDelegate>
/*指针*/
@property (nonatomic,strong) CYXPointerView *pointerView;
/*指针说明label*/
@property (nonatomic,strong) UILabel *explainLabel;
/*渐变 填充*/
@property (nonatomic,strong) CAGradientLayer *gradientLayer;
@end
@implementation CYXLineChartView{
    /*当前月*/
    NSInteger _currentMonth;
    /*当前月总天数*/
    NSInteger _currentMonthTotalDays;
    /*当前天*/
    NSInteger _currentDay;
    /*最大Y值*/
    CGFloat _maxYValue;
    /*所有点的坐标集合*/
    NSMutableArray * _pointList;
}

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor cyanColor];
        
        myFrame = frame;
    }
    return self;
}
#pragma mark ---画表
-(void)drawChartWithMaxYValue:(CGFloat)maxYValue{
    if (maxYValue<=0||[self.yValues count]==0) {
        return;
    }
    _maxYValue = maxYValue;
    NSArray *layers = [self.layer.sublayers mutableCopy];
    for (CAShapeLayer *layer in layers) {
        [layer removeFromSuperlayer];
    }
    
    //画三条线
    [self drawXYLine];
    //添加y轴三个label
    [self drawYLabelsWithMaxYValue:maxYValue];
    //画X轴刻度和label
    [self drawXLineAndLabels];
    //画折线
    [self drawLine];
    //[self drawGradient];
    [self addSubview:self.pointerView];
    [self addSubview:self.explainLabel];
}
#pragma mark ---画折线
-(void)drawLine{
    if ([self.yValues count]>_currentMonthTotalDays) {
        NSLog(@"******************数据和当前月份不一致******************");
        return;
    }
    _pointList = [NSMutableArray new];
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat yTotalDistance =CGRectGetHeight(myFrame)-kDrawMarginBottom-kDrawMarginTop;
    CGFloat firstY = [[self.yValues firstObject] floatValue];
    CGPoint firstPoint =CGPointMake(kZeroMarginLeft, yTotalDistance - (firstY/_maxYValue*yTotalDistance)+kDrawMarginTop);
    [path moveToPoint:firstPoint];
    [_pointList addObject:[NSValue valueWithCGPoint:firstPoint]];
    
    CGFloat  xTotalDistance = CGRectGetWidth(myFrame)-kZeroMarginLeft-kZeroMarginRight;
    CGFloat  xUnitMargin = xTotalDistance/(_currentMonthTotalDays-1);
    for (int i =1; i<[self.yValues count]; i++) {
        CGFloat yValue =[self.yValues[i] floatValue];
        CGPoint point = CGPointMake(kZeroMarginLeft+xUnitMargin*i, yTotalDistance - (yValue/_maxYValue*yTotalDistance)+kDrawMarginTop);
        [path addLineToPoint:point];
        if (i == [self.yValues count]-1) {//刻度尺默认选择当前 日期
            self.pointerView.centerX =point.x;
            self.pointerView.maxX = point.x+self.pointerView.width/2;
        }
        [_pointList addObject:[NSValue valueWithCGPoint:point]];
    }
    [self changeExplainLabelWithCenterX:self.pointerView.centerX];
    self.pointerView.minX = kZeroMarginLeft-self.pointerView.width/2;
    self.explainLabel.top =27;
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.path = path.CGPath;
    layer.strokeColor = [UIColor redColor].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineWidth = 1;
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1.5;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.autoreverses = NO;
    pathAnimation.delegate = self;
    [layer addAnimation:pathAnimation forKey:@"lineLayerAnimation"];
    layer.strokeEnd = 1.0;
    [self.layer addSublayer:layer];
}
#pragma mark ---添加Y轴文字
-(void)drawYLabelsWithMaxYValue:(CGFloat)maxYValue{
    
    NSMutableArray * yValueList= [NSMutableArray new];
    //y值平均
    CGFloat yUnitValue = maxYValue/(yCount-1);
    for (int i=yCount-1; i>=0; i--) {
        [yValueList addObject:@(i*yUnitValue)];
    }
    CGFloat yUnitDistance = (CGRectGetHeight(myFrame)-kDrawMarginTop-kDrawMarginBottom)/(yCount-1);
    for (int i =0; i<yCount; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, yUnitDistance*i+kDrawMarginTop, kDrawMarginLeft, 12)];
        label.centerY = yUnitDistance*i+kDrawMarginTop;
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:12];
        //lbl.backgroundColor = [UIColor brownColor];
        label.textAlignment = NSTextAlignmentCenter;
        CGFloat yValue = [yValueList[i] floatValue];
        NSInteger yK = yValue/1000;
        label.text = [NSString stringWithFormat:@"%ldK",yK];
        [self addSubview:label];
    }
}
#pragma mark ---画X轴刻度和label
-(void)drawXLineAndLabels{
    //先计算当前月份和当前月的总天数
    [self setCurrentDaysAndMoth];
    
    NSLog(@"%02ld",_currentMonth);
    NSLog(@"%02ld",_currentMonthTotalDays);
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat  xUnitValue = 10;
    CGFloat  xTotalDistance = CGRectGetWidth(myFrame)-kZeroMarginLeft-kZeroMarginRight;
    CGFloat  xUnitMargin = xUnitValue/(_currentMonthTotalDays-1) *xTotalDistance;
    
    NSInteger day = 1;
    CGFloat centerX;
    for (int i=0; i<xCount; i++) {
        if (i==xCount-2) {//倒数第二个刻度
            [path moveToPoint:CGPointMake(kZeroMarginLeft+xTotalDistance-xUnitMargin, CGRectGetHeight(myFrame)-kDrawMarginBottom)];
            [path addLineToPoint:CGPointMake(kZeroMarginLeft+xTotalDistance-xUnitMargin, CGRectGetHeight(myFrame)-kDrawMarginBottom+8)];
            day = _currentMonthTotalDays-10;
            centerX = kZeroMarginLeft+xTotalDistance-xUnitMargin;
        }else if (i==xCount-1){//倒数第一个刻度
            [path moveToPoint:CGPointMake(kZeroMarginLeft+xTotalDistance, CGRectGetHeight(myFrame)-kDrawMarginBottom)];
            [path addLineToPoint:CGPointMake(kZeroMarginLeft+xTotalDistance, CGRectGetHeight(myFrame)-kDrawMarginBottom+8)];
            day = _currentMonthTotalDays;
            centerX = kZeroMarginLeft+xTotalDistance;
        }else{//其余刻度
            [path moveToPoint:CGPointMake(kZeroMarginLeft+i*xUnitMargin, CGRectGetHeight(myFrame)-kDrawMarginBottom)];
            [path addLineToPoint:CGPointMake(kZeroMarginLeft+i*xUnitMargin, CGRectGetHeight(myFrame)-kDrawMarginBottom+8)];
            if (i==0) {
                day = 1;
            }else{
              day = day+xUnitValue*i;
            }
            centerX = kZeroMarginLeft+i*xUnitMargin;
        }
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor grayColor];
        label.font = [UIFont systemFontOfSize:12];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"%02ld-%02ld",_currentMonth,day];
        [label sizeToFit];
        label.centerX = centerX;
        label.bottom = CGRectGetHeight(myFrame)-10;
        [self addSubview:label];
    }
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.path = path.CGPath;
    layer.strokeColor = [UIColor brownColor].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineWidth = 0.5;
    [self.layer addSublayer:layer];
}
#pragma mark - 画XY线
- (void)drawXYLine{
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    //y单位坐标距离
    CGFloat yUnitDistance = (CGRectGetHeight(myFrame)-kDrawMarginTop-kDrawMarginBottom)/(yCount-1);
    //从上到下
    for (int i =0; i<yCount; i++) {
        [path moveToPoint:CGPointMake(kDrawMarginLeft, yUnitDistance*i+kDrawMarginTop)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(myFrame)-kDrawMarginRight, yUnitDistance*i+kDrawMarginTop)];
    }

    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.path = path.CGPath;
    layer.strokeColor = [UIColor brownColor].CGColor;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineWidth = 0.5;
    [self.layer addSublayer:layer];
    self.pointerView.frame = CGRectMake(0, kDrawMarginTop, 20, CGRectGetHeight(myFrame)-kDrawMarginTop-kDrawMarginBottom+10);
}
-(void)drawGradient{
    CGFloat  xTotalDistance = CGRectGetWidth(myFrame)-kZeroMarginLeft-kZeroMarginRight;
    CGFloat  xUnitMargin = xTotalDistance/(_currentMonthTotalDays-1);
    //////m填充
    UIBezierPath * gradientPath = [UIBezierPath bezierPath];
    [gradientPath moveToPoint:CGPointMake(kZeroMarginLeft+0*xUnitMargin, CGRectGetHeight(myFrame)-kDrawMarginBottom)];//第一个点
    /////
    for (NSValue * value in _pointList) {
        CGPoint point = [value CGPointValue];
        [gradientPath addLineToPoint:point];
        if (value == [_pointList lastObject]) {
            //蒙版最后一个点
            [gradientPath addLineToPoint:CGPointMake(point.x, CGRectGetHeight(myFrame)-kDrawMarginBottom)];
        }
    }
    
    CAShapeLayer *arc = [CAShapeLayer layer];
    arc.path = gradientPath.CGPath;
    
    
    self.gradientLayer.mask = arc;
    self.gradientLayer.frame = self.bounds;
    [self.layer addSublayer:self.gradientLayer];
    [self bringSubviewToFront:self.pointerView];
    [self bringSubviewToFront:self.explainLabel];
}
#pragma mark ---CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self drawGradient];
}
#pragma mark ---获取当前月份的总天数
- (void)setCurrentDaysAndMoth
{
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]; // 指定日历的算法 NSGregorianCalendar - ios 8
    NSDate * currentDate = [NSDate date];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay  //NSDayCalendarUnit - ios 8
                                   inUnit: NSCalendarUnitMonth //NSMonthCalendarUnit - ios 8
                                  forDate:currentDate];
    // 定义一个时间字段的旗标，指定将会获取指定年、月、日、时、分、秒的信息
    unsigned unitFlags = NSCalendarUnitYear |
    NSCalendarUnitMonth |  NSCalendarUnitDay |
    NSCalendarUnitHour |  NSCalendarUnitMinute |
    NSCalendarUnitSecond | NSCalendarUnitWeekday;
    // 获取不同时间字段的信息
    NSDateComponents* comp = [calendar components: unitFlags
                                          fromDate:currentDate];
    _currentMonth = comp.month;
    _currentDay = comp.day;
    _currentMonthTotalDays = range.length;
}
/*一根或者多根手指开始触摸view，系统会自动调用view的下面方法*/
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //获取touch
    UITouch * touch = [touches anyObject];
    CGPoint curretPoint = [touch locationInView:self];
    [self dealWithLocationPoint:curretPoint];
    
}
/*一根或者多根手指在view上移动，系统会自动调用view的下面方法（随着手指的移动，会持续调用该方法）*/
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"手指移动");
    //获取touch
    UITouch * touch = [touches anyObject];
    //获取当前点
    CGPoint curretPoint = [touch locationInView:self];
    [self dealWithLocationPoint:curretPoint];
}
-(void)dealWithLocationPoint:(CGPoint )currentPoint{
    NSLog(@"%f",currentPoint.x);
    CGFloat  availableX = 0;
    if (currentPoint.x<=self.pointerView.maxX-self.pointerView.width/2&&currentPoint.x>=self.pointerView.minX+self.pointerView.width/2) {
        //self.pointerView.centerX = curretPoint.x;
        availableX =currentPoint.x;
    }else if (currentPoint.x>self.pointerView.maxX-self.pointerView.width/2){
        //self.pointerView.left = self.pointerView.minX;
        //availableX = self.pointerView.minX;
        availableX = self.pointerView.maxX-self.pointerView.width/2;
    }else if (currentPoint.x<self.pointerView.minX+self.pointerView.width/2){
        //self.pointerView.left = self.pointerView.maxX;
        //availableX = self.pointerView.maxX;
        availableX = self.pointerView.minX+self.pointerView.width/2;
    }
    [self changeExplainLabelWithCenterX:availableX];
}
-(void)changeExplainLabelWithCenterX:(CGFloat)centerX{
    for (int i=0; i<[_pointList count]; i++) {
        NSValue * value =_pointList[i];
        CGPoint point = [value CGPointValue];
        NSLog(@"%d",i);
        if (point.x>centerX&&i>0) {
            CGFloat offsetxCurrent = point.x-centerX;
            NSValue * value2 =_pointList[i-1];
            CGPoint point2 = [value2 CGPointValue];
            CGFloat offsetxNext = centerX-point2.x;
            NSLog(@"centerX:%f",centerX);
            if (offsetxCurrent<=offsetxNext) {
                NSLog(@"point:%f",point.x);
                self.explainLabel.text = [NSString stringWithFormat:@"%@",self.yValues[i]];
                self.pointerView.centerX = point.x;
            }else{
                NSLog(@"point2:%f",point2.x);
                self.explainLabel.text = [NSString stringWithFormat:@"%@",self.yValues[i-1]];
                self.pointerView.centerX = point2.x;
            }
            break;
        }else if (point.x==centerX){
            self.explainLabel.text = [NSString stringWithFormat:@"%@",self.yValues[i]];
            self.pointerView.centerX = point.x;
        }
    }
    if (centerX<CGRectGetWidth(myFrame)/2) {
        self.explainLabel.left = self.pointerView.centerX+7;
    }else{
        self.explainLabel.right = self.pointerView.centerX-7;
    }
}
#pragma mark ---G
-(CYXPointerView*)pointerView{
    if(!_pointerView){
        _pointerView = [[CYXPointerView alloc] init];
        __weak typeof(self) _self = self;
        _pointerView.centerXChanged = ^(CGFloat centerX) {
            [_self changeExplainLabelWithCenterX:centerX];
        };
    }
    return _pointerView;
}
-(UILabel*)explainLabel{
    if(!_explainLabel){
        _explainLabel = [[UILabel alloc] init];
        _explainLabel.textColor = [UIColor whiteColor];
        _explainLabel.numberOfLines = 0;
        _explainLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        _explainLabel.layer.masksToBounds = YES;
        _explainLabel.layer.cornerRadius = 2;
        _explainLabel.font = [UIFont systemFontOfSize:12];
        _explainLabel.size = CGSizeMake(70, 60);
        _explainLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _explainLabel;
}
-(CAGradientLayer*)gradientLayer{
    if(!_gradientLayer){
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.colors = @[(__bridge id)[UIColor blueColor].CGColor,(__bridge id)[UIColor whiteColor].CGColor];
        _gradientLayer.startPoint = CGPointMake(0, 0);
        _gradientLayer.endPoint = CGPointMake(0, 1);
    }
    return _gradientLayer;
}
@end
