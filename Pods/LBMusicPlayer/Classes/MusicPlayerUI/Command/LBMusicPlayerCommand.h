//
//  LBMusicPlayerCommand.h
//  LBMusicPlayer
//
//  Created by 黄贤于 on 2019/2/25.
//  Copyright © 2019年 黄贤于. All rights reserved.
//

#ifndef LBMusicPlayerCommand_h
#define LBMusicPlayerCommand_h

// 屏幕宽高
#define kScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#define kScreenHeigth ([[UIScreen mainScreen] bounds].size.height)
#define kScaleWidth(W) (roundf(kScreenWidth*(W)/375.0f))
#define kScaleHeigth(H) (roundf(kScreenHeigth*(H)/667.0f))

// 普通字体 中黑体 粗体
#define kFontNameRegular @"PingFangSC-Regular"
#define kFontNameLigth @"PingFangSC-Light"
#define kFontNameMedium @"PingFangSC-Medium"
#define kFontNameSemibold @"PingFangSC-Semibold"

#define LBMusicPlayerMainBundle [NSBundle bundleForClass:[self class]]
#define LBMusicPlayerBundlePath [LBMusicPlayerMainBundle pathForResource:@"LBMusicPlayer" ofType:@"bundle"]
#define LBMusicPlayerBundle [NSBundle bundleWithPath:LBMusicPlayerBundlePath]
#define LBMusicPlayerBuldleImage(img) [UIImage imageNamed:img inBundle:LBMusicPlayerBundle compatibleWithTraitCollection:nil]


#endif /* LBMusicPlayerCommand_h */
