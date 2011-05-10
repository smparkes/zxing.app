module CocoaTasks; end

class CocoaTasks::MacRubyLibTask < Rake::Task; end

def macruby_lib *args, &block
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

  params = Array(params)
  from = params[0] || "."
  target = File.join [".."]*(from.split('/').length), name
  target = File.expand_path(name)
  
  # deps = deps.map {|fn| fn.sub(%r{.rb$}, "_rb.o")}

  # ugh ... need to think this through ... this is where things get tricky ...

  deps = deps.map do |fn|
    object = fn.sub(%r{.rb$}, ".o")
    if object != fn
      file(object => fn) do |t|
        Dir.chdir from do
          sh "macrubyc -c -o #{object.sub(%r{^#{from}/},'')} #{fn.sub(%r{^#{from}/},'')}"
        end
      end
    end
    object
  end
  
  directory File.dirname(name)

  file "#{name}.dylib" => [File.dirname(name)] + deps do |t|
    Dir.chdir from do
      local_deps = deps.grep(%r{.o$}).map{|fn| fn.sub(%r{^#{from}/},"")}
      sh "macrubyc --dylib -o #{target}.dylib #{local_deps.join(' ')}"
    end
  end

  deps.grep(/.bundle$/).each do |ext|
    filename = ext
    params.each do |path|
      filename = filename.sub(%r{^#{path}/},"")
    end
    # FIX: hardcoding file seps, though I think ruby might do this anyway?
    filename = filename.split("/")
    filename.shift
    filename = filename.join("/")
    filename = File.join(name, filename)
    # the dirname conflicts with the library name ... knew this would catch up ...
    # directory File.dirname(filename)
    # file filename => [File.dirname(filename), ext] do
    file filename => ext do
      mkdir_p File.dirname(filename) if !File.exist? File.dirname(filename)
      cp ext, filename
    end
    CocoaTasks::MacRubyLibTask.define_task name => filename
  end

  CocoaTasks::MacRubyLibTask.define_task name => "#{name}.dylib"
end
