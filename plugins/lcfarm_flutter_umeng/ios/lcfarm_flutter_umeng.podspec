#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'lcfarm_flutter_umeng'
  s.version          = '0.0.1'
  s.summary          = 'lcfarm flutter umeng .'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/MrLiuYS/lcfarm_flutter_umeng'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'mrliuys' => '3050700400@qq.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'

  s.ios.deployment_target = '8.0'

  s.dependency 'UMCCommon', '~> 7.1.0'
  s.static_framework = true


end

