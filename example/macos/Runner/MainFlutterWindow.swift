import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    flutterViewController.backgroundColor = .clear // <-- Make the view controller transparent
    var windowFrame = self.frame
    windowFrame.size = NSSize(width: 1280, height: 1024)
    self.contentViewController = flutterViewController
    self.minSize = NSSize(width: 1280, height: 1024)
    self.setFrame(windowFrame, display: true)

    // self.titlebarAppearsTransparent = true
    // self.backgroundColor = NSColor.controlAccentColor

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
