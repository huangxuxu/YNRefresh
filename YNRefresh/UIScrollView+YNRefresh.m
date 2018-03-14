//
//  UIScrollView+YNRefresh.m
//  Messenger
//
//  Created by YN on 2017/6/15.
//  Copyright © 2017年 YN-APP-iOS. All rights reserved.
//

#import "UIScrollView+YNRefresh.h"
#import <objc/runtime.h>
#import "YNRefreshHeaderView.h"
#import "YNRefreshFootView.h"

@implementation UIScrollView (YNRefresh)

#pragma mark __关联头部
-(void)setYNheader:(YNRefreshHeaderView *)YNheader{
    objc_setAssociatedObject(self, @selector(YNheader), YNheader, OBJC_ASSOCIATION_ASSIGN);
}
-(YNRefreshHeaderView *)YNheader{
    return objc_getAssociatedObject(self, @selector(YNheader));
}
#pragma mark __关联底部
-(void)setYNfoot:(YNRefreshFootView *)YNfoot{
    objc_setAssociatedObject(self, @selector(YNfoot), YNfoot, OBJC_ASSOCIATION_ASSIGN);
}
-(YNRefreshFootView *)YNfoot{
    return objc_getAssociatedObject(self, @selector(YNfoot));
}
#pragma mark __初始化头部
-(void)YNaddRefreshHeaderWithBlock:(void (^)())Block
{
    YNRefreshHeaderView *Yheader=[[YNRefreshHeaderView alloc]init];
    Yheader.returnRefreshingBlock=Block;
    self.YNheader=Yheader;
    [self insertSubview:Yheader atIndex:0];
    
}
#pragma mark __初始化底部
-(void)YNaddLoadMoreFootWithBlock:(void (^)())Block{
    YNRefreshFootView*YNfoot=[[YNRefreshFootView alloc]init];
    YNfoot.returnLoadingBlock=Block;
    self.YNfoot=YNfoot;
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView*tableV=(UITableView*)self;
        tableV.tableFooterView=YNfoot;
    }
    
}
@end
