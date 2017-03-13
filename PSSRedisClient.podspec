#
# Be sure to run `pod lib lint PSSRedisClient.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PSSRedisClient'
  s.version          = '0.1.1'
  s.summary          = 'A simple Swift-based interface to Redis, using CocoaAsyncSocket'
  s.description      = <<-DESC
A simple Swift-based interface to Redis, using CocoaAsyncSocket as the networking layer and a swift-based implementation of the redis protocol.
                       DESC

  s.homepage         = 'https://github.com/perrystreetsoftware/PSSRedisClient'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'esilverberg' => 'eric@<company name>.com' }
  s.source           = { :git => 'https://github.com/perrystreetsoftware/PSSRedisClient.git', :tag => '0.1.1' }
  s.social_media_url = 'https://twitter.com/esilverberg'

  s.ios.deployment_target = '9.0'

  s.source_files = 'PSSRedisClient/Classes/**/*'
  
  # s.resource_bundles = {
  #   'PSSRedisClient' => ['PSSRedisClient/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'CocoaAsyncSocket'
end
