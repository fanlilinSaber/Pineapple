//
//  PWDrawView.m
//  Pineapple iOS Example
//
//  Created by 范李林 on 2017/11/3.
//

#import "PWDrawView.h"

@interface PWDrawView () <CAAnimationDelegate>
/*&* <##>*/
@property (nonatomic, strong) NSMutableArray *drawPaths;
/*&* <##>*/
@property (nonatomic, strong) NSMutableArray *drawLayers;
/*&* timer*/
@property (nonatomic, strong) NSTimer *timer;

/*&* <##>*/
@property (nonatomic, strong) CAShapeLayer *drawLayer;

@end

@implementation PWDrawView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.lineWidth = 3.0f;
        self.strokeColor = [UIColor redColor];
        self.interval = 3.0;
        self.isClearAnim = NO;
        
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.backgroundColor = [UIColor clearColor].CGColor;
//        layer.path = path.CGPath;
        layer.lineWidth = self.lineWidth;
        layer.strokeColor = self.strokeColor.CGColor;
        layer.miterLimit = 2.;
        layer.lineDashPhase = 10;
        layer.lineDashPattern = @[@1,@0];
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.fillRule = kCAFillRuleEvenOdd;
        layer.lineCap = kCALineCapRound;
        layer.lineJoin = kCALineJoinRound;
        [self.layer addSublayer:layer];
        self.drawLayer = layer;
    }
    return self;
}

#pragma mark -
- (void)clearPath{
    if (self.isClearAnim) {
        for (CAShapeLayer *layer in self.drawLayers) {
            CABasicAnimation *aniStart = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
            aniStart.fromValue  = [NSNumber numberWithFloat:0.f];
            aniStart.toValue = [NSNumber numberWithFloat:1.f];
            aniStart.duration  = 1.0;
            aniStart.autoreverses = NO;
            aniStart.delegate = self;
            aniStart.removedOnCompletion = NO;
            aniStart.fillMode = kCAFillModeForwards;
            [layer addAnimation:aniStart forKey:@"strokeStart"];
        }
    }else{
        for (CAShapeLayer *layer in self.drawLayers) {
            [layer removeFromSuperlayer];
        }
        self.drawLayers = nil;
        [self.drawPaths removeAllObjects];
    }
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    for (CAShapeLayer *layer in self.drawLayers) {
        [layer removeFromSuperlayer];
    }
    self.drawLayers = nil;
    [self.drawPaths removeAllObjects];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self stopTimer];
    UIBezierPath *path;
    if (self.drawPaths.count) {
        path = self.drawPaths.lastObject;
    }else{
        path = [UIBezierPath bezierPath];
    }
//    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:[[touches anyObject] locationInView:self]];
    self.drawLayer.path = path.CGPath;
//    CAShapeLayer *layer = [CAShapeLayer layer];
//    layer.backgroundColor = [UIColor clearColor].CGColor;
//    layer.path = path.CGPath;
//    layer.lineWidth = self.lineWidth;
//    layer.strokeColor = self.strokeColor.CGColor;
//    layer.miterLimit = 2.;
//    layer.lineDashPhase = 10;
//    layer.lineDashPattern = @[@1,@0];
//    layer.fillColor = [UIColor clearColor].CGColor;
//    layer.fillRule = kCAFillRuleEvenOdd;
//    layer.lineCap = kCALineCapRound;
//    layer.lineJoin = kCALineJoinRound;
    
//    [self.layer addSublayer:layer];
    [self.drawPaths addObject:path];
//    [self.drawLayers addObject:layer];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    UIBezierPath *path = self.drawPaths.lastObject;
//    CAShapeLayer *layer = self.drawLayers.lastObject;
    [path addLineToPoint:[[touches anyObject] locationInView:self]];
    self.drawLayer.path = path.CGPath;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UIBezierPath *path = self.drawPaths.lastObject;
    [path closePath];
    [self startTimer];
}

#pragma mark - 定时器相关方法
- (void)startTimer {
    if (self.timer) {
        [self stopTimer];
    }
    self.timer = [NSTimer timerWithTimeInterval:self.interval target:self selector:@selector(clearPath) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - get
- (NSMutableArray *)drawPaths{
    if (_drawPaths == nil) {
        _drawPaths = [NSMutableArray array];
    }
    return _drawPaths;
}

- (NSMutableArray *)drawLayers{
    if (_drawLayers == nil) {
        _drawLayers = [NSMutableArray array];
    }
    return _drawLayers;
}

@end
