//
//  listViewController.h
//  fascal
//
//  Created by kenjou yutaka on 2014/01/31.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "getEKData.h"

@interface listViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic) NSMutableDictionary *sections;
@property (nonatomic) NSArray *sortedDays;
@property (nonatomic) NSDateFormatter *sectionDateFormatter;
@property (nonatomic) NSDateFormatter *cellDateFormatter;
@property (nonatomic,retain) EKEventStore *eventStore;
@property (nonatomic) EKCalendar *eventCalendar;
@property (nonatomic) getEKData *ekData;
@property (nonatomic) EKEvent *cellEvent;
@end
