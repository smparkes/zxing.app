#!/usr/bin/env macruby
if !defined?(RUBY_ENGINE) or RUBY_ENGINE != "macruby"
  $stderr.puts "#{$PROGRAM_NAME} requires macruby"
  exit -1
end
framework "AppKit"
if NSWorkspace.sharedWorkspace.activeApplication["NSApplicationBundleIdentifier"] == "org.zxing.ZXing"
  resources = NSBundle.mainBundle.resourcePath.fileSystemRepresentation
end
require 'lib/zxing/app_delegate'
NSApplication.sharedApplication.delegate = ZXing::AppDelegate.new
NSApplication.sharedApplication.run
