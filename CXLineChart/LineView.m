//
//  LineView.m
//  UIpage
//
//  Created by chenxiang on 2017/5/9.
//  Copyright © 2017年 chenxiang. All rights reserved.
//
#define UIColorWithRadix(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#import "LineView.h"

@interface LineView()
{
    CGFloat width;
    CGFloat height;
    CGFloat originX;
    CGFloat originY;
}
@property (nonatomic, strong) CAShapeLayer   * lineLayer;//折线
@property (nonatomic, strong) CAShapeLayer   * gradientShapeLayer;//渐变图层的ShapeLayer
@property (nonatomic, strong) CAGradientLayer  * gradientLayer;//渐变图层的Layer

@property (nonatomic, strong) NSMutableArray *timeArray;
@property (nonatomic, strong) NSArray *powerArray;
@end
@implementation LineView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self    = [super initWithFrame:frame]) {
        width   = frame.size.width;
        height  = frame.size.height;
        originX = 24;
        originY = 24;

        self.backgroundColor = [UIColor whiteColor];
        [self createXCoordinateAndYCoordinate];
        
    }
    return self;
}
//创建X轴Y轴
- (void)createXCoordinateAndYCoordinate{
    
    
    UIBezierPath * path = [[UIBezierPath alloc] init];
    path.lineCapStyle   = kCGLineCapRound;
    path.lineJoinStyle  = kCGLineJoinRound;
    
    [self createXLineWithPath:path AndContext:nil widthX:originX widthY:originY];
    [self createYLineWithPath:path AndContext:nil widthX:originX widthY:originY];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path          = path.CGPath;
    shapeLayer.frame         = self.bounds;
    shapeLayer.fillColor     = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor   = [UIColor blackColor].CGColor;
    [self.layer addSublayer:shapeLayer];
}

- (void)drawRect:(CGRect)rect {

        CGContextRef crf = UIGraphicsGetCurrentContext();

        [self createXLineWithPath:nil AndContext:crf widthX:originX widthY:originY];
        [self createYLineWithPath:nil AndContext:crf widthX:originX widthY:originY];
        
        CGContextStrokePath(crf);
    
}
//创建X轴
- (void)createXLineWithPath:(UIBezierPath *)path AndContext:(CGContextRef)crf widthX:(CGFloat)pointX widthY:(CGFloat)pointY{
    //画线用贝塞尔曲线,渲染文字用CGContextRef
    if (path != nil) {
        //起始点
        [path moveToPoint:CGPointMake(pointX, height - pointY)];
        //X轴
        [path addLineToPoint:CGPointMake(width - pointX, height - pointY)];
        //箭头上半部分
        [path addLineToPoint:CGPointMake( width - (pointX + 3), height - (pointY + 3))];
        //箭头下半部分
        [path moveToPoint:CGPointMake(width - pointX, height - pointY)];
        [path addLineToPoint:CGPointMake(width - (pointX + 3), height - (pointY - 3))];
        
    }
    //X轴刻度坐标,单位长度
    CGFloat XlineWidth = (width - 2 * pointX - 10) /  (self.timeArray.count);
    NSDictionary * strAtt = @{NSFontAttributeName:[UIFont systemFontOfSize:12]};
    for (int i = 0; i < self.timeArray.count; i++) {
        CGFloat x = i * XlineWidth + pointX;
        CGFloat y = height - pointY;
        NSString * time = self.timeArray[i];
        CGSize     size = [self sizeWithStr:time];
        //画线
        if (path != nil) {
            if (i > 0) {
                if (i % 4 == 0 || i == self.timeArray.count - 1) {
                    [path moveToPoint:CGPointMake(x, y)];
                    [path addLineToPoint:CGPointMake(x, y + 3)];
                }
            }
        }
        //渲染文字，只有4的倍数的位置才有文字
        if (crf != nil) {
            if (i % 4 == 0 || i == self.timeArray.count - 1) {
                [time drawInRect:CGRectMake(x - size.width/2, y + 3, size.width, size.height) withAttributes:strAtt];
            }
        }
        
    }
    //时间单位
    if (crf != nil) {
        CGSize size = [self sizeWithStr:@"H"];
        [@"H" drawInRect:CGRectMake(width - 20, height - pointY - size.height/2, size.width, size.height) withAttributes:strAtt];
    }
    
}
//创建Y轴
- (void)createYLineWithPath:(UIBezierPath *)path AndContext:(CGContextRef)crf widthX:(CGFloat)pointX widthY:(CGFloat)pointY{
    //起始点
    [path moveToPoint:CGPointMake(pointX, height - pointY)];
    //Y轴
    [path addLineToPoint:CGPointMake(pointX, pointY)];
    //箭头上半部分
    [path addLineToPoint:CGPointMake(pointX - 3, pointY + 3)];
    //箭头下半部分
    [path moveToPoint:CGPointMake(pointX, pointY)];
    [path addLineToPoint:CGPointMake(pointX + 3, pointY + 3)];
    //Y轴刻度,每个刻度的长度
    CGFloat YlineWidth    = (height - 2 * pointY - 10)/ self.powerArray.count;
    NSDictionary * strAtt = @{NSFontAttributeName:[UIFont systemFontOfSize:12]};
    
    for (int i = 0; i < self.powerArray.count; i++) {
        NSString *numStr = self.powerArray[i];
        CGSize   size    = [self sizeWithStr:numStr];
        CGFloat x = pointX;
        CGFloat y = height - (i + 1) * YlineWidth - 24;
        //画线
        if (path != nil) {
            [path moveToPoint:CGPointMake(x, y)];
            [path addLineToPoint:CGPointMake(x - 3, y)];
        }
        //渲染文字
        if (crf != nil) {
            [numStr drawInRect:CGRectMake(x - size.width - 4, y - size.height / 2, size.width, size.height) withAttributes:strAtt];
        }
    }
    if (crf != nil) {
        CGSize size = [self sizeWithStr:@"KW.H"];
        //4是单位距箭头的距离
        [@"KW.H" drawInRect:CGRectMake(pointX - size.width / 2, pointY - size.height - 4, size.width, size.height) withAttributes:strAtt];
    }
}

#pragma mark --- 自定义内部使用
//计算文字的大小
- (CGSize)sizeWithStr:(NSString *)str{
    CGSize size = [str sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    return size;
}
#pragma mark --- 数据懒加载
- (NSMutableArray *)timeArray{
    if (!_timeArray) {
        _timeArray = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < 24; i++) {
            NSString * str;
            if (i >= 10) {
                str = [NSString stringWithFormat:@"%d:00",i];
            }else{
                str = [NSString stringWithFormat:@"0%d:00",i];
            }
            [_timeArray addObject:str];
        }
    }
    return _timeArray;
}
- (NSArray *)powerArray{
    if (!_powerArray) {
        _powerArray = @[@"2",@"4",@"6",@"8",@"10"];
    }
    return _powerArray;
}

- (CAShapeLayer *)lineLayer{
    if (!_lineLayer) {
        _lineLayer = [CAShapeLayer layer];
        _lineLayer.zPosition      = 0;//设置图层层级
        _lineLayer.lineJoin       = @"round";
        _lineLayer.lineCap        = @"round";
        _lineLayer.frame          = self.bounds;
        _lineLayer.fillColor      = [UIColor clearColor].CGColor;
        _lineLayer.strokeColor    = UIColorWithRadix(0x3d98ff, 1).CGColor;
        [self.layer addSublayer:_lineLayer];
    }
    return _lineLayer;
}
- (CAShapeLayer *)gradientShapeLayer{
    if (!_gradientShapeLayer) {
        _gradientShapeLayer = [CAShapeLayer layer];
        _gradientShapeLayer.frame         = self.bounds;
        _gradientShapeLayer.fillColor     = [UIColor blueColor].CGColor;
        _gradientShapeLayer.strokeColor   = [UIColor yellowColor].CGColor;
    }
    return _gradientShapeLayer;
}
- (CAGradientLayer *)gradientLayer{
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = self.bounds;
        //    gradientLayer.colors = @[(__bridge id)UIColorWithRadix(0x3D98FF, 0.5).CGColor,(__bridge id)UIColorWithRadix(0xC6E0FD, 0.5).CGColor];
        
        _gradientLayer.colors = @[(__bridge id)UIColorWithRadix(0x3D98FF, 0.1).CGColor,
                                 (__bridge id)UIColorWithRadix(0x3D98FF, 0.8).CGColor,
                                 (__bridge id)UIColorWithRadix(0x3D98FF, 0.6).CGColor,
                                 (__bridge id)UIColorWithRadix(0x3D98FF, 0.4).CGColor,
                                 (__bridge id)UIColorWithRadix(0x3D98FF, 0.2).CGColor,
                                 (__bridge id)UIColorWithRadix(0x3D98FF, 0.0).CGColor,
                                 ];
        _gradientLayer.startPoint = CGPointMake(0, 0);
        _gradientLayer.endPoint   = CGPointMake(1, 1);
        
        [self.layer addSublayer:_gradientLayer];
    }
    return _gradientLayer;
}

#pragma mark  /*********************************************************************/
#pragma mark ---------- 分割线以上为内部视图的实现，以下为外部开放的刷新视图的接口
- (void)loadData{

    //path是折线图路径，newPath是渐变色背景的路径
    UIBezierPath *path     = [[UIBezierPath alloc] init];
    UIBezierPath *newPath  = [[UIBezierPath alloc] init];
    
    CGFloat lastPointX = 0.0;
    CGFloat lastPointY = 0.0;
    //X轴Y轴刻度的单位长度
    CGFloat xLineWidth = (width - 2  * originX - 10) / 24;
    CGFloat yLineWidth = (height - 2 * originY - 10) / 10;
    for (int i = 0; i < self.dataArray.count; i++) {
        CGFloat x = i * xLineWidth + 24;
        CGFloat y = height - 24 - yLineWidth * [self.dataArray[i] floatValue];
        
        if (i == 0) {
            [path moveToPoint:CGPointMake(x, y)];
            [newPath moveToPoint:CGPointMake(x + 1, y)];
        }
        [path addLineToPoint:CGPointMake(x, y)];
        [newPath addLineToPoint:CGPointMake(x, y)];
        
        //记录最后一个点的坐标，定义渐变色背景的范围
        if (i == self.dataArray.count - 1) {
            lastPointX = x;
            lastPointY = y;
        }
    }
    [newPath addLineToPoint:CGPointMake(lastPointX , height - originX - 1)];
    [newPath addLineToPoint:CGPointMake(originX    , height - originX - 1)];
    [newPath closePath];
    
    self.lineLayer.path           = path.CGPath;
    self.gradientShapeLayer.path  = newPath.CGPath;
    
    self.gradientLayer.mask       = self.gradientShapeLayer;
    
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration       = 1;
    animation.repeatCount    = 1;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fromValue      = [NSNumber numberWithFloat:0.0f];
    
    animation.toValue        = [NSNumber numberWithFloat:1.0f];
    
    [self.lineLayer addAnimation:animation forKey:@"strokeEndAnimation"];
    
    
}
@end
