//
//  ViewController.m
//  LBMusicPlayer
//
//  Created by 黄贤于 on 2019/2/19.
//  Copyright © 2019年 黄贤于. All rights reserved.
//

#import "ViewController.h"
#import "TPOAudioRecordManager.h"
#import "TPOPlayMusicManager.h" // 导入方式1
//#import <LBMusicPlayer/TPOAudioRecordManager.h> // 导入方式2
#import "LBMusicPlayerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    LBMusicPlayerView *playerView = [[LBMusicPlayerView alloc] initWithPlayerType:LBMusicPlayerThumbDefault frame:CGRectMake(10, 100, 400, 100)];
    [playerView playWithUrl:[NSURL URLWithString:@"https://a-pubres-cet.langlib.com/foreign/tpo/TPO-054/listening/TPO-054L2.mp3"]];
    [self.view addSubview:playerView];
}


@end
