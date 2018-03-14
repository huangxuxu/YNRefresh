//
//  YNRefreshHeaderView.h
//  Messenger
//
//  Created by YN on 2017/5/17.
//  Copyright © 2017年 YN-APP-iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,RefreshState) {
    YNStatueNomal=0,//默认状态
    
    YNStatuePulling,//下拉状态
    
    YNStatueReleaseRefresh,//释放刷新状态
    
    YNStatueRefreshing,//刷新状态
    
    YNStatueRefreshSuccessful,//刷新成功状态
    
    YNStatueRefreshFailure,//刷新失败状态
    
    YNStatueRefreshNetworkAnomaly //网络异常
};

@interface YNRefreshHeaderView : UIView
/**HX** 提示lable **/
@property(nonatomic,strong)UILabel *stateNoteLable;
/**HX** 刷新图片 **/
@property(nonatomic,strong)UIImageView *refreshImageView;
/**HX** 需要动画的图片--现在为旋转动画 **/
@property(nonatomic,strong)UIImageView *animationImageView;
/**HX** 当前状态 **/
@property(nonatomic,assign)RefreshState currentState;
/**HX** 进入刷新状态的回调 **/
@property(nonatomic,copy)void(^returnRefreshingBlock)();

//开始下拉刷新
-(void)YNbeginRefreshing;
//结束下拉刷新
-(void)YNendHeadRefresh;
//刷新成功
-(void)refreshSuccessful;
//刷新失败
-(void)refreshFailue;
//网络异常
-(void)networkAnomaly;
@end
