module ZXing; end;

require 'zxing/objc/zxing'
require 'zxing/main_menu'

class ZXing::AppDelegate < NSObject

  def applicationDidFinishLaunching notification

    load_bridge_support_file resource("zxing.bridgesupport")

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

    NSApp.mainMenu = ZXing::MainMenu.new

    # @window.display
    # @window.makeKeyWindow
    # @window.orderFrontRegardless
    # @window.makeMainWindow

    @capture = capture = ::ZXCapture.alloc.init

    @window.title = 'ZXing'
    @window.level = NSNormalWindowLevel
    @window.delegate = self

    @layer = CALayer.layer
    @layer.frame =  NSWindow.contentRectForFrameRect @window.contentView.frame, styleMask:@mask
    @layer.backgroundColor = CGColorGetConstantColor KCGColorBlack

    # capture.layer.frame = NSWindow.contentRectForFrameRect @window.contentView.frame, styleMask:@mask

    if @options[:show_luminance]
      capture.showLuminance = true
    end

    if @options[:show_binary]
      capture.showBinary = true
    end

    @layer.addSublayer capture.layer
    # @window.contentView.layer = capture.layer
    @window.contentView.layer = @layer
    @window.contentView.wantsLayer = true

    capture.delegate = self
  end

  def captureResult capture, result:result
    if @options[:continuous]
      @count ||= 0
      print "#{@count+=1} "
    end
    puts result.text
    if !@options[:continuous]
      # capture.delegate = nil
      # capture.layer.removeFromSuperlayer
      capture.stop
      NSApplication.sharedApplication.
        performSelectorOnMainThread :"terminate:", withObject:self, waitUntilDone:false
    end
  end

  def resource name
    file = $:.detect { |path| path = File.join(path, name); path if File.exists? path }
    File.join(file, name) if file
  end

  def size_window
    frame = NSWindow.frameRectForContentRect @new_frame, styleMask:@mask
    @window.setFrame frame, display:true
    # @window.setContentAspectRatio [@new_frame.size.width, @new_frame.size.height]
    @window.orderFrontRegardless

    # I've always wanted a detect which returns the first mapped ... must exist?

    img = resource "ZXing.icns"

    NSApplication.sharedApplication.setApplicationIconImage NSImage.alloc.initByReferencingFile(img) if img
  end

  def captureSize capture, width:width, height:height
    @width = width
    @height = height
    Dispatch::Queue.main.async do
      begin
        windowWillResize @window, toSize:@window.frame.size
        @window.orderFrontRegardless
      rescue Exception => e
        p e
      end
    end
  end

  def applicationShouldTerminateAfterLastWindowClosed app
    true
  end

  def windowWillResize window, toSize:size
    frame = [0, 0, size.width, size.height]
    frame = NSWindow.contentRectForFrameRect frame, styleMask:@mask

    window_ar = frame.size.width/frame.size.height
    video_ar = 1.0*@width/@height

    if (video_ar-window_ar).abs > 0.001
      if video_ar > window_ar
        frame.origin.y = (frame.size.height-frame.size.width/video_ar)/2
        frame.size.height = frame.size.width/video_ar
      else
        frame.origin.x = (frame.size.width-frame.size.height*video_ar)/2
        frame.size.width = frame.size.height*video_ar
      end
    end
    @capture.layer.frame = frame
    size
  end

end
