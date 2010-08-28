# -*- ruby -*-
require 'cocoa_tasks'

xcode_bundle "lib/zxing/objc/zxing" =>
  Dir["vendor/zxing/objc/**/*.{h,pch,c,cpp,cc,m,mm}"] +
  Dir["vendor/zxing/cpp/core/src/**/*.{h,c,cpp,cc,m,mm}"] << 
  "vendor/zxing/objc/osx.xcodeproj"

directory "vendor/zxing.rb" do
  sh "git submodule update --init"
end

directory "vendor/zxing.rb/vendor/zing" do
  Dir.chdir "vendor/zxing.rb" do
    sh "git submodule update --init"
  end
end

directory "Contents/Resources"

file "Contents/Resources/ZXing.icns" =>
  [ "Contents/Resources",
    "vendor/zxing/zxingorg/web/zxing-icon.png" ] do |t|
  sh "png2icns #{t} #{t.prerequisites.grep(%r{.png$}).join(' ')}"
end

cocoa_app "ZXing" => 
  %w(main.rb) +
  Dir["lib/**/*.rb"] +
  %w(lib/zxing/objc/zxing)
 
task :default => "ZXing:run"
