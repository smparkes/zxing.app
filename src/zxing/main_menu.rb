module ZXing
  class Item < NSMenuItem
    def params params
      params.each do |key, value|
        case key
        when :title; self.title = value
        else
          raise "don't understand param #{key}: #{value}"
        end
      end
    end
    def initWithMenu parent, arg:arg
      menu = nil
      case arg
      when Hash
        if arg.length != 1
          raise "not sure what #{arg} means 0"
        end
        key = arg.keys.first
        value = arg.values.first
        case key
        when String; self.title = key
        when Symbol; self.title = key.to_s.capitalize
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
      self.initWithTitle title, action:nil, keyEquivalent:""
      parent.addItem self
      parent.setSubmenu menu, forItem:self if menu
    end
  end
  class Menu < NSMenu
    def menu *args
      raise "implement menu"
    end
    def item *args
      raise "implement item"
    end
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
    end
    def _items *args
      args.each do |arg|
        case arg
        when Hash
          arg.each do |key, value|
            case key
            when Hash
              raise "implement hash key #{key}"
            when String
              raise "implement string key #{key}"
            when Symbol
              raise "implement symbol key #{key}"
            else
              raise "implement hash key #{key}"
            end
          end
        when Array; raise "implement array"
        else; raise "implement #{arg.inspect}"
        end
      end
    end
  end

  class MainMenu < Menu
    def init
      initWithTitle ""
      
      name = NSRunningApplication.currentApplication.localizedName

      items apple: [{about: {title: "About #{name}"}},
                    :separator,
                    {services: []}],
      view: {{title: "View Me"} =>
        [{luminance: {}},
         {binary: {}}]},
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
