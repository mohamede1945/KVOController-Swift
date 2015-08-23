#
# Be sure to run `pod lib lint KVOController.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "KVOController-Swift"
  s.version          = "1.0.0"
  s.summary          = "Generic, simple key-value observing for Swift"
  s.description      = <<-DESC

Have you ever wondered if you can implement a generic key-value observing for Swift. It makes your life easy and safes you a lot of casting.
This project is inspired by facebook/KVOController. So, it doesn't only provide a neat UI for KVO', but also makes use of Swift generics feature.

                       DESC
  s.homepage         = "https://github.com/mohamede1945/KVOController-Swift"
  s.license          = 'MIT'
  s.author           = { "Mohamed Afifi" => "mohamede1945@gmail.com" }
  s.source           = { :git => "https://github.com/mohamede1945/KVOController-Swift.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/mohamede1945'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'KVOController' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
