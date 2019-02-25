Pod::Spec.new do |s|

  s.name         = "LBMusicPlayer"
  s.version      = "0.0.5"
  s.summary      = "LBMusicPlayer"
  s.description  = <<-DESC
                        AVPlayer 播放和录音
                   DESC

  s.homepage     = "https://github.com/huangxianyu/LBMusicPlayer"
  s.license      = "MIT"
  s.author       = { "huangxianyu" => "huangxianyu@langlib.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/huangxianyu/LBMusicPlayer.git", :tag => "#{s.version}" }

  #s.source_files  = "Classes", "Classes/LBMusicPlayer.h"
  #s.public_header_files = "Classes/LBMusicPlayer.h"
  #s.resource  = "LBMusicPlayer/Assets.xcassets"
  s.static_framework = true
  s.requires_arc = true
  #s.dependency 'AFNetworking'

  s.subspec 'MusicPlayer' do |ss|
    ss.source_files        = "Classes", "Classes/MusicPlayer/**/*.{h,m}"
    ss.public_header_files = "Classes", "Classes/MusicPlayer/**/*.h"
  end

  s.subspec 'AudioRecord' do |ss|
    ss.source_files        = "Classes", "Classes/AudioRecord/**/*.{h,m}"
    ss.public_header_files = "Classes", "Classes/AudioRecord/**/*.h"
  end

end
