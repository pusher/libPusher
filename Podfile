platform :ios

dependency do |s|
  s.name     = 'JSONKit'
  s.version  = '1.5b'
  s.source   = { :git => 'https://github.com/johnezang/JSONKit.git', :commit => '0aff3deb5e' }
  s.source_files = 'JSONKit.*'
end

dependency 'SocketRocket', '0.1'

target :specs, :exclusive => true do
  dependency 'Kiwi', git: "git://github.com/allending/Kiwi.git"
end
