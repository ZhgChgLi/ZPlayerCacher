Pod::Spec.new do |s|
  s.name             = "ZPlayerCacher"
  s.version          = "1.0.0"
  s.summary          = "ZPlayerCacher is a lightweight implementation that enables AVPlayerItem to support caching streaming files."
  s.homepage         = "https://github.com/ZhgChgLi/ZPlayerCacher"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "ZhgChgLi" => "me@zhgchg.li" }
  s.source           = { :git => "https://github.com/ZhgChgLi/ZPlayerCacher.git", :tag => "v" + s.version.to_s }
  s.ios.deployment_target = "13.0"
  s.osx.deployment_target = "12.0"
  s.swift_version = "5.0"
  s.source_files = ["Sources/**/*.swift"]
end
