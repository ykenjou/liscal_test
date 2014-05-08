//
//  UICircleView.m
//  LisCal
//
//  Created by kenjou yutaka on 2014/05/07.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "UICircleView.h"

@implementation UICircleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithFrameColor:(CGRect)frame color:(UIColor *)refcolor
{
    self = [super initWithFrame:frame];
    if (self) {
        self.color = refcolor;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    CGContextSetFillColorWithColor(c, self.color.CGColor);
    CGContextFillEllipseInRect(c, CGRectMake(0, 0, w, h));
}

@end
