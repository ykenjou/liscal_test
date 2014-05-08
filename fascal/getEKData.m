//
//  getEKData.m
//  LisCal
//
//  Created by kenjou yutaka on 2014/05/04.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "DataUtility.h"
#import "calendarAccessCheck.h"
#import "getEKData.h"
#import <EventKit/EventKit.h>

@implementation getEKData

-(NSMutableDictionary *)EKDataDictionary:(EKEventStore *)eventStore
{
    NSDate *now = [NSDate date];
    NSDate *startDate = [DataUtility dateAtBeginningOfDayForDate:now];
    NSDate *endDate = [DataUtility dateByAddingYears:1 toDate:startDate];
    
    eventStore = [[EKEventStore alloc] init];
    NSPredicate *searchPrecidate= [eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
    NSArray *events = [eventStore eventsMatchingPredicate:searchPrecidate];
    
    self.sections = [NSMutableDictionary dictionary];
    for (EKEvent *event in events) {
        NSDate *dateRepresentingThisDay = [DataUtility dateAtBeginningOfDayForDate:event.startDate];
        NSMutableArray *eventsOnThisDay = [self.sections objectForKey:dateRepresentingThisDay];
        if (eventsOnThisDay == nil) {
            eventsOnThisDay = [NSMutableArray array];
            [self.sections setObject:eventsOnThisDay forKey:dateRepresentingThisDay];
        }
        [eventsOnThisDay addObject:event];
    }
    return self.sections;
}

@end
