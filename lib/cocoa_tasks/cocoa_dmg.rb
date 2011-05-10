module CocoaTasks; end

require 'cocoa_tasks/cocoa_build'

def cocoa_dmg *args, &block

  name = nil
  params = []
  deps = []

  if Hash === args[0] 
    # task :t => [:d]
    name = args[0].keys.first
    deps = args[0].values.first
  else
    name = args.shift
    if Hash === args[0]
      # task :t, [a] => [:d]
      params = args[0].keys.first
      deps = args[0].values.first
    else
      # task :t || task :t, [:a]
      deps = args[0] if args[0]
    end
  end

  desc "build #{name} dmg"
  CocoaTasks::CocoaDMGTask.define_task(:dmg, params => deps, &block)

end

class CocoaTasks::CocoaDMGTask < Rake::Task

  def self.define_task *args, &block
    t = super

    t.enhance ["build/#{t.app_name}.dmg"]
    task "build/#{t.app_name}.dmg" => "#{t.app_name}:build"

    t
  end

  attr_accessor :app_name

  def initialize *args
    super
    @app_name = name.sub %r{:dmg$}, ""
  end

  def prerequisites
    super
  end

  def needed?
    # p "n? #{super}"
    super
  end

end

