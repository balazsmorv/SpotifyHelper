#
# Be sure to run `pod lib lint SpotifyHelper.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SpotifyHelper'
  s.version          = '0.1.13'
  s.summary          = 'The spotify sdk, with helper classes'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  The spotify sdk, with helper classes.
                       DESC

  s.homepage         = 'https://github.com/balazsmorv/SpotifyHelper'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'balazsmorv' => 'balazsmorvay@yahoo.com' }
  s.source           = { :git => 'https://github.com/balazsmorv/SpotifyHelper.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  
  s.swift_versions = ['5.0', '5.1', '5.2']
  
  s.static_framework = true

  s.source_files = 'SpotifyHelper/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SpotifyHelper' => ['SpotifyHelper/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'

  #s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }

  s.preserve_paths = 'ios-sdk/SpotifyiOS.framework'
  s.vendored_frameworks = 'ios-sdk/SpotifyiOS.framework'
  s.prepare_command = './prepare-iOS-SDK.sh'
  
  
  s.frameworks = 'UIKit'
  s.dependency 'RxSwift', '~> 5.0'
  s.dependency 'RxRelay', '~> 5.0'
  s.dependency 'RxCocoa', '~> 5.0'
  s.dependency 'RxGesture', '~> 3.0'




  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }



  
end






