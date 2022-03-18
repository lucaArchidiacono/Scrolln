//
//  AppDelegate.swift
//  Scrolln
//
//  Created by Luca Archidiacono on 31.01.21.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(usbDelegate: USBDelegate())
        
        // Create popover
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 200)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
		self.popover = popover
        
        // Create status item
        statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = statusBarItem.button {
            button.image = NSImage(named: "Icon-Opaque")
            button.action = #selector(togglePopover(_:))
        }
    }
    
	// Once tapped on the MenuIcon a popover should be shown.
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if popover.isShown {
               popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }
}

