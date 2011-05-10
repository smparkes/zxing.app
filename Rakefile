# -*- ruby -*-

macruby = defined?(RUBY_ENGINE) && RUBY_ENGINE == "macruby"

if macruby
  $stderr.puts "you don't want to run rake under macruby ... just the result"
  exit -1
end

$: << File.expand_path( File.dirname(__FILE__) + '/lib' )

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
    "vendor/zxing/zxing.appspot.com/static/zxingiconsmall.png",
    "vendor/zxing/zxing.appspot.com/static/zxingicon.png"
  ] do |t|
  sh "png2icns #{t} #{t.prerequisites.grep(%r{.png$}).join(' ')}"
end

cocoa_app "ZXing" => 
  %w(src) +
  %w(lib/zxing/objc/zxing)
 
task :default => "ZXing:run"
