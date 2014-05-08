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
#import "getEKData.h"
#import <QuartzCore/QuartzCore.h>

@class calendarDayCell;

@interface calenderViewController ()

@property(nonatomic,strong) UILabel *overlayView;
@property(nonatomic)CGPoint offsetPoint;
@property(nonatomic)NSCalendar *calendar;
@property(nonatomic,strong) NSDate *nowDate;

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
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    calendarFlowLayout *calLayout = [calendarFlowLayout new];
    
    //float width = screenRect.size.width/7;
    float spacing = 0.1f;
    
    [calLayout setItemSize:CGSizeMake(cellWidth, cellHeight)];
    [calLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [calLayout setMinimumInteritemSpacing:spacing];
    [calLayout setMinimumLineSpacing:spacing];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 20, screenRect.size.width, screenRect.size.height -20 -20 -44 -49) collectionViewLayout:calLayout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    
    [_collectionView registerClass:[calendarDayCell class] forCellWithReuseIdentifier:cellIdentifier];
    //[_collectionView setBackgroundColor:[UIColor colorWithRed:0.857 green:0.857 blue:0.857 alpha:1.0]];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];
    
    _collectionView.showsVerticalScrollIndicator = NO;//縦スクロールバーの表示制御
    
    //[_collectionView reloadData];
    
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
    UIView *weekDayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 20)];
    weekDayView.backgroundColor = [UIColor whiteColor];
    
    UIFont *weekDayFont = [UIFont fontWithName:@"Helvetica-Bold" size:weekDayFontSize];
    
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
    
    getEKData *ekData = [getEKData new];
    _sections = [ekData EKDataDictionary:_eventStore];
    
    //NSLog(@"_sections %@",_sections);
}

//viewの表示直前の処理
-(void)viewWillAppear:(BOOL)animated
{
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
    NSLog(@"change time");
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
    
    NSLog(@"cellDate : %@",cellDate);
    
    NSDateComponents *cellDateComponents = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit fromDate:cellDate];
    
    NSDateComponents *nowDateComponents = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:_nowDate];
    
    //日付ラベル処理
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cellWidth,10)];
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
    
    if (nowDateComponents.year == cellDateComponents.year && nowDateComponents.month == cellDateComponents.month && nowDateComponents.day == cellDateComponents.day) {
        dayCell.backgroundColor = [UIColor colorWithRed:0.949 green:0.973 blue:0.992 alpha:1.0];
        label.backgroundColor = [UIColor blackColor];
        label.textColor = [UIColor whiteColor];
    }
    
    label.text = labelStr;
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11.0f];
    
    //土日の日付の文字色設定
    if (cellDateComponents.weekday == 1)
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
        label.backgroundColor = [UIColor blackColor];
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
    //UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    //cell.contentView.backgroundColor = [UIColor blueColor];
}

//選択終了時の色変更
-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    //cell.contentView.backgroundColor = [UIColor whiteColor];
}

//スクロールアウトした際にセルの選択状態を解除
-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell.selected) {
        //cell.contentView.backgroundColor = [UIColor whiteColor];
        
        [self collectionView:collectionView didDeselectItemAtIndexPath:indexPath];
    }
    
    [[cell viewWithTag:1] removeFromSuperview];
    //[[cell viewWithTag:2] removeFromSuperview];
    //[[cell viewWithTag:3] removeFromSuperview];
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
    //NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
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
    
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSInteger seconds = [timeZone secondsFromGMTForDate:_nowDate];
    preEndDate = [preEndDate dateByAddingTimeInterval:seconds];
    return preEndDate;
}

@end
