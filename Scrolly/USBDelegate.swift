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
    var id = UUID()
    var name: String
}

class USBDelegate: USBWatcherDelegate, ObservableObject {
    private var usbWatcher: USBWatcher!

    @Published var currentDevices = [CurrentDevice]()
    @Published var nonNaturalScrollingDevices = [String]()
    @Published var isNonNaturalScrollable = false

    init() {
        self.usbWatcher = USBWatcher(delegate: self)
    }
    
    internal func deviceAdded(_ device: io_object_t) {
        guard let deviceName = device.name() else { return }
        print("device added: \(deviceName)")
        if nonNaturalScrollingDevices.contains(deviceName) {
            isNonNaturalScrollable = true
            currentDevices.append(CurrentDevice(name: deviceName))
            updateSystemPreferences(deviceName: deviceName,
                                    enableScrolling: 1)
        } else {
            currentDevices.append(CurrentDevice(name: deviceName))
        }
    }

    internal func deviceRemoved(_ device: io_object_t) {
        guard let deviceName = device.name() else { return }
        print("device removed: \(deviceName)")
        if nonNaturalScrollingDevices.contains(deviceName) {
            currentDevices.removeAll(where: { $0.name == deviceName })
            updateSystemPreferences(deviceName: deviceName,
                                    enableScrolling: 0)
        } else {
            currentDevices.removeAll(where: { $0.name == deviceName })
        }
    }
    
    func updateSystemPreferences(deviceName: String, enableScrolling: Int) {
        nonNaturalScrollingDevices.forEach { nonNaturalScrollingDevice in
            if deviceName.contains(nonNaturalScrollingDevice) {
                runAppleScript(enableScrolling: enableScrolling)
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
