//
//  USBDelegate.swift
//  Scrolly
//
//  Created by Luca Archidiacono on 01.02.21.
//

import Foundation
import IOKit
import IOKit.usb
import IOKit.hid

class USBDelegate: USBWatcherDelegate {
    private var usbWatcher: USBWatcher!
    
    private enum Devices: String {
        case Logitech
    }
    
    init() {
        usbWatcher = USBWatcher(delegate: self)
    }
    
    internal func deviceAdded(_ device: io_object_t) {
        print("device added: \(device.name() ?? "<unknown>")")
        if let deviceName = device.name(), deviceName.contains(Devices.Logitech.rawValue) {
            let disableNaturalScrolling =   """
                                                try
                                                    tell application "System Preferences"
                                                        set current pane to pane "com.apple.preference.trackpad"
                                                    end tell
                                                    tell application "System Events"
                                                        tell process "System Preferences"
                                                            delay 0.6
                                                            set checkBoxOne to checkbox 1 of tab group 1 of window "Trackpad"
                                                            click radio button "Scroll & Zoom" of tab group 1 of window "Trackpad"
                                                            tell checkBoxOne to if value is 1 then click
                                                            tell application "System Preferences" to quit
                                                        end tell
                                                    end tell
                                                end try
                                            """
            runAppleScript(source: disableNaturalScrolling)
        }
    }
    internal func deviceRemoved(_ device: io_object_t) {
        print("device removed: \(device.name() ?? "<unknown>")")
        if let deviceName = device.name(), deviceName.contains(Devices.Logitech.rawValue) {
            let enableNaturalScrolling =    """
                                                try
                                                    tell application "System Preferences"
                                                        set current pane to pane "com.apple.preference.trackpad"
                                                    end tell
                                                    tell application "System Events"
                                                        tell process "System Preferences"
                                                            delay 0.6
                                                            set checkBoxOne to checkbox 1 of tab group 1 of window "Trackpad"
                                                            click radio button "Scroll & Zoom" of tab group 1 of window "Trackpad"
                                                            tell checkBoxOne to if value is 0 then click
                                                            tell application "System Preferences" to quit
                                                        end tell
                                                    end tell
                                                end try
                                            """
            runAppleScript(source: enableNaturalScrolling)
        }
    }
    
    
    private func runAppleScript(source: String) {
        if let scriptObject = NSAppleScript(source: source) {
            var error: NSDictionary?
            scriptObject.executeAndReturnError(&error)
            if let err = error {
                print(err)
            }
        }
    }
}
