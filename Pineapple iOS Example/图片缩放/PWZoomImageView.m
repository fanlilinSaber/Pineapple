//
//  PWZoomImageView.m
//  Pineapple iOS Example
//
//  Created by Fan Li Lin on 2019/1/3.
//

#import "PWZoomImageView.h"

const CGFloat kMaximumZoomScale = 10.0f;
const CGFloat kMinimumZoomScale = 1.0f;
const CGFloat kDuration = 0.3f;

@interface PWZoomImageView ()<UIScrollViewDelegate>
/*&* <##>*/
@property (nonatomic, strong) UIImage *image;
/*&* <##>*/
@property (nonatomic, assign) CGSize originalSize;

@end

@implementation PWZoomImageView

//View初始化
#pragma mark - view init

- (instancetype)initWithImage:(UIImage *)image boundsSize:(CGSize)size
{
    if (self = [super init]) {
        self.bounds = CGRectMake(0, 0, size.width, size.height);
        self.image = image;
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.maximumZoomScale = kMaximumZoomScale;
        self.minimumZoomScale = kMinimumZoomScale;
        self.zoomScale = 1.0f;
        [self addSubviews];
        [self layoutPageSubviews];
        [self setupGestures];
    }
    return self;
}

//View的配置、布局设置
#pragma mark - view config

/**
 *  *&* 添加子view*
 */
- (void)addSubviews
{
    [self addSubview:self.imageView];
}

/**
 *  *&* 子view添加约束*
 */
- (void)layoutPageSubviews {}

//私有方法
#pragma mark - private Method

- (void)setupGestures
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    singleTap.delaysTouchesBegan = YES;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.delaysTouchesBegan = YES;
    [self addGestureRecognizer:singleTap];
    [self.imageView addGestureRecognizer:doubleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (CGRect)testCalculateDestinationFrameWithSize:(CGSize)size {
    CGRect rect;
    CGFloat boundsHeight = self.bounds.size.height;
    CGFloat boundsWidth = self.bounds.size.width;
    
    CGFloat screenRatio = boundsWidth / boundsHeight;
    CGFloat imageRatio = size.width / size.height;
    /*&* 如果屏幕的宽高比大于图片的宽高比*/
    if (screenRatio > imageRatio) {
        
        CGFloat imageScale = boundsHeight / size.height;
        
        rect = CGRectMake((boundsWidth - size.width * imageScale)/2,
                          0.0f,
                          size.width * imageScale,
                          boundsHeight);
        
    }else {
        
        CGFloat imageScale = boundsWidth / size.width;
        
        rect = CGRectMake(0.0f,
                          (boundsHeight - size.height * imageScale)/2,
                          boundsWidth,
                          size.height * imageScale);
    }
    
    self.contentSize = rect.size;
    return rect;
}

- (void)adjustCenter
{
    CGFloat offsetX = (self.bounds.size.width > self.contentSize.width) ? (self.bounds.size.width - self.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (self.bounds.size.height > self.contentSize.height) ? (self.bounds.size.height - self.contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(self.contentSize.width * 0.5 + offsetX, self.contentSize.height * 0.5 + offsetY);
}

//View的生命周期
#pragma mark - view life

//更新View的接口
#pragma mark - update view

//处理View的事件
#pragma mark - handle view event

//发送View的事件
#pragma mark - send view event

//公有方法
#pragma mark - public Method

#pragma mark - UIGestureRecognizerHandler

- (void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.numberOfTapsRequired == 1) {
        
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.numberOfTapsRequired == 2) {
        if(self.zoomScale == 1){
            float newScale = [self zoomScale] * 2;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:self]];
            [self zoomToRect:zoomRect animated:YES];
        } else {
            float newScale = [self zoomScale] / 2;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:self]];
            [self zoomToRect:zoomRect animated:YES];
        }
    }
}

#pragma mark - @UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    CGFloat insetY = (CGRectGetHeight(self.bounds) - CGRectGetHeight(self.imageView.frame))/2;
    insetY = MAX(insetY, 0.0);
    
    if (ABS(self.imageView.frame.origin.y - insetY) > 0.5) {
        CGRect imageViewFrame = self.imageView.frame;
        imageViewFrame = CGRectMake(imageViewFrame.origin.x, insetY, imageViewFrame.size.width, imageViewFrame.size.height);
        [UIView animateWithDuration:0.2f animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveLinear];
            self.imageView.frame = imageViewFrame;
        }];
    }
    
    [self scrollViewChangeScroll:scrollView];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    NSLog(@"image_iv.center 1 = %@",NSStringFromCGPoint(self.imageView.center));
    
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    
    NSLog(@"image_iv.center 2 = %@",NSStringFromCGPoint(self.imageView.center));
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{

}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self scrollViewChangeScroll:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewChangeScroll:scrollView];
}

- (void)scrollViewChangeScroll:(UIScrollView *)scrollView
{
    
    CGPoint currentCenter = self.imageView.center;
    
    CGFloat currentCenterX = currentCenter.x;
    CGFloat currentCenterY = currentCenter.y;
    
    CGFloat changeCenterX = self.bounds.size.width/2 - currentCenterX;
    CGFloat changeCenterY = self.bounds.size.height/2 - currentCenterY;
    
    NSLog(@"changeCenterX = %lf,changeCenterY = %lf",changeCenterX,changeCenterY);
    
    NSLog(@"scrollView.contentInset = %@",NSStringFromUIEdgeInsets(scrollView.contentInset));
}

//Setters方法
#pragma mark - @Setters
- (void)setImage:(UIImage *)image
{
    if (image == nil) {
        return;
    }
    _image = image;
    
    self.zoomScale = 1.0f;
    self.imageView.image = image;
    CGRect destinationRect = [self testCalculateDestinationFrameWithSize:self.image.size];
    self.imageView.frame = destinationRect;
    self.originalSize = destinationRect.size;
    
}

//Getters方法
#pragma mark - @Getters

- (UIImageView *)imageView
{
    if (_imageView == nil) {
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor redColor];
    }
    return _imageView;
}

- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = [self frame].size.height / scale;
    zoomRect.size.width = [self frame].size.width / scale;
    zoomRect.origin.x = center.x - zoomRect.size.width / 2;
    zoomRect.origin.y = center.y - zoomRect.size.height / 2;
    return zoomRect;
}

//dealloc
#pragma mark - @dealloc

- (void)dealloc {
    NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
