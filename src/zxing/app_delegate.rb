module ZXing; end;

require 'zxing/objc/zxing'
require 'zxing/main_menu'

class ZXing::AppDelegate < NSObject

  def preferences
    prefs = NSUserDefaults.standardUserDefaults
    prefs.registerDefaults show_luminance:false, show_binary:false, fullscreen:false
    @options = prefs
  end

  class WindowView < NSView
    def cancelOperation sender
      NSApp.delegate.cancel
    end
  end

  def applicationDidFinishLaunching notification

    load_bridge_support_file resource("zxing.bridgesupport")

    trap "INT" do
      Dispatch::Queue.main.async do
        NSApp.terminate self
      end
    end

    preferences

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
    
    @window.contentView = WindowView.new

    NSNotificationCenter.defaultCenter.
      addObserver self, selector: :"resizeNotification:", name:NSViewFrameDidChangeNotification, object:@window.contentView

    @layer = CALayer.layer
    @layer.frame =  NSWindow.contentRectForFrameRect @window.frame, styleMask:@mask
    @layer.backgroundColor = CGColorGetConstantColor KCGColorBlack

    # capture.layer.frame = NSWindow.contentRectForFrameRect @window.contentView.frame, styleMask:@mask

    @layer.addSublayer capture.layer

    if @options[:show_luminance]
      # capture.showLuminance = true
      @layer.addSublayer capture.luminance
    end

    if @options[:show_binary]
      # capture.showBinary = true
      @layer.addSublayer capture.binary
    end

    # @window.contentView.layer = capture.layer
    @window.contentView.layer = @layer
    @window.contentView.wantsLayer = true

    contents = NSWindow.contentRectForFrameRect @window.frame, styleMask:@mask
    contents = @window.contentView.frame
    @tv = NSTextField.alloc.initWithFrame [0,
                                           contents.size.height-100,
                                           contents.size.width,
                                           100]
    @tv.stringValue = ""
    @tv.textColor = NSColor.yellowColor
    @tv.backgroundColor = NSColor.clearColor
    @tv.bezeled = false
    @tv.editable = false
    @tv.font = NSFont.systemFontOfSize 72
    @tv.alignment = NSCenterTextAlignment
    @window.contentView.addSubview @tv

    capture.delegate = self
  end

  def captureResult capture, result:result
    if false && @options[:continuous]
      @count ||= 0
      print "#{@count+=1} "
    end
    if result.text != @last_text
      @tv.stringValue = result.text
      puts result.text
    end
    @last_text = result.text
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
        resize @window.frame.size
        @window.orderFrontRegardless
      rescue Exception => e
        p e
      end
    end
  end

  def applicationShouldTerminateAfterLastWindowClosed app
    true
  end

  def resize size
    frame = CGRect.new [0, 0], [size.width, size.height]
    # frame = NSWindow.contentRectForFrameRect frame, styleMask:@mask

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

    if @options[:show_luminance]
      frame = CGRect.new [0, 0], [size.width, size.height]
      # frame = NSWindow.contentRectForFrameRect frame, styleMask:@mask
      width = frame.size.width
      frame.size.height *= 1/3.0
      frame.size.width *= 1/3.0

      window_ar = frame.size.width/frame.size.height
      video_ar = 1.0*@width/@height

      if (video_ar-window_ar).abs > 0.001
        if video_ar > window_ar
          frame.size.height = frame.size.width/video_ar
        else
          frame.size.width = frame.size.height*video_ar
        end
      end

      frame.origin.x = width - frame.size.width

      @capture.luminance.frame = frame
    end

    if @options[:show_binary]
      frame = CGRect.new [0, 0], [size.width, size.height]
      # frame = NSWindow.contentRectForFrameRect frame, styleMask:@mask
      frame.size.height *= 1/3.0
      frame.size.width *= 1/3.0

      window_ar = frame.size.width/frame.size.height
      video_ar = 1.0*@width/@height

      if (video_ar-window_ar).abs > 0.001
        if video_ar > window_ar
          frame.size.height = frame.size.width/video_ar
        else
          frame.size.width = frame.size.height*video_ar
        end
      end

      @capture.binary.frame = frame
    end

    size
  end

  def quit item
    NSApp.terminate self
  end

  def show_luminance
    @options[:show_luminance]
  end

  def show_binary
    @options[:show_binary]
  end

  def luminance item
    @options[:show_luminance] = !@options[:show_luminance]
    item.state = @options[:show_luminance]
    if @options[:show_luminance]
      @layer.addSublayer @capture.luminance
      resize @window.frame.size
    else
      @capture.luminance.removeFromSuperlayer
      @capture.luminance = nil
    end
  end

  def binary item
    @options[:show_binary] = !@options[:show_binary]
    item.state = @options[:show_binary]
    if @options[:show_binary]
      @layer.addSublayer @capture.binary
      resize @window.frame.size
    else
      @capture.binary.removeFromSuperlayer
      @capture.binary = nil
    end
  end

  def capture item
    p "capture"
  end

  def fullscreen item
    @options[:fullscreen] = !@options[:fullscreen]
    if @options[:fullscreen]
      options = {NSFullScreenModeAllScreens => NSNumber.numberWithBool(false)}
      @window.contentView.enterFullScreenMode @window.screen, withOptions:options
    else
      @window.contentView.exitFullScreenModeWithOptions nil
    end
  end

  def cancel
    @options[:fullscreen] = false 
    @window.contentView.exitFullScreenModeWithOptions nil
  end

  def resizeNotification notification
    resize notification.object.frame.size
  end

end
