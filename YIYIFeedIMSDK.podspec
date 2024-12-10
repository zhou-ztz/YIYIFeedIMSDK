
Pod::Spec.new do |spec|

  spec.name         = "YIYIFeedIMSDK"
  spec.version      = "1.0.5"
  spec.summary      = "A short description of YIYIFeedIMSDK."
  spec.description  = <<-DESC
                   这个是一个测试的demo description of YIYIFeedIMSDK项目
                   DESC
  spec.homepage     = "https://github.com/zhou-ztz/YIYIFeedIMSDK"
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.author       = { "tingzhi.zhou" => "tingzhi.zhou@yiartkeji.com" }
  spec.platform     = :ios, "13.0"
  spec.source       = { :git => 'https://github.com/zhou-ztz/YIYIFeedIMSDK.git', :tag => '1.0.5'}
  #spec.vendored_frameworks = ['YIYIFeedIMSDK/OBS.framework']
  spec.source_files  = "YIYIFeedIMSDK/**/*.swift"
  spec.resources = ['YIYIFeedIMSDK/SDKResource.bundle']
  spec.requires_arc  = true
  spec.static_framework = true
  spec.swift_version    = '5.0'

  spec.dependency "SDWebImage", "5.17.0"
  spec.dependency 'NEMeetingKit', '4.9.1'
  spec.dependency 'KMPlaceholderTextView', '1.4.0'   
  spec.dependency 'SnapKit', '5.0.0'                    
  spec.dependency 'MJRefresh', '3.1.16'
  spec.dependency 'Reachability', '3.2'
  spec.dependency 'IQKeyboardManagerSwift', '6.5.0'
  spec.dependency 'ReactiveObjC', '3.1.1'
  spec.dependency 'YYCategories', '1.0.4'
  spec.dependency 'ObjectMapper', '3.4.2'
  spec.dependency 'ObjectBox', '4.0.0'
  spec.dependency 'STRegex', '2.1.0'
  spec.dependency 'SwiftDate', '7.0.0'
 
  spec.xcconfig = {
  'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }

  spec.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64' }

end
