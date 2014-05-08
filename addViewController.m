//
//  addViewController.m
//  fascal
//
//  Created by kenjou yutaka on 2014/01/31.
//  Copyright (c) 2014年 kenjou yutaka. All rights reserved.
//

#import "addViewController.h"

@interface addViewController ()

@end

@implementation addViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title = @"追加";
        
        self.tabBarItem.title = @"追加";
        self.tabBarItem.image = [[UIImage imageNamed:@"pen_tab_ns.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.tabBarItem.selectedImage = [[UIImage imageNamed:@"pen_tab.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        /*UIEdgeInsets insets;
        insets.top = 5.0;
        insets.bottom = -5.0;
        self.tabBarItem.imageInsets = insets;*/
        
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
