Pod::Spec.new do |s|
  s.name         = 'POSLens'
  s.version      = '1.0.0'
  s.license      = 'MIT'
  s.summary      = 'Library for thread-safe atomic object updates and persisting.'
  s.homepage     = 'https://github.com/pavelosipov/POSLens'
  s.authors      = { 'Pavel Osipov' => 'posipov84@gmail.com' }
  s.source       = { :git => 'https://github.com/pavelosipov/POSLens.git', :tag => s.version }
  s.requires_arc = true
  s.ios.deployment_target = '7.0'
  s.source_files = 'Classes/**/*.{h,m}'
  s.dependency 'ReactiveObjC'
end
