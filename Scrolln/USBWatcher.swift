//
//  USBWatcher.swift
//  Scrolln
//
//  Created by Luca Archidiacono on 31.01.21.
//

import IOKit
import Foundation


protocol USBWatcherDelegate: AnyObject {
    /// Called on the main thread when a device is connected.
    func deviceAdded(_ device: IOHIDDevice)
    /// Called on the main thread when a device is disconnected.
    func deviceRemoved(_ device: IOHIDDevice)
}

public class USBWatcher {
    private var manager: IOHIDManager!
    private weak var delegate: USBWatcherDelegate?

    init(delegate: USBWatcherDelegate) {
        self.delegate = delegate
        self.manager = IOHIDManagerCreate(kCFAllocatorDefault, 0)

        func hidDeviceAdded(context: UnsafeMutableRawPointer?, result: IOReturn, sender: UnsafeMutableRawPointer?, device: IOHIDDevice) {
            guard let context = context else { return }
            let watcher = Unmanaged<USBWatcher>.fromOpaque(context).takeUnretainedValue()
            // we don't want to display the already integrated tackpad in the list of available devices.
            guard let name = device.name(), !name.lowercased().contains("trackpad") else { return }
            watcher.delegate?.deviceAdded(device)
        }

        func hidDeviceRemoved(context: UnsafeMutableRawPointer?, result: IOReturn, sender: UnsafeMutableRawPointer?, device: IOHIDDevice) {
            guard let context = context else { return }
            let watcher = Unmanaged<USBWatcher>.fromOpaque(context).takeUnretainedValue()
            watcher.delegate?.deviceRemoved(device)
        }


        let opaqueSelf = Unmanaged.passUnretained(self).toOpaque()
        var dict = IOServiceMatching(kIOHIDDeviceKey) as! [String: Any]
        dict[kIOHIDDeviceUsagePageKey] = kHIDPage_GenericDesktop
        dict[kIOHIDDeviceUsageKey] = kHIDUsage_GD_Mouse
        IOHIDManagerSetDeviceMatching(manager, dict as CFDictionary)

        IOHIDManagerRegisterDeviceMatchingCallback(manager, hidDeviceAdded(context:result:sender:device:), opaqueSelf)
        IOHIDManagerRegisterDeviceRemovalCallback(manager, hidDeviceRemoved(context:result:sender:device:), opaqueSelf)

        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetCurrent(), CFRunLoopMode.commonModes.rawValue)
    }
}
