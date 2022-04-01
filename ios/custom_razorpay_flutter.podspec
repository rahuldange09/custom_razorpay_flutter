#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint custom_razorpay_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'custom_razorpay_flutter'
  s.version          = '0.0.1'
  s.summary          = 'Custom Razorpay SDK for Flutter'
  s.description      = 'Custom Razorpay SDK for Flutter'
  s.homepage         = 'http://github.com/rahuldange09'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Rahul Dange' => 'rahuldange09@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.vendored_frameworks = 'Frameworks/Razorpay.xcframework'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
