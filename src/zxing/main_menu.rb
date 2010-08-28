module ZXing
  class MainMenu < NSMenu
    def init
      initWithTitle "ME!!"

      item = addItemWithTitle "File", action:nil, keyEquivalent:""
      submenu = NSMenu.alloc.initWithTitle "File"
      setSubmenu submenu, forItem:item

      item = addItemWithTitle "Bar", action:nil, keyEquivalent:""
      submenu = NSMenu.alloc.initWithTitle "Bar"
      setSubmenu submenu, forItem: item

    end
  end
end

# NSApplication.sharedApplication

# menu = NSMenu.alloc.initWithTitle ""

# item = menu.addItemWithTitle "File", action:nil, keyEquivalent:""
# submenu = NSMenu.alloc.initWithTitle "File"
# $stderr.puts [menu, submenu, item].map(&:inspect).join(" ")
# menu.setSubmenu submenu, forItem:item

# item = menu.addItemWithTitle "Bar", action:nil, keyEquivalent:""
# submenu = NSMenu.alloc.initWithTitle "Bar"
# $stderr.puts [menu, submenu, item].map(&:inspect).join(" ")
# menu.setSubmenu submenu, forItem: item

# NSApp.setMainMenu menu

