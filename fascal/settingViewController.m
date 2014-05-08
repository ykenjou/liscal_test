//
//  settingViewController.m
//  fascal
//
//  Created by kenjou yutaka on 2014/01/31.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "settingViewController.h"

@interface settingViewController ()

@end

@implementation settingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"設定";
        self.tabBarItem.title = @"設定";
        self.tabBarItem.image = [[UIImage imageNamed:@"gear_tab_ns.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"gear_tab.png"];
        
        UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [view setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:view];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
