//
//  YNRefreshFootView.h
//  Messenger
//
//  Created by YN on 2017/7/11.
//  Copyright © 2017年 YN-APP-iOS. All rights reserved.
//
/**HX** 为了满足当前项目的自定义性，目前这个刷新控件只针对tableView，因为条件限制非tableView控件添加后在8.0系列系统里会崩溃 **/
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,LoadState) {
    YNStatueLoadNomal=0,//默认状态(footView不可见)
    
    YNStatueUpPulling,//上拉状态
    
    YNStatueLoading,//正在加载
    
    YNStatueLoadFailure,//加载失败，请重试
    
    YNStatueNetworkAnomaly,//网络异常
    
    YNStatueNomoreData//没有了
};

@interface YNRefreshFootView : UIView
/**HX** 提示lable **/
@property(nonatomic,strong)UILabel *stateNoteLable;
/**HX** 刷新图片 **/
@property(nonatomic,strong)UIImageView *refreshImageView;
/**HX** 需要动画的图片--现在为旋转动画 **/
@property(nonatomic,strong)UIImageView *animationImageView;
/**HX** 当前状态 **/
@property(nonatomic,assign)LoadState currentState;
/**HX** 进入下拉状态的回调 **/
@property(nonatomic,copy)void(^returnLoadingBlock)();

/**HX** 开始加载 **/
- (void)YNbeginLoading;
/**HX** 查看更多 **/
-(void)loadSuccessful_lookMore;
/**HX** 没有更多数据 **/
-(void)loadSuccessful_nomoreData;
/**HX** 加载失败 **/
-(void)loadFailue;
/**HX** 网络异常 **/
-(void)networkAnomaly;

@end
