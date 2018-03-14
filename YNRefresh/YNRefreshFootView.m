//
//  YNRefreshFootView.m
//  Messenger
//
//  Created by YN on 2017/7/11.
//  Copyright © 2017年 YN-APP-iOS. All rights reserved.
//

#import "YNRefreshFootView.h"

const static float footLoadViewHight=40;
const static float imageViewSize=20;

@interface YNRefreshFootView()
/**HX** tableView弱引用 **/
@property(nonatomic,weak)UITableView *superScrollview;
/**HX** 记录scrollView初始时的fram **/
@property(nonatomic,assign)CGRect initFram;
@end
@implementation YNRefreshFootView
-(instancetype)init{
    if (self=[super initWithFrame:CGRectMake(0, 0, ScreenWidth, footLoadViewHight)]) {
        [self setUpUI];
    }
    return self;
}
-(void)setUpUI{
    self.stateNoteLable.bounds=CGRectMake(0, 0, 20, 20);
    self.stateNoteLable.center=CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.refreshImageView.frame=CGRectMake(CGRectGetMidX(self.stateNoteLable.frame)-imageViewSize-15, (footLoadViewHight-imageViewSize)/2, imageViewSize, imageViewSize);
    self.animationImageView.frame=CGRectMake(0, 0, imageViewSize, imageViewSize);
    
}
#pragma mark __添加观察者
-(void)willMoveToSuperview:(UIView *)newSuperview{
    if (self.superScrollview) {//初始过了就不再初始化
        return;
    }
    [super willMoveToSuperview:newSuperview];
    //加上这句，可以在控件在自动布局和非自动布局下都能获取到它的bounds的准确值
    [newSuperview layoutIfNeeded];
    /**HX** 为满足现在项目的需求这里是只能针对tableview进行封装 **/
    if (![newSuperview isKindOfClass:[UITableView class]]) return;
    if (newSuperview) {
        self.superScrollview = (UITableView *)newSuperview;
        self.currentState = YNStatueLoadNomal;
        @try {
            [self.superScrollview removeObserver:self forKeyPath:@"contentOffset"];
            [self.superScrollview removeObserver:self forKeyPath:@"contentSize"];
        } @catch (NSException *exception) {
            debugLog(@"多次删除KVO报错,不放在try里容易崩溃");
        }
        [self.superScrollview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [self.superScrollview addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
//        self.superScrollview.tableFooterView=self;//这个方法会再次触发调用-(void)willMoveToSuperview:(UIView *)newSuperview这个方法
    }else {
        if (self.superScrollview) {
            @try {
                [self.superScrollview removeObserver:self forKeyPath:@"contentOffset"];
                [self.superScrollview removeObserver:self forKeyPath:@"contentSize"];
            } @catch (NSException *exception) {
                debugLog(@"多次删除KVO报错,不放在try里容易崩溃");
            }
            
        }
    }
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentSize"]) {
        if (self.superScrollview.contentSize.height<self.superScrollview.bounds.size.height) {
            self.hidden=YES;
        }else{
            self.hidden=NO;
        }
    }
    if ([keyPath isEqualToString:@"contentOffset"])
    {
        if (self.currentState==YNStatueNomoreData||self.superScrollview.contentInset.top>0||self.hidden) {
            /**HX** 没有更多数据、正在下拉刷新中、已经隐藏则不做操作 **/
            return;
        }else{
            /**HX** 先判断是上拉还是下拉 **/
            static float lastPosition = 0;
            float currentPostion = self.superScrollview.contentOffset.y;
            
            if(self.superScrollview.isDragging)
            {
                if (currentPostion - lastPosition > 0) {//上拉
                    
                    lastPosition = currentPostion;
                    if((currentPostion + self.superScrollview.bounds.size.height) >= self.superScrollview.contentSize.height+10&&self.currentState != YNStatueLoading)
                    {
                        //上拉到空白区出现10的距离时开始加载
                        self.currentState = YNStatueLoading;
                    }
                }else{//下拉
                    lastPosition = currentPostion;
                }
                
            }else{
                
            }
        }
    }
}
-(void)setCurrentState:(LoadState)currentState{
    if (self.superScrollview==nil) {
        return;
    }
    _currentState=currentState;
    [self performSelectorOnMainThread:@selector(setState) withObject:nil waitUntilDone:NO];
}
-(void)setState{
    BOOL animation =NO;
    switch (_currentState) {
        case YNStatueLoadNomal:
        {
            self.stateNoteLable.text=@"查看更多";
            self.refreshImageView.image=[UIImage imageNamed:@""];
            [self.animationImageView.layer removeAllAnimations];
            self.animationImageView.hidden=YES;
        }
            break;
        case YNStatueUpPulling:
        {
            
        }
            break;
        case YNStatueLoading:
        {
            animation=YES;
            self.stateNoteLable.text=@"正在加载...";
            self.refreshImageView.image=[UIImage imageNamed:@""];
            self.animationImageView.hidden=NO;
            CABasicAnimation* rotationAnimation;
            rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
            rotationAnimation.duration = 1;
            rotationAnimation.cumulative = YES;
            rotationAnimation.repeatCount = MAXFLOAT;
            [self.animationImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
            if (self.returnLoadingBlock) {
                self.returnLoadingBlock();
            }
        }
            break;
        case YNStatueNomoreData:
        {
            self.stateNoteLable.text=@"没有了，已经到底啦！";
            self.refreshImageView.image=[UIImage imageNamed:@""];
            [self.animationImageView.layer removeAllAnimations];
            self.animationImageView.hidden=YES;
        }
            break;
        case YNStatueLoadFailure:
        {
            self.stateNoteLable.text=@"加载失败，请重试";
            self.refreshImageView.image=[UIImage imageNamed:@"img_caution"];
            [self.animationImageView.layer removeAllAnimations];
            self.animationImageView.hidden=YES;
        }
            break;
        case YNStatueNetworkAnomaly:
        {
            self.stateNoteLable.text=@"网络异常，请检测网络设置";
            self.refreshImageView.image=[UIImage imageNamed:@"img_caution"];
            [self.animationImageView.layer removeAllAnimations];
            self.animationImageView.hidden=YES;
        }
            break;
        default:
            break;
    }
    CGFloat noteStringWith=[self.stateNoteLable sizeThatFits:CGSizeMake(MAXFLOAT, self.stateNoteLable.bounds.size.height)].width;
    if (animation) {
        weak_Self(weakSelf);
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.stateNoteLable.bounds=CGRectMake(0, 0, noteStringWith, weakSelf.stateNoteLable.bounds.size.height);
            weakSelf.refreshImageView.frame=CGRectMake(weakSelf.stateNoteLable.frame.origin.x-imageViewSize-15, (footLoadViewHight-imageViewSize)/2, imageViewSize, imageViewSize);
        }];
    }else{
        self.stateNoteLable.bounds=CGRectMake(0, 0, noteStringWith, self.stateNoteLable.bounds.size.height);
        self.refreshImageView.frame=CGRectMake(self.stateNoteLable.frame.origin.x-imageViewSize-15, (footLoadViewHight-imageViewSize)/2, imageViewSize, imageViewSize);
        
    }
}
#pragma 开始加载
- (void)YNbeginLoading {
    
    self.currentState = YNStatueLoading;
}
//加载成功，（查看更多）
-(void)loadSuccessful_lookMore{
    self.currentState=YNStatueLoadNomal;
}
//加载成功，（没有了）
-(void)loadSuccessful_nomoreData{
    self.currentState=YNStatueNomoreData;
}
//加载失败
-(void)loadFailue{
    self.currentState=YNStatueLoadFailure;
}
//网络异常
-(void)networkAnomaly{
    self.currentState=YNStatueNetworkAnomaly;
}
#pragma mark __懒加载
-(UIImageView *)refreshImageView{
    if (_refreshImageView==nil) {
        _refreshImageView=[[UIImageView alloc]init];
        _refreshImageView.image=[UIImage imageNamed:@"img_caution"];
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
        [self.superScrollview removeObserver:self forKeyPath:@"contentSize"];
    } @catch (NSException *exception) {
        debugLog(@"多次删除KVO报错,不放在try里容易崩溃");
    }
}

@end
