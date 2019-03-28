#
# Be sure to run `pod lib lint CNjacobBleManagerKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CNjacobBleManagerKit'
  s.version          = '0.0.1'
  s.summary          = '苹果蓝牙CoreBluetooth简单使用.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
CNjacobBleManagerKit 是对苹果蓝牙CoreBluetooth的简单封装，使用Block方式使代码更简洁.
                       DESC

  s.homepage         = 'https://github.com/CNjacob/CNjacobBleManagerKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'CNjacob' => '15375187600@163.com' }
  s.source           = { :git => 'https://github.com/CNjacob/CNjacobBleManagerKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'CNjacobBleManagerKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'CNjacobBleManagerKit' => ['CNjacobBleManagerKit/Assets/*.png']
  # }

  s.static_framework = true
  
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
