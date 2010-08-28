require 'rubygems'
require 'hotcocoa'
require 'hotcocoa/mappings/view'
require 'hotcocoa/mappings/control'
require 'hotcocoa/mappings/text_field'
require 'hotcocoa/mappings/application'
require 'hotcocoa/mappings/menu'
require 'hotcocoa/mappings/menu_item'
require 'hotcocoa/mappings/window'
require 'hotcocoa/mappings/label'

require 'zxing'

# Replace the following code with your own hotcocoa code

class Application

  include HotCocoa
  
  def start
    application :name => "Zxd" do |app|

      trap "INT" do
        app.performSelectorOnMainThread :"terminate:", withObject:self, waitUntilDone:false
      end

      app.delegate = self
      window :frame => [0, 0, 640, 480], :title => "Zxd" do |win|
        win.center
        win.setFrameAutosaveName "SomeWindow"
        win.setFrameUsingName "SomeWindow"
        win << label(:text => "Hello from HotCocoa", :layout => {:start => false})
        win.will_close { exit }
      end
    end
  end
  
  # file/open
  def on_open(menu)
  end
  
  # file/new 
  def on_new(menu)
  end
  
  # help menu item
  def on_help(menu)
  end
  
  # This is commented out, so the minimize menu item is disabled
  #def on_minimize(menu)
  #end
  
  # window/zoom
  def on_zoom(menu)
  end
  
  # window/bring_all_to_front
  def on_bring_all_to_front(menu)
  end
end

Application.new.start
