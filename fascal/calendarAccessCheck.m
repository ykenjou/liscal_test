//
//  calendarAccessCheck.m
//  LisCal
//
//  Created by kenjou yutaka on 2014/05/02.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "calendarAccessCheck.h"
#import <EventKit/EventKit.h>

@implementation calendarAccessCheck

-(void)EKAccessCheck
{
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    //NSLog(@"status:%d",status);
    
    //ユーザーのeventkitデータアクセス許可設定の確認
    switch (status) {
            //まだ許可されていない場合に許可を要請
        case EKAuthorizationStatusNotDetermined:
        {
            [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                if (granted) {
                    _EKAccess = YES;
                    NSLog(@"EKAccess : %d",_EKAccess);
                }
            }];
            break;
        }
        //ユーザーからアクセスを拒否されている
        case EKAuthorizationStatusDenied:
        //ユーザーから機能制限されている
        case EKAuthorizationStatusRestricted:
            //許可しないと使用できない旨を通知する
            [self notifyEvent];
            break;
        //許可されているのでそのまま処理を続ける
        case EKAuthorizationStatusAuthorized:
        {
            _EKAccess = YES;
            NSLog(@"EKAccess : %d",_EKAccess);
        }
        default:
            break;
    }
    
}

-(void)notifyEvent
{
    UIAlertView *notify = [[UIAlertView alloc] initWithTitle:@"許可設定してください"
                                                     message:@"カレンダーにアクセスできません。「設定」アプリの「プライバシー」→「カレンダー」の項目で「LisCal」のカレンダーへのアクセスを許可してください。許可されない場合にはアプリの機能が使用できません。"
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [notify show];
}

/*
-(NSArray *)listData
{
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *tenDayAgo = [[NSDateComponents alloc] init];
    tenDayAgo.month = -3;
    NSDate *tenDayAgoDay = [calendar dateByAddingComponents:tenDayAgo toDate:[NSDate date] options:0];
    
    NSDateComponents *oneYearAfterComp = [[NSDateComponents alloc] init];
    oneYearAfterComp.year = 1;
    NSDate *oneYearFromNow = [calendar dateByAddingComponents:oneYearAfterComp toDate:[NSDate date] options:0];
    
    NSPredicate *precidate = [eventStore predicateForEventsWithStartDate:tenDayAgoDay endDate:oneYearFromNow calendars:nil];
    
    NSArray *events = [eventStore eventsMatchingPredicate:precidate];
    EKEvent *firstEvent = [EKEvent alloc];
    firstEvent = events[0];
    
    NSInteger count = [events count];
    NSLog(@"count :%ld",(long)count);
    
    for (EKEvent *event in events) {
        NSLog(@"%@ - status at %@",event.title , event.startDate);
    }
    return events;
}
 */

@end
