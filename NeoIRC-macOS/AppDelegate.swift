//
//  AppDelegate.swift
//  NeoIRC-macOS
//
//  Created by Helge Heß on 23.05.20.
//  Copyright © 2020 ZeeZide GmbH. All rights reserved.
//

import Cocoa
import SwiftUI
import NeoIRCClient

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  lazy var serviceManager = IRCServiceManager(passwordProvider: "")
  
  var window: NSWindow!


  func applicationDidFinishLaunching(_ aNotification: Notification) {
    serviceManager.resume()
    
    // Create the SwiftUI view that provides the window contents.
    let contentView = NeoIRCClientView().environmentObject(serviceManager)

    // Create the window and set the content view. 
    window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
      styleMask: [
        .titled, .closable, .miniaturizable, .resizable,
        .fullSizeContentView
      ],
      backing: .buffered, defer: false
    )
    window.center()
    window.setFrameAutosaveName("Main Window")
    window.contentView = NSHostingView(rootView: contentView)
    window.makeKeyAndOrderFront(nil)
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    serviceManager.suspend()
  }

  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication)
       -> Bool
  {
    return true
  }
}
