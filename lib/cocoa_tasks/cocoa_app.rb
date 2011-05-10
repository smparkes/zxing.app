module CocoaTasks; end

class CocoaTasks::CocoaAppTask < Rake::Task; end

require 'cocoa_tasks/cocoa_dmg'

def cocoa_app *args, &block
  name = nil
  params = []
  deps = []

  if Hash === args[0] 
    #   task :t => [:d]
    name = args[0].keys.first
    deps = args[0].values.first
  else
    name = args.shift
    if Hash === args[0]
      #   task :t, [a] => [:d]
      params = args[0].keys.first
      deps = args[0].values.first
    else
      #   task :t || task :t, [:a]
      deps = args[0]
    end
  end

  # p [ name, params => deps ]

  objects = deps.grep %r(\.rb$)
  deps -= objects

  dirs = deps.select { |fn| File.directory? fn }
  deps -= [dirs.first]

  objects += dirs.map {|dir| Dir[dir+"/**/*.rb"]}.flatten

  objects.map! { |fn| fn.sub %r{\.rb$}, ".o" }

  dylibs = deps.map do |fn|
    # can't do existance check here ... ick?
    # if !File.exist?(fn) && CocoaTasks::MacRubyLibTask === task(fn)
    if CocoaTasks::MacRubyLibTask === task(fn)
      fn+".dylib"
    elsif fn =~ /\.dylib$/
      fn
    else
      nil
    end
  end.compact
  # this needs to be fixed later anyway, so ...
  objects.concat dylibs.map{|fn| File.expand_path(fn)}

  deps.each do |dep|
    t = task(dep)
    if CocoaTasks::XCodeBundleTask === t ||
        CocoaTasks::MacRubyLibTask === t
      t.prerequisites.each do |prereq|
        string = prereq+""
        # p "string #{string}"
        string.sub! %r{^lib/}, ""
        dir = File.join(%W(Contents Resources #{File.dirname string}))
        # p "ho #{t} #{dir}"
        directory dir
        file "Contents/Resources/#{string}" =>
          [dir, prereq] do |ft|
          cp ft.prerequisites.last, ft.name
        end
        deps << "Contents/Resources/#{string}"
      end
    end
  end

  namespace name do

    directory "Contents/MacOS"

    file "Contents/MacOS/#{name}" => "Contents/MacOS"

    file "Contents/MacOS/#{name}" => objects do |t|
      up = ""
      down = "."
      files = objects
      if dirs.size > 0
        up = "../" * dirs.first.split("/").size
        down = dirs.first
        files = files.map do |fn|
          fn.sub %r{^#{dirs.first}/}, "" 
        end
      end
      Dir.chdir down do
        sh "macrubyc -o #{up}#{t.name} #{files.join(' ')}"
      end
      files.grep(%r{\.dylib$}).each do |dylib|
        prefix = File.expand_path(t.name).sub(%r{/Contents/MacOS/.*$},"")
        # sh "otool -L #{t.name}"
        # puts File.expand_path(dylib) +" "+File.expand_path(t.name)+" "+prefix
        to = "@executable_path/../Resources/#{File.expand_path(dylib).sub %r{^#{prefix}/lib/}, ''}"
        sh "install_name_tool -change #{File.expand_path(dylib)} #{to} #{t.name}"
        # sh "otool -L #{t.name}"
      end
    end

    desc "Compile #{name}"
    task :compile =>
       deps + %W(Contents/MacOS/#{name} Contents/Resources/#{name}.icns Contents/Info.plist)

    desc "Run #{name}"
    task :run => :compile do
      sh "Contents/MacOS/#{name}"
    end

    cocoa_build name

    if false
    namespace :build do
      desc "Run built #{name}"
      task :run => "#{name}:build" do
        raise "implement"
      end
      
      task :build do
        raise "implement"
      end
    end
    end

    desc "Build a deployable #{name}"
    task :build => "#{name}:build:build"

    cocoa_dmg name
  end

  task name => "#{name}:compile"
end


