module ZXing; end;

require 'zxing/objc/zxing'
require 'zxing/main_menu'

class ZXing::AppDelegate < NSObject

  def preferences
    prefs = NSUserDefaults.standardUserDefaults
    prefs.registerDefaults show_luminance:false,
                           show_binary:false,
                           fullscreen:false,
                           continuous:true

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

    mask = NSTitledWindowMask|
      NSClosableWindowMask|
      NSMiniaturizableWindowMask|
      NSResizableWindowMask
    frame = NSWindow.frameRectForContentRect [0, 0, 640, 480 ], styleMask:mask
    @window = NSWindow.alloc.initWithContentRect(frame,
                                                 styleMask:mask,
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
    @layer.frame =  @window.contentRectForFrameRect @window.frame
    @layer.backgroundColor = CGColorGetConstantColor KCGColorBlack

    # capture.layer.frame = @window.contentRectForFrameRect @window.contentView.frame

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
    contents =  @window.contentRectForFrameRect(@window.frame)

    @tv = NSTextView.alloc.initWithFrame [0.1*contents.size.width,
                         0.05*contents.size.height,
                         0.8*contents.size.width,
                         0.45*contents.size.height]
    @tv.horizontallyResizable = false
    @tv.verticallyResizable = false
    @tv.textContainerInset = [10, 10]
    @tv.textColor = NSColor.yellowColor
    @tv.editable = false
    @tv.font = NSFont.systemFontOfSize 36
    @tv.alignment = NSCenterTextAlignment

    @window.contentView.addSubview @tv

    @tv.backgroundColor = NSColor.clearColor
    @tv.layer.backgroundColor = CGColorCreateGenericRGB 0, 0, 1, 0.4
    @tv.layer.borderColor = CGColorCreateGenericRGB 1, 1, 1, 0.4
    @tv.layer.borderWidth = 2
    @tv.layer.cornerRadius = 10

    @tv.alphaValue = 0

    capture.delegate = self
  end

  def height string, font, width
    ts = NSTextStorage.alloc.initWithString string
    tc = NSTextContainer.alloc.initWithContainerSize [width, 9999999]
    lm = NSLayoutManager.alloc.init
    lm.addTextContainer tc
    ts.addLayoutManager lm
    ts.addAttribute NSFontAttributeName, value:font, range:[0, ts.length]
    tc.setLineFragmentPadding 0
    lm.glyphRangeForTextContainer tc
    return lm.usedRectForTextContainer(tc).size.height
  end

  def captureResult capture, result:result
    value = result.text
    if result.text != @tv.string
      Dispatch::Queue.main.async do
        begin
          @tv.string = result.text
          @tv.frame = @tv_frame
          h = height result.text, @tv.font, @tv.frame.size.width
          h += 2*@tv.textContainerInset.height
          if h < @tv.frame.size.height
            f = @tv.frame
            f.size.height = h
            @tv.frame = f
          end
          # NSSpeechSynthesizer.alloc.initWithVoice(NSSpeechSynthesizer.defaultVoice).startSpeakingString("Steven Parkes")
          # @tv.startSpeaking self
          # @tv.horizontallyResizable = false
          # @tv.sizeToFit
          NSAnimationContext.beginGrouping
          NSAnimationContext.currentContext.duration = 0.8
          @tv.animator.alphaValue = 0.9
          NSAnimationContext.endGrouping

          # this code is fast and loose: it's just a demo after all

          Dispatch::Queue.main.after 5 do
            if @tv.string == value or @tv.string == ""
              NSAnimationContext.beginGrouping
              NSAnimationContext.currentContext.duration = 0.8
              @tv.animator.alphaValue = 0
              NSAnimationContext.endGrouping
              Dispatch::Queue.main.after 1 do
                if @tv.string == value
                  @tv.string = ""
                end
              end
            end
          end
        rescue Exception => e
          p e
        end
      end
      puts result.text
    end
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
    raise "hell"
    frame = @window.frameRectForContentRect @new_frame
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
    frame = @window.contentRectForFrameRect frame

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

    frame = CGRect.new [0, 0], [size.width, size.height]
    @tv_frame = @tv.frame = [0.1*frame.size.width,
                             0.05*frame.size.height,
                             0.8*frame.size.width,
                             0.45*frame.size.height]

    if @options[:show_luminance]
      frame = CGRect.new [0, 0], [size.width, size.height]
      frame = @window.contentRectForFrameRect frame
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
      frame = @window.contentRectForFrameRect frame
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
      if @text_layer
        @layer.addSublayer @text_layer
      end
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
      if @text_layer
        @layer.addSublayer @text_layer
      end
      resize @window.frame.size
    else
      @capture.binary.removeFromSuperlayer
      @capture.binary = nil
    end
  end

  def capture item
    now = Time.now.strftime "%Y-%m-%d at %I.%M.%S %p"
    @capture.captureToFilename = ENV["HOME"]+"/Desktop/ZXing capture #{now}.png"
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
    resize @window.frameRectForContentRect(notification.object.frame).size
  end

end
