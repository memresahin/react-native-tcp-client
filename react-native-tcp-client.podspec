Pod::Spec.new do |s|
  s.name         = "react-native-tcp-client"
  s.version      = "1.0.0"
  s.summary      = "TCP client for React Native"
  s.homepage     = "https://github.com/senin-kutuphanen"
  s.license      = "MIT"
  s.author       = { "Senin Adın" => "email@example.com" }
  s.source       = { :git => "https://github.com/senin-kutuphanen.git", :tag => "#{s.version}" }
  s.source_files = "ios/**/*.{h,m,swift}"
  s.requires_arc = true
  s.dependency "React"
end
