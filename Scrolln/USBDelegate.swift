//
//  USBDelegate.swift
//  Scrolln
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
	private let userDefaultKey = "markedDevices"

    @Published var currentDevices = [CurrentDevice]()
	@Published private(set) var markedDevices2: [String]

    init() {
		self.markedDevices2 = UserDefaults.standard.object(forKey: userDefaultKey) as? [String] ?? [String]()
		self.usbWatcher = USBWatcher(delegate: self)
    }
    
    internal func deviceAdded(_ device: io_object_t) {
        guard let deviceName = device.name() else { return }
        print("device added: \(deviceName)")
		currentDevices.append(CurrentDevice(name: deviceName))
		toggleNaturalScrolling()
    }

    internal func deviceRemoved(_ device: io_object_t) {
        guard let deviceName = device.name() else { return }
        print("device removed: \(deviceName)")
		currentDevices.removeAll { $0.name == deviceName }
		toggleNaturalScrolling()
    }
	
	func updateMarkedDevices(newValue: String, isEnabled: Bool) {
		if isEnabled {
			if !markedDevices2.contains(newValue) { markedDevices2.append(newValue) }
		} else {
			markedDevices2.removeAll { $0 == newValue }
		}
		UserDefaults.standard.set(markedDevices2, forKey: userDefaultKey)
		toggleNaturalScrolling()
	}
	
	//For Debugging Purpose
	private func log() {
		print("\n--------------------")
		print("currentDevices List:")
		currentDevices.forEach { device in
			print("-\(device.name)")
		}
		print("markedDevices2 List:")
		markedDevices2.forEach { deviceName in
			print("-\(deviceName)")
		}
		print("--------------------\n")
	}
	
	private func toggleNaturalScrolling() {
		//If currently the natural-scroll direction is set to "false"/"disabled", then set it to "true"
		if swipeScrollDirection() && !markedDevices2.isEmpty {
			setSwipeScrollDirection(false)
		} else {
			setSwipeScrollDirection(true)
		}
	}
}
