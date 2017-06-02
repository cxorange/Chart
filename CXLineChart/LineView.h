//
//  LineView.h
//  UIpage
//
//  Created by chenxiang on 2017/5/9.
//  Copyright © 2017年 chenxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineView : UIView
@property (nonatomic, strong) NSMutableArray * dataArray;

- (void)loadData;
@end
