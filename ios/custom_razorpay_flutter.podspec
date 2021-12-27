#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint custom_razorpay_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'custom_razorpay_flutter'
  s.version          = '0.0.1'
  s.summary          = 'Custom Razorpay SDK for Flutter'
  s.description      = <<-DESC
Custom Razorpay SDK for Flutter
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.vendored_frameworks = 'Razorpay.xcframework/ios-arm64_armv7/Razorpay.framework'

  s.platform = :ios, '10.1'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
