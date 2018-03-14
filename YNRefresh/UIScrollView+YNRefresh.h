//
//  UIScrollView+YNRefresh.h
//  Messenger
//
//  Created by YN on 2017/6/15.
//  Copyright © 2017年 YN-APP-iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YNRefreshHeaderView;
@class YNRefreshFootView;
@interface UIScrollView (YNRefresh)
//下拉刷新
@property(nonatomic,weak)YNRefreshHeaderView *YNheader;
//上拉加载
@property(nonatomic,weak)YNRefreshFootView *YNfoot;

-(void)YNaddRefreshHeaderWithBlock:(void (^)())Block;
-(void)YNaddLoadMoreFootWithBlock:(void (^)())Block;
@end
