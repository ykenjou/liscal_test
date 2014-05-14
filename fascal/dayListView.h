//
//  dayListView.h
//  LisCal
//
//  Created by kenjou yutaka on 2014/05/10.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface dayListView : UIView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic) NSArray *rowArray;
@property (nonatomic) NSDate *sectionDate;
@property (nonatomic) CGRect screenRect;
- (id)initWithFrame:(CGRect)frame sectionDate:(NSDate *)date rowArray:(NSArray *)array;
@end
