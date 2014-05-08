//
//  getEKData.h
//  LisCal
//
//  Created by kenjou yutaka on 2014/05/04.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface getEKData : NSObject
-(NSMutableDictionary *)EKDataDictionary:(EKEventStore *)eventStore;
@property (nonatomic) NSMutableDictionary *sections;
@property (nonatomic) NSArray *sortedDays;
//@property (strong,nonatomic) EKEventStore *eventStore;
@end
