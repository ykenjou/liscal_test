//
//  calendarAccessCheck.h
//  LisCal
//
//  Created by kenjou yutaka on 2014/05/02.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface calendarAccessCheck : NSObject

@property (nonatomic) BOOL EKAccess;

-(void)EKAccessCheck;

@end
