//
//  dayListView.m
//  LisCal
//
//  Created by kenjou yutaka on 2014/05/10.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "dayListView.h"
#import <EventKit/EventKit.h>

@interface dayListView()

@property (nonatomic) UITableView *tableView;

@end

@implementation dayListView

- (id)initWithFrame:(CGRect)frame sectionDate:(NSDate *)date rowArray:(NSArray *)array
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _screenRect = [[UIScreen mainScreen] bounds];
        _sectionDate = date;
        _rowArray = array;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _screenRect.size.width, 174) style:UITableViewStylePlain];
        //self.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        //_tableView.backgroundColor = [UIColor colorWithRed:0.392 green:0.600 blue:0.922 alpha:1.0f];
        //_tableView.bounces = NO;
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenRect.size.width, 0.5f)];
        topView.backgroundColor = [UIColor grayColor];
        [self addSubview:_tableView];
        [self addSubview:topView];
        
    }
    return self;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_rowArray count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenRect.size.width, 30)];
    
    //UIColor *sectionBackColor = [UIColor colorWithRed:0.392 green:0.600 blue:0.922 alpha:1.0f];
    UIColor *sectionBackColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1.0f];
    sectionView.backgroundColor = sectionBackColor;
    //sectionView.layer.borderColor = [UIColor grayColor].CGColor;
    //sectionView.layer.borderWidth = 0.5f;

    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, _screenRect.size.width, 30)];

    NSDateFormatter *mdFormatter = [NSDateFormatter new];
    mdFormatter.dateFormat = @"M月d日";
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [calendar components:NSWeekdayCalendarUnit fromDate:_sectionDate];
    NSInteger weekday = comps.weekday;
    static NSString * const weekArray[] = {nil,@"（日）",@"（月）",@"（火）",@"（水）",@"（木）",@"（金）",@"（土）"};
    
    NSString *weekdayString = weekArray[weekday];
    NSString *dateString = [mdFormatter stringFromDate:_sectionDate];
    
    NSString *dateWeekString = [NSString stringWithFormat:@"%@%@",dateString,weekdayString];
    
    headerLabel.text = dateWeekString;
    headerLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
    headerLabel.textColor = [UIColor blackColor];
    
    [sectionView addSubview:headerLabel];
    
    //UILabel *closeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 44, 22)];
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    closeBtn.frame = CGRectMake(_screenRect.size.width - 44, 0, 44, 30);
    
    [closeBtn setTitle:@"閉じる" forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
    [closeBtn addTarget:self action:@selector(closeBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
    
    [sectionView addSubview:closeBtn];
    
    return sectionView;
}

-(void)closeBtnTouch:(id)sendar
{
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveLinear animations:^ {
        self.frame = CGRectMake(0, _screenRect.size.height-49, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished){
        [self removeFromSuperview];
    }];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    //NSLog(@"_rowArray %@",_rowArray);
    
    EKEvent *event = [_rowArray objectAtIndex:indexPath.row];
    
    UILabel *eventTitle = [[UILabel alloc] initWithFrame:CGRectMake(80, 9, 200, 20)];
    UIFont *eventTitleFont = [UIFont fontWithName:@"Helvetica" size:15.0f];
    eventTitle.font = eventTitleFont;
    eventTitle.textColor = [UIColor blackColor];
    eventTitle.text = event.title;
    eventTitle.numberOfLines = 1;
    eventTitle.tag = 1;
    eventTitle.lineBreakMode = NSLineBreakByTruncatingTail;
    [eventTitle sizeToFit];
    
    EKCalendar *eventCalendar = event.calendar;
    NSString *eventCalendarTitle = eventCalendar.title;
    UIColor *eventCalendarColor = [UIColor colorWithCGColor:eventCalendar.CGColor];
    
    UILabel *eventTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 50, 20)];
    UIFont * eventTimeLabelFont = [UIFont fontWithName:@"Helvetica" size:11.0f];
    eventTimeLabel.font = eventTimeLabelFont;
    eventTimeLabel.textColor = [UIColor grayColor];
    eventTimeLabel.tag = 2;
    //eventTimeLabel.backgroundColor = [UIColor grayColor];
    
    NSDateFormatter *timeDateFormat = [NSDateFormatter new];
    [timeDateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
    [timeDateFormat setDateFormat:@"H:mm"];
    
    NSString *startTime = [timeDateFormat stringFromDate:event.startDate];
    NSString *endTime = [timeDateFormat stringFromDate:event.endDate];
    
    NSAttributedString *startAttributeTime = [[NSAttributedString alloc] initWithString:startTime attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    
    NSAttributedString *endAttributeTime = [[NSAttributedString alloc] initWithString:endTime attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
    
    NSAttributedString *newLine = [[NSAttributedString alloc] initWithString:@"\n"];
    
    NSMutableAttributedString *timeString = [[NSMutableAttributedString alloc] initWithAttributedString:startAttributeTime];
    [timeString appendAttributedString:newLine];
    [timeString appendAttributedString:endAttributeTime];

    
    BOOL oneLineTime = NO;
    
    if ([eventCalendarTitle isEqualToString:@"日本の祝日"])
    {
        eventTimeLabel.text = @"祝日";
        oneLineTime = YES;
    } else if ([eventCalendar.title isEqualToString:@"Birthdays"]){
        eventTimeLabel.text = @"誕生日";
        oneLineTime = YES;
    } else if (event.allDay) {
        eventTimeLabel.text = @"終日";
        oneLineTime = YES;
    } else {
        eventTimeLabel.attributedText = timeString;
    }
    
    eventTimeLabel.numberOfLines = 0;
    [eventTimeLabel sizeToFit];
    if (oneLineTime) {
        eventTimeLabel.frame = CGRectMake(5, 12, 40, eventTimeLabel.frame.size.height);
    } else {
        eventTimeLabel.frame = CGRectMake(5, 5, 40, eventTimeLabel.frame.size.height);
    }
    eventTimeLabel.textAlignment = NSTextAlignmentRight;

    UIImage *square = [self imageWithColor:eventCalendarColor];
    UIImageView *squareView = [[UIImageView alloc] initWithImage:square];
    squareView.center = CGPointMake(64, 18);
    squareView.tag = 3;
    
    [cell addSubview:eventTitle];
    [cell addSubview:eventTimeLabel];
    [cell addSubview:squareView];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[cell viewWithTag:1] removeFromSuperview];
    [[cell viewWithTag:2] removeFromSuperview];
    [[cell viewWithTag:3] removeFromSuperview];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = 36.0f;
    return height;
}

-(UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0, 0, 10, 10);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
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
