//
//  ViewController.m
//  CXLineChart
//
//  Created by chenxiang on 2017/6/1.
//  Copyright © 2017年 chenxiang. All rights reserved.
//

#import "ViewController.h"
#import "LineView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"hello world");
    NSMutableArray * arr = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < 24; i++) {
        int i = arc4random() % 10 + 1;
        [arr addObject:@(i)];
    }
    LineView * lin = [[LineView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 300)];
    lin.dataArray  = arr;
    [lin loadData];
    [self.view addSubview:lin];
    NSLog(@"-------");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
