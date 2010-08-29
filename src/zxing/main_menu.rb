module ZXing
  class Item < NSMenuItem
    def params params
      params.each do |key, value|
        case key
        when :title; self.title = value
        when :key
          key, mask = value.to_s.split(":").inject([nil,0]) do |pair, string|
            k, m = pair
            case string
            when "cmd"; m |= NSCommandKeyMask
            when "ctl"; m |= NSControlKeyMask
            when "shift"; m |= NSShiftKeyMask
            when "opt"; m |= NSAlternateKeyMask
            else k = string
            end
            [k, m]
          end
          self.keyEquivalent = key
          self.keyEquivalentModifierMask = mask
        when :state
          self.state = value
        else
          raise "don't understand param #{key}: #{value}"
        end
      end
    end
    def initWithMenu parent, arg:arg
      self.initWithTitle "", action:nil, keyEquivalent:""
      # self.target = NSApp.delegate
      self.target = NSApp.delegate
      self.enabled = true
      menu = nil
      case arg
      when Hash
        if arg.length != 1
          raise "not sure what #{arg} means 0"
        end
        key = arg.keys.first
        value = arg.values.first
        case key
        when String;
          self.action = "#{key}:".to_sym
          # p self.action, NSApp.delegate.respondsToSelector(self.action)
          self.title = key
        when Symbol;
          self.action = "#{key}:".to_sym
          # p self.action, NSApp.delegate.respondsToSelector(self.action)
          self.title = key.to_s.split("_").map(&:capitalize).join(" ")
        when Hash
          params key
        else
          raise "not sure what #{key} means 1"
        end
        case value
        when String; raise "hell"
        when Array
          menu = Menu.alloc.initWithTitle title
          menu.items *value
        when Hash
          if value.length == 1 and
              Hash === value.keys.first
            params value.keys.first
            menu = Menu.alloc.initWithTitle self.title
            menu.items *value.values.first
          else
            params value
          end
        else; raise "not sure what #{value} means 2"
        end
      when Symbol
        raise "implement symbol item arg #{arg}"
      else
        raise "implement #{arg.class} item arg #{arg}"
      end
      # p self, self.action, self.target, self.isEnabled
      parent.addItem self
      if menu
        case arg.keys.first
        when :apple; NSApp.setAppleMenu(menu)
        when :services; NSApp.setServicesMenu(menu)
        when :window; NSApp.setWindowsMenu(menu)
        end
        self.action = self.target = nil
        parent.setSubmenu menu, forItem:self
      end
    end
  end
  class Menu < NSMenu
    def items *args
      args.each do |arg|
        case arg
        when Array
          Item.alloc.initWithMenu self, arg:arg
        when Hash
          arg.each do |key, value|
            Item.alloc.initWithMenu self, arg:{key => value}
          end
        end
      end
      update
    end
  end

  class MainMenu < Menu
    def init
      initWithTitle ""
      
      name = NSRunningApplication.currentApplication.localizedName

      items apple: [{about: {title: "About #{name}"}},
                    :separator,
                    {services: []},
                    :separator,
                    {hide: {title: "Hide #{name}", key: "cmd:h"}},
                    {hide_others: {key: "cmd:opt:h"}},
                    :show_all,
                    :separator,
                    {quit: {title: "Quit #{name}", key: "cmd:q"}}
                   ],
      view: {{title: "View"} =>
        [{capture: {:key => "cmd:c"}},
         {luminance: {:key => "cmd:l", state: NSApp.delegate.show_luminance}},
         {binary: {:key => "cmd:b", state: NSApp.delegate.show_binary}}]},
      window:[],
      help:[]
            
      self
      # item = addItemWithTitle "File", action:nil, keyEquivalent:""
      # submenu = NSMenu.alloc.initWithTitle "File"
      # setSubmenu submenu, forItem:item

      # item = addItemWithTitle "Bar", action:nil, keyEquivalent:""
      # submenu = NSMenu.alloc.initWithTitle "Bar"
      # setSubmenu submenu, forItem: item

    end
  end
end
