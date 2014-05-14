//
//  calenderViewController.m
//  fascal
//
//  Created by kenjou yutaka on 2014/01/31.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "calenderViewController.h"
#import "DataUtility.h"
#import "calendarDayCell.h"
#import "calendarFlowLayout.h"
#import "calendarAccessCheck.h"
#import <QuartzCore/QuartzCore.h>

@class calendarDayCell;

@interface calenderViewController ()

@property(nonatomic,strong) UILabel *overlayView;
@property(nonatomic)CGPoint offsetPoint;
@property(nonatomic)NSCalendar *calendar;
@property(nonatomic,strong) NSDate *nowDate;
@property(nonatomic) NSTimer *handleTimer;

@end

@implementation calenderViewController

static NSString *cellIdentifier = @"cellIdentifier";
static float cellHeight = 70.0f;
static float cellWidth = 45.6f;
static float weekDayFontSize = 12.0f;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tabBarItem.title = @"カレンダー";
        self.tabBarItem.image = [[UIImage imageNamed:@"calendar_tab_ns.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"calendar_tab.png"];
        self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        self.overlayView = [UILabel new];
        _eventStore = [EKEventStore new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [self resetCalendarDate];
    [self dateChangeNotification];
    
    _screenRect = [[UIScreen mainScreen] bounds];
    
    calendarFlowLayout *calLayout = [calendarFlowLayout new];
    
    //float width = screenRect.size.width/7;
    float spacing = 0.1f;
    
    [calLayout setItemSize:CGSizeMake(cellWidth, cellHeight)];
    [calLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [calLayout setMinimumInteritemSpacing:spacing];
    [calLayout setMinimumLineSpacing:spacing];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 20, _screenRect.size.width, _screenRect.size.height -20 -20 -44 -49) collectionViewLayout:calLayout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    
    [_collectionView registerClass:[calendarDayCell class] forCellWithReuseIdentifier:cellIdentifier];
    //[_collectionView setBackgroundColor:[UIColor colorWithRed:0.857 green:0.857 blue:0.857 alpha:1.0]];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    
    _collectionView.showsVerticalScrollIndicator = NO;//縦スクロールバーの表示制御
    
    //コレクションビューをサブビューにセット
    [self.view addSubview:_collectionView];
    
    //ナビゲーションバー非透過設定
    self.navigationController.navigationBar.translucent = NO;
    
    //タブバー非透過設定
    self.tabBarController.tabBar.translucent = NO;
    
    //「今日」ボタンの表示
    UIBarButtonItem *todayButton = [[UIBarButtonItem alloc] initWithTitle:@"今日" style:UIBarButtonItemStyleBordered target:self action:@selector(todayScroll:)];
    self.navigationItem.rightBarButtonItem = todayButton;
    
    //週のラベル表示
    UIView *weekDayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenRect.size.width, 20)];
    weekDayView.backgroundColor = [UIColor whiteColor];
    weekDayView.layer.borderColor = [UIColor grayColor].CGColor;
    weekDayView.layer.borderWidth = 0.5f;
    
    UIFont *weekDayFont = [UIFont fontWithName:@"Helvetica" size:weekDayFontSize];
    
    UILabel *sunday = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cellWidth, 20)];
    sunday.text = @"日";
    sunday.textAlignment = NSTextAlignmentCenter;
    sunday.font = weekDayFont;
    sunday.textColor = [UIColor redColor];
    
    UILabel *monday = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth, 0, cellWidth, 20)];
    monday.text = @"月";
    monday.textAlignment = NSTextAlignmentCenter;
    monday.font = weekDayFont;
    
    UILabel *tuesday = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth * 2, 0, cellWidth, 20)];
    tuesday.text = @"火";
    tuesday.textAlignment = NSTextAlignmentCenter;
    tuesday.font = weekDayFont;
    
    UILabel *wednesday = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth * 3, 0, cellWidth, 20)];
    wednesday.text = @"水";
    wednesday.textAlignment = NSTextAlignmentCenter;
    wednesday.font = weekDayFont;
    
    UILabel *thursday = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth * 4, 0, cellWidth, 20)];
    thursday.text = @"木";
    thursday.textAlignment = NSTextAlignmentCenter;
    thursday.font = weekDayFont;
    
    UILabel *friday = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth * 5, 0, cellWidth, 20)];
    friday.text = @"金";
    friday.textAlignment = NSTextAlignmentCenter;
    friday.font = weekDayFont;
    
    UILabel *saturday = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth * 6, 0, cellWidth, 20)];
    saturday.text = @"土";
    saturday.textAlignment = NSTextAlignmentCenter;
    saturday.font = weekDayFont;
    saturday.textColor = [UIColor blueColor];
    
    [weekDayView addSubview:sunday];
    [weekDayView addSubview:monday];
    [weekDayView addSubview:tuesday];
    [weekDayView addSubview:wednesday];
    [weekDayView addSubview:thursday];
    [weekDayView addSubview:friday];
    [weekDayView addSubview:saturday];
    
    [self.view addSubview:weekDayView];
    
    calendarAccessCheck *check = [calendarAccessCheck new];
    [check EKAccessCheck];
    
    _ekData = [getEKData new];
    _sections = [_ekData EKDataDictionary:_eventStore];
    
    NSString *eventDictionary = [_sections description];
    
    //NSLog(@"_sections %@",_sections);
    
}

//viewの表示直前の処理
-(void)viewWillAppear:(BOOL)animated
{
    [self calendarChangeNotification];
    
    [super viewWillAppear:animated];
    
    //日付が変わっている場合にカレンダー表示を再設定する
    [self dateChangeNotification];
    
    //view切り替え前の位置がセットされている場合にはその位置に戻し、セットされていない場合には今日の日付の位置を表示する
    if (_offsetPoint.y == 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:firstDayIndex inSection:0];
        [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    } else {
        [_collectionView setContentOffset:_offsetPoint];
    }
}

-(void)dateChangeNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCalendar:) name:UIApplicationSignificantTimeChangeNotification object:nil];
}

-(void)reloadCalendar:(NSNotification *)notification
{
    [self resetCalendarDate];
}

-(void)handleNotification:(NSNotification *)note
{
    [_handleTimer invalidate];
    _handleTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(reloadView:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_handleTimer forMode:NSDefaultRunLoopMode];
}

-(void)resetCalendarDate
{
    _nowDate = [NSDate date];
    startDate = [self setStartDate:_nowDate];
    endDate = [self setEndDate:_nowDate];
    
    allDays = [DataUtility daysBetween:startDate and:endDate];
    firstDayIndex = [DataUtility daysBetween:startDate and:_nowDate];
    [_collectionView reloadData];
    //NSLog(@"reset done");
}


-(void)calendarChangeNotification
{
    [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:EKEventStoreChangedNotification object:_eventStore];
        }
    }];
}

-(void)reloadView:(NSNotification *)notification
{
    [_handleTimer invalidate];
    self.sections = [_ekData EKDataDictionary:_eventStore];
    
    NSString *sections = [self.sections description];
    
    NSLog(@"reloadView");
    
    [_collectionView reloadData];
}


//viewが他に移る前の処理
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    /*NSDateComponents *nowDateComponent = [_calendar components:NSDayCalendarUnit fromDate:_nowDate];
    int nowDay = nowDateComponent.day;
    NSLog(@"%d",(int)nowDay);*/
    
    //現在のスクロール位置をセット
    _offsetPoint = [_collectionView contentOffset];
    //NSLog(@"%@",NSStringFromCGPoint(_offsetPoint));
}

//今日ボタンを押した時の処理
-(void)todayScroll:(UIBarButtonItem *)btn
{
    [self dateChangeNotification];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:firstDayIndex inSection:0];
    [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -collection view delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return allDays + 1;
    } else {
        return 0;
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    dayCell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    //_nowDate = [NSDate new];
    
    NSDate *cellDate = [_calendar dateByAddingComponents:((^{
        NSDateComponents *datecomponents = [NSDateComponents new];
        datecomponents.day = indexPath.item;
        return datecomponents;
    })()) toDate:startDate options:0];
    
    //NSLog(@"cellDate : %@",cellDate);
    
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSInteger seconds = [timeZone secondsFromGMT];
    NSDate *gtmDate = [cellDate dateByAddingTimeInterval:-seconds];
    
    NSArray *events = [_sections objectForKey:gtmDate];
    //NSLog(@"timezone ,%@",timeZone);
    //NSLog(@"seconds %d",seconds);
    //NSLog(@"gtmDate %@",gtmDate);
    //NSLog(@"eventArray %@",events);
    
    EKEvent *event;
    float labelHeight = 13.0f;
    
    BOOL Holiday = NO;
    NSInteger rows = 0;
    if ([events count] > 4) {
        rows = 4;
    } else {
        rows = [events count];
    }
    
    if (events) {
        for (int i = 0; i < rows; i++) {
            event = [events objectAtIndex:i];
            UILabel *eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, (labelHeight * (i + 1)) + 2 , 43.2, 12.0)];
            eventLabel.text = event.title;
            eventLabel.textColor = [UIColor whiteColor];
            eventLabel.tag = i + 2;
            eventLabel.numberOfLines = 1;
            eventLabel.adjustsFontSizeToFitWidth = NO;
            eventLabel.lineBreakMode = NSLineBreakByClipping;
            eventLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10.0f];
            eventLabel.backgroundColor = [UIColor colorWithCGColor:event.calendar.CGColor];
            [dayCell addSubview:eventLabel];
            
            if (!Holiday) {
                if ([event.calendar.title  isEqual: @"日本の祝日"])
                {
                    Holiday = YES;
                }
            }
        }
    }
    
    NSDateComponents *cellDateComponents = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:cellDate];
    
    NSDateComponents *nowDateComponents = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:_nowDate];
    
    //日付ラベル処理
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(1, 1, cellWidth-2,13)];
    //NSString *strYear = @(cellDateComponents.year).stringValue;
    NSString *strMonth = @(cellDateComponents.month).stringValue;
    NSString *strDay = @(cellDateComponents.day).stringValue;
    NSString *labelStr;

    //CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    /*
    if (cellDateComponents.day > 14 && cellDateComponents.day < 22 && cellDateComponents.weekday == 1) {
        monthlyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -30,screenRect.size.width, 30)];
        monthlyLabel.text = [NSString stringWithFormat:@"%@年%@月",strYear,strMonth];
        monthlyLabel.textAlignment = NSTextAlignmentCenter;
        monthlyLabel.tag = 2;
        [monthlyLabel setAlpha:0.0f];
        [dayCell addSubview:monthlyLabel];
    }
    
    if (cellDateComponents.day > 7 && cellDateComponents.day < 15 && cellDateComponents.weekday == 1) {
        monthlyLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 70,screenRect.size.width, 30)];
        monthlyLabel2.text = [NSString stringWithFormat:@"%@年%@月",strYear,strMonth];
        monthlyLabel2.textAlignment = NSTextAlignmentCenter;
        monthlyLabel2.tag = 3;
        [monthlyLabel2 setAlpha:0.0f];
        [dayCell addSubview:monthlyLabel2];
    }*/
    
    if (cellDateComponents.day == 1) {
        labelStr = [NSString stringWithFormat:@"%@月%@日",strMonth,strDay];
    } else {
        labelStr = [NSString stringWithFormat:@"%@",strDay];
    }
    
    /*
    if (nowDateComponents.year == cellDateComponents.year && nowDateComponents.month == cellDateComponents.month && nowDateComponents.day == cellDateComponents.day) {
        dayCell.backgroundColor = [UIColor colorWithRed:0.949 green:0.973 blue:0.992 alpha:1.0];
        label.backgroundColor = [UIColor blackColor];
        label.textColor = [UIColor whiteColor];
    }
     */
    
    label.text = labelStr;
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
    
    //土日の日付の文字色設定
    if (cellDateComponents.weekday == 1 || Holiday)
    {
        label.textColor = [UIColor redColor];
    } else if (cellDateComponents.weekday == 7)
    {
        label.textColor = [UIColor blueColor];
    }
    
    label.backgroundColor = [UIColor clearColor];
    label.tag = 1;
    
    [dayCell.contentView addSubview:label];
    
    //セル背景色処理
    
    dayCell.backgroundColor = [UIColor whiteColor];
    
    if (cellDateComponents.month % 2 == 0) {
        //cell.backgroundColor = [UIColor grayColor];
        dayCell.backgroundColor = [UIColor colorWithRed:0.973 green:0.973 blue:0.973 alpha:1.0];
    }
    
    //日付が今日だった場合の処理
    if (nowDateComponents.year == cellDateComponents.year && nowDateComponents.month == cellDateComponents.month && nowDateComponents.day == cellDateComponents.day) {
        dayCell.backgroundColor = [UIColor colorWithRed:0.949 green:0.973 blue:0.992 alpha:1.0];
        label.backgroundColor = [UIColor colorWithRed:0.282 green:0.024 blue:0.647 alpha:1.0];
        label.textColor = [UIColor whiteColor];
    }
    
    NSArray *array = [NSArray arrayWithArray:[collectionView indexPathsForVisibleItems]];
    NSArray *sortedIndexPaths = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSIndexPath *path1 = (NSIndexPath *)obj1;
        NSIndexPath *path2 = (NSIndexPath *)obj2;
        return [path1 compare:path2];
    }];
    
    /*NSArray *visibleCells = [_collectionView visibleCells];//表示されているセル
    
    NSIndexPath *fromIndexPath = [_collectionView indexPathForCell:((UICollectionViewCell *)visibleCells[0]) ];//表示されている最初のセルのインデックスを取得
    NSLog(@"fromindexpath %@",fromIndexPath);*/

    
    NSIndexPath *firstCellIndex = [sortedIndexPaths firstObject];
    
    NSDate *naviDate = [_calendar dateByAddingComponents:((^{
        NSDateComponents *datecomponents = [NSDateComponents new];
        datecomponents.day = firstCellIndex.item + 14;
        return datecomponents;
    })()) toDate:startDate options:0];
    
    NSDateComponents *naviDateComponents = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:naviDate];
    
    //ナビゲーションバータイトル設定
    NSInteger titleYear = naviDateComponents.year;
    NSInteger titleMonth = naviDateComponents.month;
    NSString *title = [[NSString alloc] initWithFormat:@"%ld年 %ld月",(long)titleYear,(long)titleMonth];
    
    self.navigationController.navigationBar.topItem.title = title;
    
    
    return dayCell;
}


//選択時の色変更
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    //cell.contentView.backgroundColor = [UIColor blueColor];
    cell.layer.borderWidth = 1.0f;
    cell.layer.borderColor = [UIColor colorWithRed:0.282 green:0.024 blue:0.647 alpha:1.0].CGColor;
    
    NSDate *cellDate = [_calendar dateByAddingComponents:((^{
        NSDateComponents *datecomponents = [NSDateComponents new];
        datecomponents.day = indexPath.item;
        return datecomponents;
    })()) toDate:startDate options:0];
    //NSLog(@"cellDate %@",cellDate);
    
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSInteger seconds = [timeZone secondsFromGMT];
    NSDate *gtmDate = [cellDate dateByAddingTimeInterval:-seconds];
    
    NSArray *events = [_sections objectForKey:gtmDate];
    //NSLog(@"events %@",events);
    
    if ([_listView isDescendantOfView:self.view]) {
        [_listView removeFromSuperview];
        _listView = [[dayListView alloc] initWithFrame:CGRectMake(0, _screenRect.size.height - 287, _screenRect.size.width, 210) sectionDate:cellDate rowArray:events];
        [self.view addSubview:_listView];
    } else {
    
        _listView = [[dayListView alloc] initWithFrame:CGRectMake(0, _screenRect.size.height - 49, _screenRect.size.width, 210) sectionDate:cellDate rowArray:events];
        _listView.tag = 10;
        [self.view addSubview:_listView];
    
        [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveLinear animations:^ {
            _listView.frame = CGRectMake(0, _screenRect.size.height - 287, _listView.frame.size.width, _listView.frame.size.height);
        } completion:^(BOOL finished){
        }];
    }
}

//選択終了時の色変更
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.layer.borderWidth = 0.0f;
    //cell.contentView.backgroundColor = [UIColor whiteColor];
}

//スクロールアウトした際にセルの選択状態を解除
-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell.selected) {
        //cell.contentView.backgroundColor = [UIColor whiteColor];
        
        [self collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
        cell.layer.borderWidth = 0.0f;
    }
    
    
    [[cell viewWithTag:1] removeFromSuperview];
    [[cell viewWithTag:2] removeFromSuperview];
    [[cell viewWithTag:3] removeFromSuperview];
    [[cell viewWithTag:4] removeFromSuperview];
    [[cell viewWithTag:5] removeFromSuperview];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    //[_collectionView setAlpha:1.0f];
    //[monthlyLabel setAlpha:0.0f];
    //[monthlyLabel2 setAlpha:0.0f];
    //NSLog(@"end anime");
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    /*
    [_collectionView setAlpha:1.0f];
    [monthlyLabel setAlpha:0.0f];
    [monthlyLabel2 setAlpha:0.0f];
     */
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.dragging) {
        //[_collectionView setAlpha:0.5f];
        //[monthlyLabel setAlpha:1.0f];
        //[monthlyLabel2 setAlpha:1.0f];
        
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([_listView isDescendantOfView:self.view]) {
        [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveLinear animations:^ {
            _listView.frame = CGRectMake(0, _screenRect.size.height-49, _listView.frame.size.width, _listView.frame.size.height);
        } completion:^(BOOL finished){
            [_listView removeFromSuperview];
        }];
    }

}

-(NSDate *)setStartDate:(NSDate *)date
{
    //NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *pastDate = [_calendar dateByAddingComponents:((^{
        NSDateComponents *datecomponents = [NSDateComponents new];
        datecomponents.month = -3;
        return datecomponents;
    })()) toDate:_nowDate options:0];
    
    NSDateComponents *pastComponents = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekdayCalendarUnit fromDate:pastDate];
    [pastComponents setDay:1];
    
    pastDate = [_calendar dateFromComponents:pastComponents];
    
    pastComponents = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:pastDate];
    
    NSInteger pastWeekDay = pastComponents.weekday;
    
    NSDate *firstDate = [_calendar dateByAddingComponents:((^{
        NSDateComponents *datecomponents = [NSDateComponents new];
        datecomponents.day = -pastWeekDay + 1;
        return datecomponents;
    })()) toDate:pastDate options:0];
    
    NSDateComponents *firstDateComponents = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:firstDate];
    
    date = [_calendar dateFromComponents:firstDateComponents];
    
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSInteger seconds = [timeZone secondsFromGMTForDate:_nowDate];
    date = [date dateByAddingTimeInterval:seconds];
    return date;
}

-(NSDate *)setEndDate:(NSDate *)date
{
    NSDate *futureDate = [_calendar dateByAddingComponents:((^{
        NSDateComponents *datecomponents = [NSDateComponents new];
        datecomponents.month = 11;
        return datecomponents;
    })()) toDate:_nowDate options:0];
    
    NSDateComponents *futureDateComponents = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:futureDate];
    
    futureDate = [_calendar dateFromComponents:futureDateComponents];
    
    NSDate *preEndDate = [_calendar dateByAddingComponents:((^{
        NSDateComponents *datecomponents = [NSDateComponents new];
        datecomponents.month = 1;
        datecomponents.day = -1;
        return datecomponents;
    })()) toDate:futureDate options:0];
    
    futureDateComponents = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:preEndDate];
    NSInteger weekDay = futureDateComponents.weekday;
    
    if (weekDay != 7) {
        weekDay = 7 - weekDay;
        preEndDate = [_calendar dateByAddingComponents:((^{
            NSDateComponents *datecomponents = [NSDateComponents new];
            datecomponents.day = weekDay;
            return datecomponents;
        })()) toDate:preEndDate options:0];
    }
    
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSInteger seconds = [timeZone secondsFromGMTForDate:_nowDate];
    preEndDate = [preEndDate dateByAddingTimeInterval:seconds];
    
    return preEndDate;
}

@end
