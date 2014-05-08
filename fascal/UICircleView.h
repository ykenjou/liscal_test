//
//  UICircleView.h
//  LisCal
//
//  Created by kenjou yutaka on 2014/05/07.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UICircleView : UIView

@property (nonatomic) UIColor *color;
-(id)initWithFrameColor:(CGRect)frame color:(UIColor *)refcolor;
@end
