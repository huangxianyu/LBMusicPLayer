//
//  LBMusicPlayerView.m
//  TOEFL
//
//  Created by 黄贤于 on 2018/12/29.
//  Copyright © 2018年 Langlib. All rights reserved.
//

#import "LBMusicPlayerView.h"
#import "TPOPlayMusicManager.h"
#import "Masonry.h"
#import "UIColor+Hex.h"
#import "LBMusicPlayerCommand.h"

@interface LBMusicPlayerSlider : UISlider
@property (nonatomic,assign) BOOL isThumb;
@end

@implementation LBMusicPlayerSlider
// 改变slider滑道的高的
- (CGRect)trackRectForBounds:(CGRect)bounds {
    return CGRectMake(0, (self.frame.size.height-3)/2.0, CGRectGetWidth(self.frame), 3);
}
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGFloat d = _isThumb ? 3 : 0;
    rect.origin.x = rect.origin.x - d;
    rect.size.width = rect.size.width + d*2;
    return CGRectInset ([super thumbRectForBounds:bounds trackRect:rect value:value], d, d);
}
@end



@interface LBMusicPlayerView ()

@property (nonatomic,strong) UIView *bgView;

@property (nonatomic,strong) UIButton *playButton;

@property (nonatomic,strong) LBMusicPlayerSlider *slider;

@property (nonatomic,assign) LBMusicPlayerThumbType type;

@property (nonatomic,strong) TPOPlayMusicManager *musicManager;

@property (nonatomic,strong) UILabel *currentTimeLabel;

@property (nonatomic,strong) UILabel *totalTimeLabel;
@property (nonatomic,assign) BOOL isPrecis;

@property (nonatomic,assign) BOOL thumbEnabled;
@property (nonatomic,assign) BOOL sliderEnabled;

@property (nonatomic,copy) void (^completion) (void);
@property (nonatomic,copy) void (^playAction) (void);
@property (nonatomic,copy) void (^pauseAction) (void);
@property (nonatomic,copy) void (^loadCompletion) (BOOL completion);

@end

@implementation LBMusicPlayerView

- (instancetype)initWithPlayerType:(LBMusicPlayerThumbType)type frame:(CGRect)frame; {
    if (self = [super initWithFrame:frame]) {
        _type = type;
        _isPrecis = NO;
        [self customView];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        _isPrecis = NO;
        [self customView];
    }
    return self;
}

- (void)customView {
    _thumbEnabled = YES;
    _sliderEnabled = YES;
    [self addSubview:self.bgView];
    [self addSubview:self.playButton];
    [self addSubview:self.totalTimeLabel];
    [self addSubview:self.currentTimeLabel];
    [self addSubview:self.slider];
}

- (void)precisDuration:(BOOL)isPrecis {
    _isPrecis = isPrecis;
}

- (void)playWithUrl:(NSURL *)url {
    
    [self.musicManager precisDuration:_isPrecis];
    [self.musicManager playMusicWithUrl:url];
    
    __weak typeof (self) weakSelf = self;
    
    [self.musicManager playMusicStauts:^(TPOPlayMusicStatus status) {
        
        if (status == TPOPlayMusicStatusEnd) {
            
            if (weakSelf.type == LBMusicPlayerThumbDefault && weakSelf.sliderEnabled) {
                weakSelf.slider.userInteractionEnabled = weakSelf.thumbEnabled;
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [weakSelf.musicManager seekToTime:0 completionHandle:^{

                    weakSelf.currentTimeLabel.text = @"00:00";

                    weakSelf.playButton.selected = YES;
                    [weakSelf.playButton setImage:LBMusicPlayerBuldleImage(@"audiostrip_play_button") forState:UIControlStateSelected | UIControlStateHighlighted];

                    if (weakSelf.completion) {
                        weakSelf.completion();
                    }
                }];
            });
            
            
        } else if (status == TPOPlayMusicStatusPlaying) {
            
            if (weakSelf.type == LBMusicPlayerThumbDefault && weakSelf.sliderEnabled) {
                weakSelf.slider.userInteractionEnabled = YES;
            }
            
            weakSelf.playButton.selected = NO;
            [weakSelf.playButton setImage:LBMusicPlayerBuldleImage(@"audiostrip_pause_button") forState:UIControlStateHighlighted];
            
        } else if (status == TPOPlayMusicStatusPause){
            
            if (weakSelf.type == LBMusicPlayerThumbDefault && weakSelf.sliderEnabled) {
                weakSelf.slider.userInteractionEnabled = weakSelf.thumbEnabled;
            }
            
            weakSelf.playButton.selected = YES;
            [weakSelf.playButton setImage:LBMusicPlayerBuldleImage(@"audiostrip_play_button") forState:UIControlStateSelected | UIControlStateHighlighted];
        }
    }];
    
    [self.musicManager playMusicWithCurrentTime:^(NSTimeInterval currentTime) {
        
        weakSelf.currentTimeLabel.text = [weakSelf timeWithValue:floor(currentTime)];
        weakSelf.slider.value = floor(currentTime);
        
    } totalTime:^(NSTimeInterval totalTime) {
        
        if (totalTime > 0) {
            weakSelf.totalTimeLabel.text = [NSString stringWithFormat:@"/%@",[weakSelf timeWithValue:floor(totalTime)]];
            weakSelf.slider.maximumValue = floor(totalTime);
            
            if (weakSelf.loadCompletion) {
                weakSelf.loadCompletion(YES);
            }
        }
    }];
}


// ************** action ***********

- (void)playButtonAction:(UIButton *)button {
    button.selected = !button.selected;
    
    if (button.isSelected) {
        if (self.pauseAction) {
            self.pauseAction();
        } else {
            [self pauseMusic];
        }
    } else {
        if (self.playAction) {
            self.playAction();
        } else {
            [self playMusic];
        }
    }
}

- (void)sliderChangeAction:(LBMusicPlayerSlider *)slider {
    __weak typeof (self) weakSelf = self;
    [self.musicManager seekToTime:slider.value completionHandle:^{
        [weakSelf playMusic];
    }];
}

- (void)setPlayerBackgroundColor:(UIColor *)backgroundColor {
    _bgView.backgroundColor = backgroundColor;
}

- (void)pauseMusic {
    [self.musicManager pause];
}

- (void)playMusic {
    [self.musicManager play];
}

- (void)playCompletion:(void (^) (void))playCompletion {
    _completion = playCompletion;
}

- (void)playAction:(void (^) (void))action {
    _playAction = action;
}

- (void)pauseAction:(void (^) (void))action {
    _pauseAction = action;
}

- (void)seekToZero {
    __weak typeof (self) weakSelf = self;
    [self.musicManager seekToTime:0 completionHandle:^{
        weakSelf.slider.value = 0;
        weakSelf.currentTimeLabel.text = @"00:00";
    }];
}

- (void)clearStauts {
    [self seekToZero];
    [self pauseMusic];
    self.totalTimeLabel.text = @"/00:00";
    self.slider.maximumValue = 0;
}

- (void)setPlayerThumbType:(LBMusicPlayerThumbType)type {
    _type = type;
    if (_type == LBMusicPlayerThumbDefault) {
        [_slider setThumbImage:LBMusicPlayerBuldleImage(@"audiostrip_schedule_icon") forState:UIControlStateNormal];
        _slider.isThumb = YES;
        _slider.userInteractionEnabled = YES;
    } else {
        [_slider setThumbImage:[self originImage:LBMusicPlayerBuldleImage(@"music_thumb1") scaleToSize:CGSizeMake(0.1, 0.1)] forState:UIControlStateNormal];
        _slider.isThumb = NO;
        _slider.userInteractionEnabled = NO;
    }
}

- (void)closeMusicPlayer {
    [self.musicManager closeMusicPlayer];
}

- (void)setThumbuEnabledWhenPause:(BOOL)enabled {
    if (_sliderEnabled) {
        self.slider.userInteractionEnabled = enabled;
        _thumbEnabled = enabled;
    }
}

- (void)setSliderEnable:(BOOL)enabled; {
    self.slider.userInteractionEnabled = enabled;
    _sliderEnabled = enabled;
}

- (void)setThumbEnable:(BOOL)enabled {
    self.slider.userInteractionEnabled = enabled;
}

- (void)loadCompletion:(void (^)(BOOL))completion {
    _loadCompletion = completion;
}

// ************** create ***********
- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init]; //WithFrame:self.bounds];
        _bgView.backgroundColor = [UIColor colorWithHexString:@"#f3f3f3"];
        _bgView.layer.cornerRadius = kScaleWidth(49/2.0);
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.selected = YES;
        _playButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_playButton setImage:LBMusicPlayerBuldleImage(@"audiostrip_pause_button") forState:UIControlStateNormal];
        [_playButton setImage:LBMusicPlayerBuldleImage(@"audiostrip_play_button") forState:UIControlStateSelected];
        [_playButton setImage:LBMusicPlayerBuldleImage(@"audiostrip_play_button") forState:UIControlStateSelected | UIControlStateHighlighted];
        [_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (LBMusicPlayerSlider *)slider {
    if (!_slider) {
        _slider = [[LBMusicPlayerSlider alloc] init];
        _slider.minimumValue = 0;
        //UIImage *minimumImage = [[UIImage imageNamed:@"music_track_s"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeStretch];
        [_slider setMinimumTrackImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#fda900"]] forState:UIControlStateNormal];
        [_slider setMaximumTrackImage:LBMusicPlayerBuldleImage(@"music_track_n2") forState:UIControlStateNormal];
        
        if (_type == LBMusicPlayerThumbDefault) {
            [_slider setThumbImage:LBMusicPlayerBuldleImage(@"audiostrip_schedule_icon") forState:UIControlStateNormal];
            _slider.isThumb = YES;
            _slider.userInteractionEnabled = YES;
        } else {
            [_slider setThumbImage:[self originImage:LBMusicPlayerBuldleImage(@"music_thumb1") scaleToSize:CGSizeMake(0.1, 0.1)] forState:UIControlStateNormal];
            _slider.isThumb = NO;
            _slider.userInteractionEnabled = NO;
        }
        
        [_slider addTarget:self action:@selector(sliderChangeAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.font = [UIFont fontWithName:kFontNameRegular size:kScaleWidth(12)];
        _currentTimeLabel.textColor = [UIColor colorWithHexString:@"#fda900"];
        _currentTimeLabel.textAlignment = NSTextAlignmentRight;
        _currentTimeLabel.text = @"00:00";
    }
    return _currentTimeLabel;
}

- (UILabel *)totalTimeLabel {
    if (!_totalTimeLabel) {
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.font = [UIFont fontWithName:kFontNameLigth size:kScaleWidth(12)];
        _totalTimeLabel.textColor = [UIColor colorWithHexString:@"#3a4246"];
        _totalTimeLabel.text = @"/00:00";
    }
    return _totalTimeLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView).offset(kScaleWidth(10));
        make.centerY.equalTo(self.bgView);
        make.height.width.mas_equalTo(kScaleWidth(33));
    }];
    
    [_totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.right.equalTo(self.bgView);
        make.width.mas_equalTo(kScaleWidth(52));
        make.height.mas_equalTo(kScaleWidth(17));
    }];
    
    [_currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bgView);
        make.right.equalTo(self.totalTimeLabel.mas_left);
        make.width.mas_equalTo(kScaleWidth(45));
        make.height.mas_equalTo(kScaleWidth(17));
    }];
    
    [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playButton.mas_right).offset(kScaleWidth(10));
        make.right.equalTo(self.currentTimeLabel.mas_left);
        make.centerY.equalTo(self.bgView);
        make.height.equalTo(self.currentTimeLabel);
    }];
}

- (TPOPlayMusicManager *)musicManager {
    if (!_musicManager) {
        _musicManager = [[TPOPlayMusicManager alloc] init];
    }
    return _musicManager;
}

- (NSMutableAttributedString *)attributedStringWithText:(NSString *)text {
    
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:text];
    [attributed addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFontNameRegular size:kScaleWidth(12)] range:NSMakeRange(0, text.length)];
    [attributed addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#ff8800"] range:NSMakeRange(0, 5)];
    [attributed addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#999999"] range:NSMakeRange(5, text.length-5)];
    
    return attributed;
}

- (NSString *)timeWithValue:(NSInteger)value{
    
    int seconds = value % 60;
    int minutes = (value / 60) % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d", minutes,seconds];
}

-(UIImage *)originImage:(UIImage*)image scaleToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage *scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


@end
