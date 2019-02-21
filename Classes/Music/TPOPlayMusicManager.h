//
//  TPOPlayMusicManager.h
//  TOEFL
//
//  Created by 黄贤于 on 2018/7/9.
//  Copyright © 2018年 Langlib. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 播放状态
 - TPOPlayMusicStatusLoaded: 加载完成
 - TPOPlayMusicStautsPause: 暂停
 - TPOPlayMusicStautsPlaying: 播放中
 - TPOPlayMusicStautsEnd: 播放结束
 - TPOPlayMusicStatusFailed: 加载失败
 */
typedef NS_ENUM(NSInteger, TPOPlayMusicStatus) {
    TPOPlayMusicStatusLoaded = 0,
    TPOPlayMusicStatusPause,
    TPOPlayMusicStatusPlaying,
    TPOPlayMusicStatusEnd,
    TPOPlayMusicStatusFailed
};


@interface TPOPlayMusicManager : NSObject


/**
 单例 使用单利 控制器销毁时是要seek到0
 */
+ (TPOPlayMusicManager *)sharePlayMusicManager;


/**
 是否需要精确的获取总时间 默认为NO
 如果需要设置 在playMusicWithUrl之前调用
 
 @param isPrecis YES:精确间但加载时间长, NO:偶尔不精确但加载时间快速
 */
- (void)precisDuration:(BOOL)isPrecis;

/**
 播放url
 */
- (void)playMusicWithUrl:(NSURL *)url;

/**
 播放时间回调

 @param currentTime 当前时间
 @param totalTime 总时间
 */
- (void)playMusicWithCurrentTime:(void (^) (NSTimeInterval currentTime))currentTime totalTime:(void (^) (NSTimeInterval totalTime))totalTime;

/**
 播放状态
 */
- (void)playMusicStauts:(void (^) (TPOPlayMusicStatus status)) status;

/**
 播放
 */
- (void)play;

/**
 暂停
 */
- (void)pause;

/**
 改变播放进度 completionHandle完成后的回调
 */
- (void)seekToTime: (NSTimeInterval)time completionHandle:(void (^) (void))completionHandle;

/**
 改变播放音量 默认0.5
 */
- (void)changeToVolume:(CGFloat)volume;

/**
 获取当期播放音量
 */
- (CGFloat)volume;

/**
 关闭播放器 使用init创建 不用时要关闭播放器
 */
- (void)closeMusicPlayer;

@end
