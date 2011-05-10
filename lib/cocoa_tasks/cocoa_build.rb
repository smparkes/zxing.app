module CocoaTasks; end

# note: expects to be namespaced ...

def cocoa_build *args, &block

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

  rule(%r{^build/#{name}\.app/} =>
       [ lambda { |fn| File.dirname fn },
         lambda { |fn| fn.sub %r{^build/#{name}\.app/}, "" } ]) do |t|
    cp t.source, t.name
  end

  CocoaTasks::CocoaBuildTask.define_task(:build, params => deps, &block)

end

class CocoaTasks::CocoaBuildTask < Rake::Task

  def self.define_task *args, &block
    t = super

    directory "build/#{t.app_name}.app/Contents/MacOS"
    directory "build/#{t.app_name}.app/Contents/Resources"

    t.enhance [ "build/#{t.app_name}.app/Contents/MacOS/#{t.app_name}",
                "build/#{t.app_name}.app/Contents/Info.plist" ]

  end

  attr_accessor :app_name

  def initialize *args
    super
    @app_name = name.sub %r{:build$}, ""
  end

  def prerequisites
    super
  end

  def needed?
    # p "n? #{super}"
    super
  end

end

