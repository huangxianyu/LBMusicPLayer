//
//  LBMusicPlayerView.h
//  TOEFL
//
//  Created by 黄贤于 on 2018/12/29.
//  Copyright © 2018年 Langlib. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 是否隐藏thumb
 
 - TPOMusicPlayerThumbDefault: 不隐藏
 - TPOMusicPlayerThumbHide: 隐藏
 */
typedef NS_ENUM(NSInteger, LBMusicPlayerThumbType) {
    LBMusicPlayerThumbDefault = 0,
    LBMusicPlayerThumbHide
};

@interface LBMusicPlayerView : UIView

- (instancetype)initWithPlayerType:(LBMusicPlayerThumbType)type frame:(CGRect)frame;

- (void)setPlayerThumbType:(LBMusicPlayerThumbType)type;

/**
 是否需要精确的获取总时间 默认为NO
 如果需要设置 在playMusicWithUrl之前调用
 
 @param isPrecis YES:精确间但加载时间长, NO:偶尔不精确但加载时间快速
 */
- (void)precisDuration:(BOOL)isPrecis;

// 播放url
- (void)playWithUrl:(NSURL *)url;

// 播放完成回调
- (void)playCompletion:(void (^) (void))playCompletion;

// 暂停
- (void)pauseMusic;

// 播放
- (void)playMusic;

- (void)closeMusicPlayer;

// 设置当暂停时是否可以拖动 默认可以
- (void)setThumbuEnabledWhenPause:(BOOL)enabled;

// 设置进度条用户交互
- (void)setSliderEnable:(BOOL)enabled;

// 设置背景色 默认#FAFAFA
- (void)setPlayerBackgroundColor:(UIColor *)backgroundColor;

// 点击播放按钮事件 手动调用播放
- (void)playAction:(void (^) (void))action;

- (void)pauseAction:(void (^) (void))action;

// 加载完成
- (void)loadCompletion:(void (^) (BOOL completion))completion;

- (void)seekToZero;

// 清空所有状态
- (void)clearStauts;


@end

NS_ASSUME_NONNULL_END
