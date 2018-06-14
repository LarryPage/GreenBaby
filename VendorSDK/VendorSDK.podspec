Pod::Spec.new do |s|

  s.name         = 'VendorSDK'  #名称
  s.version      = '1.0'  #版本号
  s.summary      = 'Vendor Common Library(MRC)'  #简短介绍，下面是详细介绍
  s.description  = 'Vendor Common Library(MRC) SDK'

  s.homepage     = "http://github.com/lixiangcheng1/VendorSDK"  #主页,这里要填写可以访问到的地址，不然验证不通过
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"           #截图
  s.license      = "MIT"  #开源协议
  s.author       = { "lixiangcheng1" => "sbtjfdn@hotmail.com" }  #作者信息
  s.platform     = :ios, "8.0"  #支持的平台及版本
  s.source       = { :git => "http://github.com/lixiangcheng1/VendorSDK.git", :tag => "#{s.version}" }  #项目地址，这里不支持ssh的地址，验证不通过，只支持HTTP和HTTPS，最好使用HTTPS

  s.source_files       = ["*/**/*.{h,m,mm,c,cc,hpp,cpp}"] #代码源文件地址，**/*表示Classes目录及其子目录下所有文件，如果有多个目录下则用逗号分开，如果需要在项目中分组显示，这里也要做相应的设置
  s.resources          = ["*/**/*.{xcassets,plist,json,xib,storyboard,png,jpg,gif}","*.{plist,json,xib,storyboard,png,jpg,gif}"]  #资源文件地址
  s.exclude_files      = "VendorSDK.xcodeproj", "VendorSDK/Info.plist"
  s.prefix_header_file = 'VendorSDK/PrefixHeader.pch'  #公开头文件地址
  s.frameworks         = 'UIKit','Foundation','CoreGraphics' #所需的framework，多个用逗号隔开
  #s.libraries          = 'sqlite3','stdc++','c++'
  # s.dependency 'AFNetworking', '~> 2.3'   #依赖关系，该项目所依赖的其他库，如果有多个需要填写多个s.dependency
  
  # s.pod_target_xcconfig = { "GCC_PREPROCESSOR_DEFINITIONS" => "__TARGET_NAME__=${PRODUCT_NAME:rfc1034identifier}" }
  s.requires_arc = false #是否使用ARC，如果指定具体文件，则具体的问题使用ARC

end
