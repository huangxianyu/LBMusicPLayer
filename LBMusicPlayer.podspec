Pod::Spec.new do |s|

  s.name         = "LBMusicPlayer"
  s.version      = "0.0.1"
  s.summary      = "LBMusicPlayer"
  s.description  = <<-DESC
                        AVPlayer
                   DESC

  s.homepage     = "https://github.com/huangxianyu/XYLibrary"
  s.license      = "MIT"
  s.author       = { "huangxianyu" => "huangxianyu@langlib.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/huangxianyu/XYLibrary.git", :tag => "#{s.version}" }

  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  #s.public_header_files = "Classes/**/*.h"
  #s.resource  = "LBMusicPlayer/Assets.xcassets"
  s.static_framework = true
  s.requires_arc = true
  #s.dependency 'AFNetworking'

end