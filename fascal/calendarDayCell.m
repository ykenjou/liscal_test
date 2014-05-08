//
//  calendarDayCell.m
//  fascal
//
//  Created by kenjou yutaka on 2014/02/14.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "calendarDayCell.h"
#import "calenderViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface calendarDayCell ()
@property (nonatomic,readonly,strong) UIImageView *imageView;
@property (nonatomic,readonly,strong) UIView *overlayView;

@end

@implementation calendarDayCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.restorationIdentifier = @"cellIdentifier";
        
        CGFloat borderWidth = 0.5f;
        CGRect myContetRect = CGRectInset(self.contentView.bounds, -borderWidth, -borderWidth);
        
        CGFloat borderBgWidth = 1.0f;
        CGRect myContetBgRect = CGRectInset(self.contentView.bounds, -borderBgWidth, -borderBgWidth);
        
        UIView *bgview = [[UIView alloc] initWithFrame:myContetBgRect];
        bgview.layer.borderColor = [UIColor blueColor].CGColor;
        bgview.layer.borderWidth = borderBgWidth;
        //self.selectedBackgroundView = bgview;
        
        UIView *myContentView = [[UIView alloc] initWithFrame:myContetRect];
        myContentView.layer.borderColor = [UIColor colorWithRed:0.588 green:0.588 blue:0.588 alpha:1.0].CGColor;
        myContentView.layer.borderWidth = borderWidth;
        [self.contentView addSubview:myContentView];
    }
    return self;
}

-(void)prepareForReuse
{
    [super prepareForReuse];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
