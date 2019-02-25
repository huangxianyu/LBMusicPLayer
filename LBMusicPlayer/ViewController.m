//
//  ViewController.m
//  LBMusicPlayer
//
//  Created by 黄贤于 on 2019/2/19.
//  Copyright © 2019年 黄贤于. All rights reserved.
//

#import "ViewController.h"
//#import "TPOAudioRecordManager.h"
//#import "TPOPlayMusicManager.h"
//#import <LBMusicPlayer/TPOAudioRecordManager.h>
#import <LBMusicPlayer/LBMusicPlayerView.h>
//#import "LBMusicPlayerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LBMusicPlayerView *playerView = [[LBMusicPlayerView alloc] initWithPlayerType:LBMusicPlayerThumbDefault frame:CGRectMake(0, 100, 400, 50)];
    [self.view addSubview:playerView];
}


@end
