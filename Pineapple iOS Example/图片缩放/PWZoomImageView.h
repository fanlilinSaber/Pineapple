//
//  PWZoomImageView.h
//  Pineapple iOS Example
//
//  Created by Fan Li Lin on 2019/1/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PWZoomImageView : UIScrollView

- (instancetype)initWithImage:(UIImage *)image boundsSize:(CGSize)size;

/*&* main imageView*/
@property (nonatomic, strong) UIImageView *imageView;

@end

NS_ASSUME_NONNULL_END
