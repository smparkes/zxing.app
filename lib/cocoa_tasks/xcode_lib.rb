module CocoaTasks; end

class CocoaTasks::XCodeBundleTask < Rake::Task; end

def xcode_bundle *args, &block
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

  configuration ||= "Debug"
  project = deps.grep(%r{\.xcodeproj})[0]
  target = File.basename name
  library = File.join(File.dirname(project), %W(build #{configuration} #{target}.bundle))

  deps.delete project
  deps << "#{project}/project.pbxproj"

  file library => deps do
    # this is a little sleazy, but xcode touches the project after creating the library ... go figure ...
    sh "xcodebuild -project #{project} -target #{target} -configuration #{configuration} && touch #{library}"
  end

  directory File.dirname(name)

  file "#{name}.bundle" => [ File.dirname(name), library ] do |t|
    cp t.prerequisites.last, t.name
  end

  CocoaTasks::XCodeBundleTask.define_task name => "#{name}.bundle"
end
