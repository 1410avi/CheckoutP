#
# Be sure to run `pod lib lint CheckoutP.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CheckoutP'
  s.version          = '0.1.3'
  s.summary          = 'CheckoutP is a sample SDK which help in solving fee collection'
  s.swift_version    = '5.0'

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = 'This is the description for the CheckoutP is a sample SDK which help in solving fee collection'

  s.homepage         = 'https://github.com/1410avi/CheckoutP'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '1410avi' => 'avinash.soni@grayquest.com' }
  s.source           = { :git => 'https://github.com/1410avi/CheckoutP.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '15.0'

  s.source_files = 'CheckoutP/Classes/**/*'
  s.dependency 'CashfreePG', '~> 2.0.3'
  s.dependency 'razorpay-pod', '1.2.5'
  
  # s.resource_bundles = {
  #   'CheckoutP' => ['CheckoutP/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
