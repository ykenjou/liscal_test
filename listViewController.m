//
//  listViewController.m
//  fascal
//
//  Created by kenjou yutaka on 2014/01/31.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "listViewController.h"
#import "calendarAccessCheck.h"
#import "DataUtility.h"
#import "getEKData.h"
#import <EventKit/EventKit.h>

@interface listViewController ()

@property(nonatomic) UITableView *tableView;
//@property(nonatomic,readwrite) EKCalendar *eventCalendar;
@end

@implementation listViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.title = @"リスト";
        self.tabBarItem.image = [[UIImage imageNamed:@"list_tab_ns.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = [[UIImage imageNamed:@"list_tab.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _eventStore = [EKEventStore new];
        _ekData = [getEKData new];
        _eventCalendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:_eventStore];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.topItem.title = @"予定リスト";
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height - 44 - 49 - 20) style:UITableViewStylePlain];
    _tableView.delegate =self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _tableView.showsVerticalScrollIndicator = NO;
    
    //ナビゲーションバー非透過設定
    self.navigationController.navigationBar.translucent = NO;
    
    //タブバー非透過設定
    self.tabBarController.tabBar.translucent = NO;
    
    calendarAccessCheck *check = [calendarAccessCheck new];
    [check EKAccessCheck];
    
    self.sections = [_ekData EKDataDictionary:_eventStore];
    
    NSArray *unsortedDays = [self.sections allKeys];
    self.sortedDays = [unsortedDays sortedArrayUsingSelector:@selector(compare:)];
    //NSLog(@"sortedDays %@",[self.sortedDays description]);
    
     
    //self.sectionDateFormatter = [NSDateFormatter new];
    //NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"MMdd" options:0 locale:[NSLocale currentLocale]];
    //self.sectionDateFormatter.dateFormat = formatString;
    //[self.sectionDateFormatter setDateStyle:NSDateFormatterLongStyle];
    //[self.sectionDateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    self.cellDateFormatter = [NSDateFormatter new];
    [self.cellDateFormatter setDateStyle:NSDateFormatterNoStyle];
    [self.cellDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    //NSLog(@"ekDictionary = %@",[self.sections description]);
    
    NSString *dictionaryDescription = [self.sections description];
    
}

-(void)calendarChangeNotification
{
    [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable:) name:EKEventStoreChangedNotification object:nil];
        }
    }];
}

//viewの表示直前の処理
-(void)viewWillAppear:(BOOL)animated
{
    [self calendarChangeNotification];
    [super viewWillAppear:animated];
}

-(void)reloadTable:(NSNotification *)notification
{
    //EKEventStore *eventStoreReload = [[EKEventStore alloc] init];
    self.sections = [_ekData EKDataDictionary:_eventStore];
    
    NSArray *unsortedDays = [self.sections allKeys];
    self.sortedDays = [unsortedDays sortedArrayUsingSelector:@selector(compare:)];
    
    NSString *sections = [self.sections description];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:section];
    NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    return [eventsOnThisDay count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDateFormatter *ymdFormatter = [NSDateFormatter new];
    ymdFormatter.dateFormat = @"yyyy年 M月d日";
    
    NSDateFormatter *mdFormatter = [NSDateFormatter new];
    mdFormatter.dateFormat = @"M月d日";
    
    NSDateFormatter *yearFormatter = [NSDateFormatter new];
    yearFormatter.dateFormat = @"yyyy";
    
    NSDate *now = [NSDate date];
    NSDate *nextDate = [NSDate dateWithTimeIntervalSinceNow:24*60*60];
    NSString *nextDateString = [ymdFormatter stringFromDate:nextDate];
    
    NSString *nowDateString = [ymdFormatter stringFromDate:now];
    NSString *nowYear = [yearFormatter stringFromDate:now];
    
    UIView *sectionView = [UIView new];
    UIColor *sectionBackColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1.0f];
    sectionView.backgroundColor = sectionBackColor;
    sectionView.frame = CGRectMake(0, 0, 320.0f, 22.0f);
    
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:section];
    
    NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    
    //NSLog(@"eventsOnThisDay %@",[eventsOnThisDay description]);
    
    
    BOOL HoliDay;
    NSString *calendarTitle;
    EKEvent *event;
    event = [eventsOnThisDay firstObject];
    calendarTitle = event.calendar.title;
    //NSLog(@"calendarTitle : %@",calendarTitle);
    
    HoliDay = YES;
    
    for (int i = 0;i < [eventsOnThisDay count];i++) {
        event = [eventsOnThisDay objectAtIndex:i];
        calendarTitle = event.calendar.title;
        if ([calendarTitle isEqualToString: @"日本の祝日"]) {
            HoliDay = YES;
            break;
        } else {
            HoliDay = NO;
        }
    }
    
    NSString *ThisDayString = [ymdFormatter stringFromDate:dateRepresentingThisDay];
    NSString *ThisYearString = [yearFormatter stringFromDate:dateRepresentingThisDay];
    
    NSString *daySubString;
    
    if ([nowDateString isEqualToString:ThisDayString])
    {
        daySubString = @"今日の予定";
    } else if ([nextDateString isEqualToString:ThisDayString])
    {
        daySubString = @"明日の予定";
    } else {
        daySubString = @"";
    }
    
    BOOL thisYear;
    
    if ([nowYear isEqualToString:ThisYearString]) {
        thisYear = YES;
    } else {
        thisYear = NO;
    }
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [calendar components:NSWeekdayCalendarUnit fromDate:dateRepresentingThisDay];
    NSInteger weekday = comps.weekday;
    static NSString * const weekArray[] = {nil,@"（日）",@"（月）",@"（火）",@"（水）",@"（木）",@"（金）",@"（土）"};
    
    static NSString * const weekArrayHoliday[] = {nil,@"（日･祝）",@"（月･祝）",@"（火･祝）",@"（水･祝）",@"（木･祝）",@"（金･祝）",@"（土･祝）"};
    
    if (weekday > 7) {
        weekday = 0;
    }
    
    NSString *dateString;
    
    if (thisYear) {
        dateString = [mdFormatter stringFromDate:dateRepresentingThisDay];
    } else {
        dateString = [ymdFormatter stringFromDate:dateRepresentingThisDay];
    }
    
    
    NSString *weekdayString;
    
    
    if (HoliDay) {
        weekdayString = weekArrayHoliday[weekday];
    } else {
        weekdayString = weekArray[weekday];
    }
    
    
    
    //NSString *weekdayString = weekArray[weekday];
    NSString *dateWeekString = [NSString stringWithFormat:@"%@%@ %@",dateString,weekdayString,daySubString];
    
    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 310.0f, 22.0f)];
    if (weekday == 1|| HoliDay) {
        sectionLabel.textColor = [UIColor redColor];
    } else if (weekday == 7) {
        sectionLabel.textColor = [UIColor blueColor];
    } else {
        sectionLabel.textColor = [UIColor blackColor];
    }
    sectionLabel.text = dateWeekString;
    sectionLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0f];
    
    [sectionView addSubview:sectionLabel];
    return sectionView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static float timeWidth = 50.0f;
    static float timeMarginLeft = 5.0f;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NSDate *dateRepresentingThisDay = [self.sortedDays objectAtIndex:indexPath.section];
    NSArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
    EKEvent *event = [eventsOnThisDay objectAtIndex:indexPath.row];
    
    //NSLog(@"event %@",event);
    
    //NSString *calendarTitle = event.calendar.title;
    //NSLog(@"calendarTitle = %@",calendarTitle);
    //UIColor *calendarColor = [UIColor colorWithCGColor:event.calendar.CGColor];
    
    _eventCalendar = event.calendar;
    //NSLog(@"%@",_eventCalendar);
    //NSLog(@"%@",_eventCalendar.title);
    //NSLog(@"%@",_eventCalendar.CGColor);
    
    //NSLog(@"calendarItemIdentifier %@", event.calendarItemIdentifier);
    
    //EKCalendar *calendar = event.calendar;
    NSString *eventCalendarTitle = _eventCalendar.title;
    UIColor *eventCalendarColor = [UIColor colorWithCGColor:_eventCalendar.CGColor];
    
    //NSLog(@"title %@",eventCalendarTitle);
    //NSLog(@"color : %@",eventCalendarColor);
    
    //NSLog(@"event title %@",event.title);
    
    UILabel *eventTitle = [[UILabel alloc] initWithFrame:CGRectMake(80, 14, 200, 20)];
    UIFont *eventTitleFont = [UIFont fontWithName:@"Helvetica" size:14.0f];
    eventTitle.font = eventTitleFont;
    eventTitle.textColor = [UIColor blackColor];
    eventTitle.text = event.title;
    eventTitle.numberOfLines = 0;
    eventTitle.tag = 1;
    //eventTitle.backgroundColor = [UIColor grayColor];
    [eventTitle sizeToFit];
    
    UILabel *eventTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 15, 50, 20)];
    UIFont * eventTimeLabelFont = [UIFont fontWithName:@"Helvetica" size:12.0f];
    eventTimeLabel.font = eventTimeLabelFont;
    eventTimeLabel.textColor = [UIColor grayColor];
    eventTimeLabel.tag = 2;
    //eventTimeLabel.backgroundColor = [UIColor grayColor];
    
    if ([eventCalendarTitle isEqualToString:@"日本の祝日"])
    {
        eventTimeLabel.text = @"祝日";
    } else if ([_eventCalendar.title isEqualToString:@"Birthdays"]){
        eventTimeLabel.text = @"誕生日";
    } else if (event.allDay) {
        eventTimeLabel.text = @"終日";
    } else {
        eventTimeLabel.text = [self.cellDateFormatter stringFromDate:event.startDate];
    }
    eventTimeLabel.numberOfLines = 0;
    [eventTimeLabel sizeToFit];
    eventTimeLabel.frame = CGRectMake(5, 15, 40, eventTimeLabel.frame.size.height);
    eventTimeLabel.textAlignment = NSTextAlignmentRight;
    
    UIImage *circle = [self imageWithColor:eventCalendarColor];
    UIImageView *circleView = [[UIImageView alloc] initWithImage:circle];
    circleView.center = CGPointMake(65, 22);
    circleView.tag = 3;
    
    [cell addSubview:circleView];
    [cell addSubview:eventTitle];
    [cell addSubview:eventTimeLabel];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cell touch");
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[cell viewWithTag:1] removeFromSuperview];
    [[cell viewWithTag:2] removeFromSuperview];
    [[cell viewWithTag:3] removeFromSuperview];
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

@end
