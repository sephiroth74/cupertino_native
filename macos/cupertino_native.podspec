#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint cupertino_native.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'cupertino_native'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://sephiroth.it'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Alessandro Crugnola' => 'alessandro.crugnola@gmail.com' }

  s.source           = { :path => '.' }
  s.source_files = 'cupertino_native/Sources/cupertino_native/**/*.swift'

  # Privacy manifest. Shared with the Swift Package Manager layout under
  # cupertino_native/Sources/cupertino_native/Resources.
  # For more information, see
  # https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  s.resource_bundles = {'cupertino_native_privacy' => ['cupertino_native/Sources/cupertino_native/Resources/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '26.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
