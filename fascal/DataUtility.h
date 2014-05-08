//
//  DataUtility.h
//  fascal
//
//  Created by kenjou yutaka on 2014/02/13.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataUtility : NSObject
+(NSInteger)daysBetween:(NSDate *)startDate and:(NSDate *)endDate;
+(NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate;
+(NSDate *)dateByAddingYears:(NSInteger)numberOfYears toDate:(NSDate *)inputDate;
@end
