require 'cocoa_tasks/version'
require 'cocoa_tasks/cocoa_app'
require 'cocoa_tasks/xcode_lib'
require 'cocoa_tasks/macruby_lib'

rule(".o" => ".rb") do |task|
  sh "macrubyc -c -o #{task.name} #{task.source}"
end
