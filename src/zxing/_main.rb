#!/usr/bin/env macruby
if !defined?(RUBY_ENGINE) or RUBY_ENGINE != "macruby"
  $stderr.puts "#{$PROGRAM_NAME} requires macruby"
  exit -1
end
framework "AppKit"
if NSWorkspace.sharedWorkspace.activeApplication["NSApplicationBundleIdentifier"] == "org.zxing.ZXing"
  $: << NSBundle.mainBundle.resourcePath.fileSystemRepresentation
else
  $: << 
    File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib")) <<
    File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "Contents", "Resources"))
end
require 'zxing/app_delegate'

NSApplication.sharedApplication.delegate = ZXing::AppDelegate.new
NSApplication.sharedApplication.run
