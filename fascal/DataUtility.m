//
//  DataUtility.m
//  fascal
//
//  Created by kenjou yutaka on 2014/02/13.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "DataUtility.h"

@implementation DataUtility

+(NSDate *)adjustZeroClock:(NSDate*)date withCalendar:(NSCalendar *)calendar
{
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    return [calendar dateFromComponents:components];
}


//日と日の間の日数をカウントするクラスメソッド
+(NSInteger)daysBetween:(NSDate *)startDate and:(NSDate *)endDate
{
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    startDate = [DataUtility adjustZeroClock:startDate withCalendar:calendar];
    endDate = [DataUtility adjustZeroClock:endDate withCalendar:calendar];
    
    NSDateComponents *components = [calendar components:NSDayCalendarUnit fromDate:startDate toDate:endDate options:0];
    NSUInteger days = [components day];
    
    return days;
}

+(NSDate *)dateAtBeginningOfDayForDate:(NSDate *)inputDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSTimeZone *timezone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone:timezone];
    
    NSDateComponents *dateCompos = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:inputDate];
    
    [dateCompos setHour:0];
    [dateCompos setMinute:0];
    [dateCompos setSecond:0];
    
    NSDate *beginningOfDay = [calendar dateFromComponents:dateCompos];
    return beginningOfDay;
}

+(NSDate *)dateByAddingYears:(NSInteger)numberOfYears toDate:(NSDate *)inputDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];;
    
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setYear:numberOfYears];
    
    NSDate *newDate = [calendar dateByAddingComponents:dateComps toDate:inputDate options:0];
    
    
    return newDate;
}

+(NSDate *)dateByAddingMonthsFirstDay:(NSInteger)numberOfMonths toDate:(NSDate *)inputDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];;
    
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setMonth:numberOfMonths];
    
    NSDate *newDate = [calendar dateByAddingComponents:dateComps toDate:inputDate options:0];
    
    NSDateComponents *firstDayComps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekdayCalendarUnit fromDate:newDate];
    [firstDayComps setDay:1];
    
    newDate = [calendar dateFromComponents:firstDayComps];
    
    return newDate;
}

//nsdateをセット
/*+(NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [NSDateComponents new];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    return [calendar dateFromComponents:components];
}*/

@end
