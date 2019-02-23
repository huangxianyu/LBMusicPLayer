//
//  TPOAudioRecordManager.h
//  Meeting
//
//  Created by 黄贤于 on 2018/7/14.
//  Copyright © 2018年 com.newchinese. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface TPOAudioRecordManager : NSObject

/**
 录音之前先设置录音保存路径名
 */
- (void)setRecordUrlName:(NSString *)urlName;

/**
 开始录音
 */
- (void)record:(void (^) (BOOL success))success;

/**
 暂停录音
 */
- (void)pause;

/**
 恢复录音
 */
- (void)resume;

/**
 完成录音
 */
- (void)recordComplete:(void (^) (BOOL isSuccess, NSURL *recordUrl))complete;

/**
 获取录音状态
 */
- (BOOL)isRecording;

/**
 录音音波大小 0 - 1

 @param power 回调
 */
- (void)getRecordPower:(void (^) (CGFloat power))power;

/**
 获取录音文件路径
 */
- (NSURL *)getRecordUrl;

/**
 获取录音时间
 */
- (NSInteger)getRecordTotalTime;

/**
 删除录音文件
 */
- (void)deleteRecordFile;

@end
