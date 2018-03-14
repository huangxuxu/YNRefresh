//
//  YNRefreshHeaderView.m
//  Messenger
//
//  Created by YN on 2017/5/17.
//  Copyright © 2017年 YN-APP-iOS. All rights reserved.
//

#import "YNRefreshHeaderView.h"

const static float headerRefeshViewHight=40;
const static float imageViewSize=20;

@interface YNRefreshHeaderView()
/**HX** tableView弱引用 **/
@property(nonatomic,weak)UIScrollView *superScrollview;
/**HX** 记录scrollView初始时的偏移量 **/
@property(nonatomic,assign)CGFloat contentOffSetY;
/**HX** 记录scrollView初始时的fram **/
@property(nonatomic,assign)CGRect initFram;
@end
@implementation YNRefreshHeaderView
-(instancetype)init{
    if (self=[super initWithFrame:CGRectMake(0, -headerRefeshViewHight, ScreenWidth, headerRefeshViewHight)]) {
        [self setUpUI];
        self.currentState = YNStatueNomal;
    }
    return self;
}
-(void)setUpUI{
    self.stateNoteLable.bounds=CGRectMake(0, 0, 20, 20);
    self.stateNoteLable.center=CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.refreshImageView.frame=CGRectMake(CGRectGetMidX(self.stateNoteLable.frame)-imageViewSize-15, (headerRefeshViewHight-imageViewSize)/2, imageViewSize, imageViewSize);
    self.animationImageView.frame=CGRectMake(0, 0, imageViewSize, imageViewSize);
    
}
#pragma mark __添加观察者
-(void)willMoveToSuperview:(UIView *)newSuperview{
    if (self.superScrollview) {
        return;
    }
    [super willMoveToSuperview:newSuperview];
    // 如果不是UIScrollView，不做任何事情
    if (![newSuperview isKindOfClass:[UIScrollView class]]) return;
    //加上这句，可以在控件在自动布局和非自动布局下都能获取到它的bounds的准确值
    [newSuperview layoutIfNeeded];
    if (newSuperview) {
        self.superScrollview = (UIScrollView *)newSuperview;
        self.contentOffSetY=self.superScrollview.contentInset.top;
        @try {
            [self.superScrollview removeObserver:self forKeyPath:@"contentOffset"];
        } @catch (NSException *exception) {
            debugLog(@"多次删除KVO报错,不放在try里容易崩溃");
        }
        [self.superScrollview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }else {
        if (self.superScrollview) {
            @try {
                [self.superScrollview removeObserver:self forKeyPath:@"contentOffset"];
            } @catch (NSException *exception) {
                debugLog(@"多次删除KVO报错,不放在try里容易崩溃");
            }
            
        }
    }
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGFloat y = self.superScrollview.contentOffset.y;
        if (self.superScrollview.isDragging) {
            //正在拖动
            if (y>= -self.contentOffSetY && self.currentState ==YNStatuePulling) {
                //下拉状态->正常状态
                self.currentState = YNStatueNomal;
            }else if (y >= -self.contentOffSetY - headerRefeshViewHight && (self.currentState == YNStatueNomal||self.currentState==YNStatueReleaseRefresh))
            {
                //正常状态->下拉状态
                self.currentState = YNStatuePulling;
            }else if (y<=-self.contentOffSetY-headerRefeshViewHight&&self.currentState==YNStatuePulling){
                //下拉状态-> 松手刷新状态
                self.currentState=YNStatueReleaseRefresh;
            }
            
        }else {
            if(self.currentState ==YNStatueReleaseRefresh &&y <= -self.contentOffSetY - headerRefeshViewHight){
                //正在刷新
                self.currentState = YNStatueRefreshing;
            }
        }
    }
}
static bool imageViewRotationed=NO;//是否已旋转
-(void)setCurrentState:(RefreshState)currentState{
    if (self.superScrollview==nil) {
        return;
    }
    _currentState=currentState;
    /**HX** 在主线程进行操作，防止不在主线程 **/
    [self performSelectorOnMainThread:@selector(setState) withObject:nil waitUntilDone:NO];
}
-(void)setState{
    BOOL animation =NO;
    weak_Self(weakSelf);
    switch (_currentState) {
        case YNStatueNomal:
        {
            self.stateNoteLable.text=@"下拉可刷新";
            self.refreshImageView.image=[UIImage imageNamed:@"YNRefreshSource.bundle/drop_downRefresh.png"];
            [self.animationImageView.layer removeAllAnimations];
            self.animationImageView.hidden=YES;
            self.superScrollview.contentInset = UIEdgeInsetsMake(self.contentOffSetY, self.superScrollview.contentInset.left, 0, self.superScrollview.contentInset.right);
            if (imageViewRotationed) {
                [UIView animateWithDuration:0.3 animations:^{
                    CGAffineTransform rotation=CGAffineTransformMakeRotation(2*M_PI);
                    [weakSelf.refreshImageView setTransform:rotation];
                }];
                imageViewRotationed=NO;
            }
        }
            break;
        case YNStatuePulling:
        {
            self.stateNoteLable.text=@"下拉可刷新";
            self.refreshImageView.image=[UIImage imageNamed:@"YNRefreshSource.bundle/drop_downRefresh.png"];
            [self.animationImageView.layer removeAllAnimations];
            self.animationImageView.hidden=YES;
            if (imageViewRotationed) {
                [UIView animateWithDuration:0.3 animations:^{
                    CGAffineTransform rotation=CGAffineTransformMakeRotation(2*M_PI);
                    [weakSelf.refreshImageView setTransform:rotation];
                }];
                imageViewRotationed=NO;
            }
            
        }
            break;
        case YNStatueReleaseRefresh:
        {
            self.stateNoteLable.text=@"释放加载";
            self.refreshImageView.image=[UIImage imageNamed:@"YNRefreshSource.bundle/drop_downRefresh.png"];
            [self.animationImageView.layer removeAllAnimations];
            self.animationImageView.hidden=YES;
            if (!imageViewRotationed) {
                [UIView animateWithDuration:0.3 animations:^{
                    CGAffineTransform rotation=CGAffineTransformMakeRotation(-M_PI);
                    [weakSelf.refreshImageView setTransform:rotation];
                }];
                imageViewRotationed=YES;
            }
            
        }
            break;
        case YNStatueRefreshing:
        {
            animation=YES;
            self.superScrollview.contentInset = UIEdgeInsetsMake(self.contentOffSetY, self.superScrollview.contentInset.left, 0, self.superScrollview.contentInset.right);
            self.stateNoteLable.text=@"正在加载中...";
            self.refreshImageView.image=[UIImage imageNamed:@""];
            self.animationImageView.hidden=NO;
            [UIView animateWithDuration:0.25 animations:^{
                weakSelf.superScrollview.contentInset = UIEdgeInsetsMake(weakSelf.superScrollview.contentInset.top + headerRefeshViewHight, weakSelf.superScrollview.contentInset.left, -weakSelf.superScrollview.contentSize.height-headerRefeshViewHight, weakSelf.superScrollview.contentInset.right);
            }];
            CABasicAnimation* rotationAnimation;
            rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
            rotationAnimation.duration = 1;
            rotationAnimation.cumulative = YES;
            rotationAnimation.repeatCount = MAXFLOAT;
            [self.animationImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
            if (self.returnRefreshingBlock) {
                self.returnRefreshingBlock();
            }
            if (imageViewRotationed) {
                CGAffineTransform rotation=CGAffineTransformMakeRotation(2*M_PI);
                [self.refreshImageView setTransform:rotation];
                imageViewRotationed=NO;
            }
        }
            break;
        case YNStatueRefreshSuccessful:
        {
            self.stateNoteLable.text=@"加载成功";
            self.refreshImageView.image=[UIImage imageNamed:@"YNRefreshSource.bundle/HasBeenRefreshed.png"];
            [self.animationImageView.layer removeAllAnimations];
            self.animationImageView.hidden=YES;
            if (imageViewRotationed) {
                CGAffineTransform rotation=CGAffineTransformMakeRotation(2*M_PI);
                [self.refreshImageView setTransform:rotation];
                imageViewRotationed=NO;
            }
            [self performSelector:@selector(YNendHeadRefresh) withObject:nil afterDelay:1];
        }
            break;
        case YNStatueRefreshFailure:
        {
            self.stateNoteLable.text=@"加载失败";
            self.refreshImageView.image=[UIImage imageNamed:@"img_caution"];
            [self.animationImageView.layer removeAllAnimations];
            self.animationImageView.hidden=YES;
            if (imageViewRotationed) {
                CGAffineTransform rotation=CGAffineTransformMakeRotation(2*M_PI);
                [self.refreshImageView setTransform:rotation];
                imageViewRotationed=NO;
            }
            [self performSelector:@selector(YNendHeadRefresh) withObject:nil afterDelay:1];
        }
            break;
        case YNStatueRefreshNetworkAnomaly:
        {
            self.stateNoteLable.text=@"网络异常，请检查网络设置";
            self.refreshImageView.image=[UIImage imageNamed:@"img_caution"];
            [self.animationImageView.layer removeAllAnimations];
            self.animationImageView.hidden=YES;
            if (imageViewRotationed) {
                CGAffineTransform rotation=CGAffineTransformMakeRotation(2*M_PI);
                [self.refreshImageView setTransform:rotation];
                imageViewRotationed=NO;
            }
            [self performSelector:@selector(YNendHeadRefresh) withObject:nil afterDelay:1];
        }
            break;
        default:
            break;
    }
    CGFloat noteStringWith=[self.stateNoteLable sizeThatFits:CGSizeMake(MAXFLOAT, self.stateNoteLable.bounds.size.height)].width;
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.stateNoteLable.bounds=CGRectMake(0, 0, noteStringWith, weakSelf.stateNoteLable.bounds.size.height);
            weakSelf.refreshImageView.frame=CGRectMake(weakSelf.stateNoteLable.frame.origin.x-imageViewSize-15, (headerRefeshViewHight-imageViewSize)/2, imageViewSize, imageViewSize);
        }];
    }else{
        self.stateNoteLable.bounds=CGRectMake(0, 0, noteStringWith, self.stateNoteLable.bounds.size.height);
        self.refreshImageView.frame=CGRectMake(self.stateNoteLable.frame.origin.x-imageViewSize-15, (headerRefeshViewHight-imageViewSize)/2, imageViewSize, imageViewSize);
        
    }
}
#pragma 开始刷新
- (void)YNbeginRefreshing {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.currentState = YNStatueRefreshing;
}

#pragma 结束下拉刷新
-(void)YNendHeadRefresh {
    if (self.superScrollview==nil) {
        return;
    }
    //先复原防止意外缩进
    if (self.superScrollview.contentInset.top>=self.superScrollview.contentInset.top + headerRefeshViewHight) {
        [UIView animateWithDuration:0.3 animations:^{
            self.superScrollview.contentInset = UIEdgeInsetsMake(self.superScrollview.contentInset.top - headerRefeshViewHight, self.superScrollview.contentInset.left, 0, self.superScrollview.contentInset.right);
        } completion:^(BOOL finished) {
            self.currentState=YNStatueNomal;
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self.superScrollview.contentInset = UIEdgeInsetsMake(self.contentOffSetY, self.superScrollview.contentInset.left, 0, self.superScrollview.contentInset.right);
        } completion:^(BOOL finished) {
            self.currentState=YNStatueNomal;
        }];
    }
}
//刷新成功
-(void)refreshSuccessful{
    if (self.currentState==YNStatueRefreshing) {
        self.currentState=YNStatueRefreshSuccessful;
    }
}
//刷新失败
-(void)refreshFailue{
    if (self.currentState==YNStatueRefreshing) {
        self.currentState=YNStatueRefreshFailure;
    }
}
//网络异常
-(void)networkAnomaly{
    if (self.currentState==YNStatueRefreshing) {
        self.currentState=YNStatueRefreshNetworkAnomaly;
    }
}
#pragma mark __懒加载
-(UIImageView *)refreshImageView{
    if (_refreshImageView==nil) {
        _refreshImageView=[[UIImageView alloc]init];
        _refreshImageView.image=[UIImage imageNamed:@"YNRefreshSource.bundle/drop_downRefresh.png"];
        [self addSubview:_refreshImageView];
    }
    return _refreshImageView;
}
-(UIImageView *)animationImageView{
    if (_animationImageView==nil) {
        _animationImageView=[[UIImageView alloc]init];
        _animationImageView.image=[UIImage imageNamed:@"YNRefreshSource.bundle/ReleaseTheLoad.png"];
        [self.refreshImageView addSubview:_animationImageView];
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
        rotationAnimation.duration = 1;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = MAXFLOAT;
        [_animationImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
    return _animationImageView;
}
-(UILabel *)stateNoteLable{
    if (_stateNoteLable==nil) {
        _stateNoteLable=[[UILabel alloc]init];
        [self addSubview:_stateNoteLable];
        _stateNoteLable.font=[UIFont systemFontOfSize:15];
        _stateNoteLable.textColor=[UIColor darkGrayColor];
        _stateNoteLable.textAlignment=1;
        _stateNoteLable.backgroundColor=[UIColor clearColor];
    }
    return _stateNoteLable;
}
-(void)dealloc{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    @try {
        [self.superScrollview removeObserver:self forKeyPath:@"contentOffset"];
    } @catch (NSException *exception) {
        debugLog(@"多次删除KVO报错,不放在try里容易崩溃");
    }
}
@end
