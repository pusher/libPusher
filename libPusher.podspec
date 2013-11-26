Pod::Spec.new do |s|
  s.name         = 'libPusher'
  s.version      = '1.5'
  s.license      = 'MIT'
  s.summary      = 'An Objective-C client for the Pusher.com service'
  s.homepage     = 'https://github.com/lukeredpath/libPusher'
  s.author       = 'Luke Redpath'
  s.source       = { :git => 'https://github.com/lukeredpath/libPusher.git', :tag => 'v1.4' }
  s.source_files = 'Library/*'
  s.private_header_files = %w(
    PTJSON.h 
    PTJSONParser.h 
    NSString+Hashing.h 
    NSDictionary+QueryString.h 
    PTPusherChannel_Private.h
  )
  s.requires_arc = true
  s.dependency 'SocketRocket', "0.2"
  s.compiler_flags = '-Wno-arc-performSelector-leaks', '-Wno-format'
  s.xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => 'kPTPusherClientLibraryVersion=@\"1.5\"' }
  s.header_dir   = 'Pusher'
end
