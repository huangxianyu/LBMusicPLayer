//
//  TPOPlayMusicManager.m
//  TOEFL
//
//  Created by 黄贤于 on 2018/7/9.
//  Copyright © 2018年 Langlib. All rights reserved.
//

#import "TPOPlayMusicManager.h"
#import <AVFoundation/AVFoundation.h>

@interface TPOPlayMusicManager () <AVAssetResourceLoaderDelegate>

@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic,strong) AVPlayer *player;

@property (nonatomic,strong) id timeObserver;
@property (nonatomic,assign) NSTimeInterval totalTime;
@property (nonatomic,assign) BOOL isPrecis;

@property (nonatomic,copy) void (^currentTime) (NSTimeInterval currentTime);
@property (nonatomic,copy) void (^totalTimeBlock) (NSTimeInterval totalTime);
@property (nonatomic,copy) void (^status) (TPOPlayMusicStatus status);

@property (nonatomic,strong) NSURL *url;

@property (nonatomic,assign) NSInteger retryTime; // 加载失败重试次数3

@end

static NSString *const kPlayMusicManager = @"kPlayMusicManager";

@implementation TPOPlayMusicManager

+ (instancetype)sharePlayMusicManager {
    static TPOPlayMusicManager *playMusicManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!playMusicManager) {
            //playMusicManager = [[super allocWithZone:NULL] init];
            playMusicManager = [[TPOPlayMusicManager alloc] init];
        }
    });
    return playMusicManager;
}

- (AVPlayer *)player {
    if (!_player) {
        _player = [[AVPlayer alloc] init];
        _player.volume = 0.5;
        if (@available(iOS 10.0, *)) {
            [_player setAutomaticallyWaitsToMinimizeStalling:NO]; // 禁止下载完成再播放
        }
        [self playerAddTimeObserver];
        self.isPrecis = NO;
    }
    return _player;
}

- (instancetype)init {
    if (self = [super init]) {
        self.retryTime = 3;
        [self setAudioSession];
    }
    return self;
}

- (void)setAudioSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [audioSession setActive:YES error:nil];
}

- (void)playerAddTimeObserver {
    __weak typeof (self) weakSelf = self;
    
    weakSelf.timeObserver = [weakSelf.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:nil usingBlock:^(CMTime time) {
        if (weakSelf.player.currentTime.timescale > 0) {
            NSTimeInterval currentTime = weakSelf.player.currentTime.value/weakSelf.player.currentTime.timescale;
            if (weakSelf.currentTime) {
                weakSelf.currentTime(currentTime);
            }
        }
    }];
}


- (void)precisDuration:(BOOL)isPrecis {
    _isPrecis = isPrecis;
}

- (void)playMusicWithUrl:(NSURL *)url {
    if (url) {
        
        self.url = url;
        
        if ([[UIDevice currentDevice].systemVersion doubleValue] < 11.0) {
            _isPrecis = YES;
        }
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:@{AVURLAssetPreferPreciseDurationAndTimingKey:@(_isPrecis)}];
        
        self.asset = asset;
        
        NSArray *keys = @[@"duration"]; //tracks,playable,duration
        
        __weak typeof(self) weakSelf = self;
        // 子线程加载数据
        [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
                
            for (NSString *key in keys) {
                NSError *error = nil;
                AVKeyValueStatus keyStatus = [asset statusOfValueForKey:key error:&error];
                
                switch (keyStatus) {
                    case AVKeyValueStatusUnknown:{
                        
                        if (weakSelf.retryTime <= 0) {
                            if (weakSelf.status) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    weakSelf.status(TPOPlayMusicStatusFailed);
                                });
                            }
                        } else {
                            [weakSelf playMusicWithUrl:url];
                            weakSelf.retryTime--;
                        }
                        return;
                    }
                    case AVKeyValueStatusLoading:{
                        break;
                    }
                    case AVKeyValueStatusLoaded:{
                        weakSelf.retryTime = 3;
                        // 非当前播放音频，产生的加载回调不播放
                        if(![url.path isEqualToString:weakSelf.url.path]) return;
                        if (weakSelf.status) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                weakSelf.status(TPOPlayMusicStatusLoaded);
                            });
                        }
                        break;
                    }
                    case AVKeyValueStatusFailed:{
                        if (weakSelf.retryTime <= 0) {
                            if (weakSelf.status) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    weakSelf.status(TPOPlayMusicStatusFailed);
                                });
                            }
                        } else {
                            [weakSelf playMusicWithUrl:url];
                            weakSelf.retryTime--;
                        }
                        return;
                    }
                    case AVKeyValueStatusCancelled:{
                        break;
                    }
                    default:
                        break;
                }
            }
            
            // check playable
            if (!asset.playable) { // 不能播放
                if (weakSelf.status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.status(TPOPlayMusicStatusFailed);
                    });
                }
                return;
            }
            
            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
            weakSelf.playerItem = playerItem;
            [weakSelf.player replaceCurrentItemWithPlayerItem:playerItem];
            weakSelf.totalTime = CMTimeGetSeconds(asset.duration);
            if (weakSelf.totalTimeBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.totalTimeBlock(weakSelf.totalTime);
                });
            }
            [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
            
        }];
    }
}

/**
 播放时间回调
 
 @param currentTime 当前时间
 @param totalTime 总时间
 */
- (void)playMusicWithCurrentTime:(void (^) (NSTimeInterval currentTime))currentTime totalTime:(void (^) (NSTimeInterval totalTime))totalTime {
    _currentTime = currentTime;
    _totalTimeBlock = totalTime;
}

/**
 播放状态
 */
- (void)playMusicStauts:(void (^) (TPOPlayMusicStatus status)) status {
    _status = status;
}

/**
 播放
 */
- (void)play {
    
    if (@available(iOS 10.0, *)) {
        [self.player playImmediatelyAtRate:1.0]; // 可以设置多倍速播放
    } else {
        [self.player play];
    }
    
    if (self.status) {
        self.status(TPOPlayMusicStatusPlaying);
    }
}

/**
 暂停
 */
- (void)pause {
    [self.player pause];
    if (self.status) {
        self.status(TPOPlayMusicStatusPause);
    }
}

/**
 播放结束
 */
- (void)playEnd {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    if (self.status) {
        self.status(TPOPlayMusicStatusEnd);
    }
}

/**
 改变播放进度
 */
- (void)seekToTime:(NSTimeInterval)time completionHandle:(void (^) (void))completionHandle {
    [self.player pause];
    [self.player seekToTime:CMTimeMakeWithSeconds(time, self.player.currentTime.timescale) completionHandler:^(BOOL finished) {
        if (finished) {
            //[self.player play];
            if (completionHandle) {
                completionHandle();
            }
        }
    }];
}

/**
 改变播放音量
 */
- (void)changeToVolume:(CGFloat)volume {
    self.player.volume = volume;
}

/**
 获取当期播放音量
 */
- (CGFloat)volume {
    return self.player.volume;
}

/**
 关闭播放器
 */
- (void)closeMusicPlayer {
    
    !_status?:_status(TPOPlayMusicStatusEnd);
    [_player removeTimeObserver:self.timeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
    
    _url = nil;
    _asset = nil;
    _timeObserver = nil;
    _player = nil;
    _playerItem = nil;
    _currentTime = nil;
    _totalTimeBlock = nil;
    _status = nil;
    _totalTime = 0;
}

@end
