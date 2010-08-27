# -*- ruby -*-
require 'cocoa_tasks'

def lib *args
  file *args
end

def macruby_lib *args
  file *args
end

lib "vendor/zxing.rb/lib/zing"
macruby_lib "vendor/zxing.rb/lib/zxing"

directory "vendor/zxing.rb" do
  sh "git submodule update --init"
end

directory "vendor/zxing.rb/vendor/zing" do
  Dir.chdir "vendor/zxing.rb" do
    sh "git submodule update --init"
  end
end

file "Resources/ZXing.icns" =>
  [ "vendor/zxing.rb/vendor/zxing/zxingorg/web/zxing-icon.png" ] do |t|
  sh "png2icns #{t} #{t.prerequisites.join(' ')}"
end

cocoa_app "ZXing" => 
  %w(main.rb) +
  Dir["lib/**/*.rb"] +
  %w(lib/zxing/objc)
 
task :default => "ZXing:run"
