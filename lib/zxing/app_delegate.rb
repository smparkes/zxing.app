module ZXing; end;

require 'zxing/objc'

class ZXing::AppDelegate < NSObject

  def applicationDidFinishLaunching notification

    trap "INT" do
      Dispatch::Queue.main.async do
        NSApp.terminate self
      end
    end

    @options = {
      :show_luminance => true,
      :show_binary => true
    }

    @mask = NSTitledWindowMask|
      NSClosableWindowMask|
      NSMiniaturizableWindowMask|
      NSResizableWindowMask
    frame = NSWindow.frameRectForContentRect [0, 0, 640, 480 ], styleMask:@mask
    @window = NSWindow.alloc.initWithContentRect(frame,
                                                 styleMask:@mask,
                                                 backing:NSBackingStoreBuffered,
                                                 defer:false)

    
    @window.center

    @window.setFrameAutosaveName "SomeWindow"
    @window.setFrameUsingName "SomeWindow"

    @capture = capture = ::ZXCapture.alloc.init

      @window.title = 'ZXing'
      @window.level = NSNormalWindowLevel
      @window.delegate = self

      @menu = NSMenu.alloc.initWithTitle "ZXD"
      NSApplication.sharedApplication.mainMenu = @menu

      # @window.display
      # @window.makeMainWindow
      # @window.makeKeyWindow
      # @window.orderFrontRegardless

      capture.layer.frame = NSWindow.contentRectForFrameRect @window.contentView.frame, styleMask:@mask

      if @options[:show_luminance]
        capture.showLuminance = true
      end

      if @options[:show_binary]
        capture.showBinary = true
      end

      # main.addSublayer capture.layer
      @window.contentView.layer = capture.layer
      @window.contentView.wantsLayer = true

    capture.delegate = self
  end

end
