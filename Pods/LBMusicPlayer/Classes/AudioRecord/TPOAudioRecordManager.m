//
//  TPOAudioRecordManager.m
//  Meeting
//
//  Created by 黄贤于 on 2018/7/14.
//  Copyright © 2018年 com.newchinese. All rights reserved.
//

#import "TPOAudioRecordManager.h"

//#include "lame.h"

@interface TPOAudioRecordManager () <AVAudioRecorderDelegate>

@property (nonatomic,strong) AVAudioRecorder *audioRecorder;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) NSString *urlName;
@property (nonatomic,assign) CGFloat recordTime;
@property (nonatomic,assign) BOOL isFinish;

@property (nonatomic,copy) void (^power) (CGFloat power);
@property (nonatomic,copy) void (^complete) (BOOL isSuccess, NSURL *recordUrl);
@property (nonatomic,copy) void (^success) (BOOL success);

@end

@implementation TPOAudioRecordManager

- (instancetype)init {
    if (self = [super init]) {
        [self setAudioSession];
    }
    return self;
}

/**
 设置音频会话
 */
//- (void)setAudioSession {
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
//    //[audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil]; // 允许在蓝牙状态下录音和播放
//    [audioSession setActive:YES error:nil];
//    // 解决录音音量小
//    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
//}

- (void)setAudioSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [audioSession setActive:YES error:nil];
}

/**
 录音之前先设置录音保存路径名
 */
- (void)setRecordUrlName:(NSString *)urlName {
    _urlName = urlName;
}


/**
 录音临时文件保存位置
 */
- (NSString *)getRecordSavePath {
    
    NSString *pathStr =[NSTemporaryDirectory() stringByAppendingPathComponent:@"Langlib"];
    
    NSFileManager *fileM = [NSFileManager defaultManager];
    // 创建路径
    if (![fileM fileExistsAtPath:pathStr]) {
        [fileM createDirectoryAtPath:pathStr withIntermediateDirectories:YES attributes:nil error:nil];
    }
    // 录音保存名字 如果需要转码 文件名后不能加后缀
    pathStr = [pathStr stringByAppendingString:@"/audioRecord"];
    
    //NSLog(@"%@",pathStr);
    
    return pathStr;
}

// 播放文件保存位置
- (NSString *)getPayerSavePath {
    
    NSString *pathStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    pathStr = [pathStr stringByAppendingString:@"/Langlib"];
    
    NSFileManager *fileM = [NSFileManager defaultManager];
    
    if (![fileM fileExistsAtPath:pathStr]) {
        [fileM createDirectoryAtPath:pathStr withIntermediateDirectories:YES attributes:nil error:nil];
    }
    pathStr = [pathStr stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.aac",_urlName]];
    
    NSLog(@"%@",pathStr);
    
    return pathStr;
}


/**
 录音设置
 */
- (NSDictionary *)getAudioSetting {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    // 录音格式
    [dict setObject:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
    // 采样频率 和转码保持一致
    [dict setObject:@(44100) forKey:AVSampleRateKey];
    // 录音通道 如需转码设置为2
    [dict setObject:@(1) forKey:AVNumberOfChannelsKey];
    // 每个采样点位数,分为8、16、24、32 设置后转码时间不准
    [dict setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    // 是否使用浮点数采样 设置后转码声音有问题
    [dict setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    // 录音质量
    [dict setObject:@(AVAudioQualityHigh) forKey:AVEncoderAudioQualityKey];
    
    return dict;
}

/**
 创建录音机
 */
- (AVAudioRecorder *)audioRecorder {
    if (!_audioRecorder) {
        
        NSURL *url = [NSURL fileURLWithPath:[self getPayerSavePath]];
        NSDictionary *dict = [self getAudioSetting];
        NSError *error = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:dict error:&error];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES; // 监听音波
        if (error) {
            NSLog(@"创建录音机时出错:%@",error.localizedDescription);
            if (self.success) {
                self.success(NO);
            }
            return nil;
        } else {
            if (self.success) {
                self.success(YES);
            }
        }
    }
    return _audioRecorder;
}


/**
 录音音波监控
 
 @return 定时器
 */
- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _timer;
}

/**
 录音音波设置
 */
- (void)audioPowerChange {
    // 更新测量值
    [self.audioRecorder updateMeters];
    // 获取第一个通道的音频, 音频强度范围: -160到0
    CGFloat power = [self.audioRecorder averagePowerForChannel:0];
    CGFloat progress = (1.0/160.0) * (power+160.0);
    if (self.power) {
        self.power(progress);
    }
}


/**
 开始录音
 */
- (void)record:(void (^) (BOOL success))success {
    _success = success;
    [self setAudioSession];
    if (![self.audioRecorder isRecording]) {
        _isFinish = NO;
        [self.audioRecorder record];
        self.timer.fireDate = [NSDate distantPast];
    }
}

/**
 暂停录音
 */
- (void)pause {
    if ([self.audioRecorder isRecording]) {
        
        [self.audioRecorder pause];
        self.timer.fireDate = [NSDate distantFuture];
    }
}

/**
 恢复录音
 恢复录音只需要再次调用record，AVAudioSession会帮助你记录上次录音位置并追加录音
 */
- (void)resume {
    [self record:_success];
}

/**
 停止录音
 */
- (void)recordComplete:(void (^) (BOOL isSuccess, NSURL *recordUrl))complete {
    _complete = complete;
    NSLog(@"--- %f",_audioRecorder.currentTime);
    _recordTime = _audioRecorder.currentTime;
    [_audioRecorder stop];
    _audioRecorder = nil;
    _timer.fireDate=[NSDate distantFuture];
    [_timer invalidate];
    _timer = nil;
}

- (BOOL)isRecording {
    return _audioRecorder.isRecording;
}

/**
 获取录音时间
 */
- (NSInteger)getRecordTotalTime {

    return round(_recordTime); // 四舍五入
    //return _recordTime;
}


/**
 录音音波大小 0 - 1
 
 @param power 回调
 */
- (void)getRecordPower:(void (^) (CGFloat power))power {
    _power = power;
}

/**
 获取录音文件路径
 */
- (NSURL *)getRecordUrl {
    return [NSURL fileURLWithPath:[self getPayerSavePath]];
}

/**
 删除录音文件
 */
- (void)deleteRecordFile {
    NSFileManager *fileM = [NSFileManager defaultManager];
    if ([fileM fileExistsAtPath:[self getPayerSavePath]]) {
        [fileM removeItemAtPath:[self getPayerSavePath] error:nil];
    }
    if ([fileM fileExistsAtPath:[self getRecordSavePath]]) {
        [fileM removeItemAtPath:[self getRecordSavePath] error:nil];
    }
}



/**
 Delegate - 录制完成
 
 @param flag 是否成功
 */
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    
    //_isFinish = YES;
    //[self pcmToMp3];
    if (_complete) {
        _complete(flag, [NSURL fileURLWithPath:[self getPayerSavePath]]);
    }
}

/**
 pcm转MP3
 */
/*
- (void)pcmToMp3 {
    
    NSString *cafFilePath = [self getRecordSavePath];
    NSString *mp3FilePath = [self getPayerSavePath];
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //资源文件位置
        fseek(pcm, 4*1024, SEEK_CUR);
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //输出位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 8000.0); // 采样率
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        NSLog(@"转码完成");
        
        if (self.complete && _isFinish) {
            self.complete(_isFinish, [NSURL fileURLWithPath:[self getPayerSavePath]]);
        }
    }
}
*/

/**
 录音文件保存位置
 */
- (NSURL *)getSavePath {
    
    NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr = [urlStr stringByAppendingString:@"/Langlib"];
    
    NSFileManager *fileM = [NSFileManager defaultManager];
    // 创建路径
    if (![fileM fileExistsAtPath:urlStr]) {
        [fileM createDirectoryAtPath:urlStr withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (![_urlName hasSuffix:@".caf"]) {
        _urlName = [_urlName stringByAppendingString:@".caf"];
    }
    
    urlStr = [urlStr stringByAppendingPathComponent:_urlName];
    //NSURL *url = [NSURL URLWithString:urlStr];
    // 使用AVPlayer播放本地音频, 创建url必须使用此方法
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    
    NSLog(@"录音保存url:%@",urlStr);
    return url;
}


@end
