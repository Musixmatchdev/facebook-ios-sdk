# Use the --use-libraries switch when pushing or linting this podspec

Pod::Spec.new do |s|

  s.name         = 'FBSDKGamingServicesKit'
  s.version      = '11.2.0'
  s.summary      = 'Official Facebook SDK for iOS to access Facebook Gaming Services'

  s.description  = <<-DESC
                   The Facebook SDK for iOS GamingKit framework provides:
                   * Friend Finder.
                   DESC

  s.homepage     = 'https://developers.facebook.com/docs/ios/'
  s.license      = { type: 'Facebook Platform License', file: 'LICENSE' }
  s.author       = 'Facebook'

  s.platform     = :ios
  s.ios.deployment_target = '9.0'

  s.swift_version = '5.0'

  s.source       = {
    git: 'https://github.com/facebook/facebook-ios-sdk.git',
    tag: "v#{s.version}"
  }

  s.weak_frameworks = 'Foundation', 'CoreGraphics'

  s.requires_arc = true
  s.pod_target_xcconfig = {
    'GCC_PREPROCESSOR_DEFINITIONS': '$(inherited) FBSDKCOCOAPODS=1',
    'OTHER_SWIFT_FLAGS': '$(inherited) -Xcc -DFBSDKCOCOAPODS',
    'DEFINES_MODULE': 'YES'
  }

  s.source_files   = 'Sources/FBSDKGamingServicesKit/**/*.{h,swift}'
  s.public_header_files = 'Sources/FBSDKGamingServicesKit/**/*.h'
  s.dependency 'LegacyGamingServices', "~> #{s.version}"
  s.dependency 'FacebookGamingServices', "~> #{s.version}"

end
