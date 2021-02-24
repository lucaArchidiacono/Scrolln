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

struct CurrentDevice: Identifiable {
    let id = UUID()
    let name: String
}

class USBDelegate: USBWatcherDelegate, ObservableObject {
    private var usbWatcher: USBWatcher!

    @Published var currentDevices = [CurrentDevice]()
    var nonNaturalScrollingDevices: [String] = ["Logitech", "USB Receiver"]

    init() {
        self.usbWatcher = USBWatcher(delegate: self)
    }
    
    internal func deviceAdded(_ device: io_object_t) {
        guard let deviceName = device.name() else { return }
        print("device added: \(deviceName)")
        currentDevices.append(CurrentDevice(name: deviceName))
        nonNaturalScrollingDevices.forEach { nonNaturalScrollingDevice in
            if deviceName.contains(nonNaturalScrollingDevice) {
                runAppleScript(enableScrolling: 1)
            }
        }
    }

    internal func deviceRemoved(_ device: io_object_t) {
        guard let deviceName = device.name() else { return }
        print("device removed: \(deviceName)")
        nonNaturalScrollingDevices.forEach { nonNaturalScrollingDevice in
            if deviceName.contains(nonNaturalScrollingDevice) {
                runAppleScript(enableScrolling: 0)
            }
        }
    }
    
    
    private func runAppleScript(enableScrolling: Int) {
        let source =    """
                        try
                            tell application "System Preferences"
                                set current pane to pane "com.apple.preference.trackpad"
                            end tell
                            tell application "System Events"
                                tell process "System Preferences"
                                    delay 0.6
                                    set checkBoxOne to checkbox 1 of tab group 1 of window "Trackpad"
                                    click radio button "Scroll & Zoom" of tab group 1 of window "Trackpad"
                                    tell checkBoxOne to if value is \(enableScrolling) then click
                                    tell application "System Preferences" to quit
                                end tell
                            end tell
                        end try
                        """
        if let scriptObject = NSAppleScript(source: source) {
            var error: NSDictionary?
            scriptObject.executeAndReturnError(&error)
            if let err = error {
                print(err)
            }
        }
    }
}
