//
//  calenderViewController.h
//  fascal
//
//  Created by kenjou yutaka on 2014/01/31.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <EventKit/EventKit.h>

@interface calenderViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate>
{
    UICollectionView *_collectionView;
    UICollectionViewCell *dayCell;
    UILabel *monthlyLabel;
    UILabel *monthlyLabel2;
    NSInteger allDays;
    NSInteger firstDayIndex;
    NSDate *startDate;
    NSDate *endDate;
    UIColor *monthColor;
    UIColor *todayColor;
}

@property (strong,nonatomic) EKEventStore *eventStore;
@property (strong,nonatomic) NSMutableDictionary *sections;
@property (strong,nonatomic) NSDateFormatter *ymdFormatter;

@end
