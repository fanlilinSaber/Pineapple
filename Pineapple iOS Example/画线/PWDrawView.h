//
//  PWDrawView.h
//  Pineapple iOS Example
//
//  Created by 范李林 on 2017/11/3.
//

#import <UIKit/UIKit.h>

@interface PWDrawView : UIView
/*&* default red<##>*/
@property (nonatomic, strong) UIColor *strokeColor;
/*&* default 3.0f<##>*/
@property (nonatomic, assign) CGFloat lineWidth;
/*&* <##>*/
@property (nonatomic, assign) NSTimeInterval interval;
/*&* 是否需要clear 动画<##>*/
@property (nonatomic, assign) BOOL isClearAnim;

@end
