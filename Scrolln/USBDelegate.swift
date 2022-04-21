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

struct Device: Identifiable {
    var id = UUID()
    var name: String
}

class USBDelegate: USBWatcherDelegate, ObservableObject {
    private var usbWatcher: USBWatcher!
	private let userDefaultKey = "markedDevices"

    @Published var currentDevices = [Device]()
	@Published private(set) var markedDevices: [Device]

    init() {
		if let data = UserDefaults.standard.object(forKey: userDefaultKey) as? Data,
		   let decodedDevices = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Device] {
			self.markedDevices = decodedDevices
		} else {
			self.markedDevices = [Device]()
		}
		self.usbWatcher = USBWatcher(delegate: self)
    }
    
    internal func deviceAdded(_ device: io_object_t) {
        guard let deviceName = device.name() else { return }
        print("device added: \(deviceName)")
		currentDevices.append(Device(name: deviceName))
		toggleNaturalScrolling()
    }

    internal func deviceRemoved(_ device: io_object_t) {
        guard let deviceName = device.name() else { return }
        print("device removed: \(deviceName)")
		currentDevices.removeAll { $0.name == deviceName }
		toggleNaturalScrolling()
    }
	
	func updateMarkedDevices(newValue: Device, isEnabled: Bool) {
		if isEnabled {
			if !markedDevices.contains(where: { $0.name == newValue.name }) { markedDevices.append(newValue) }
		} else {
			markedDevices.removeAll { $0.name == newValue.name }
		}
		let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: markedDevices, requiringSecureCoding: false)
		UserDefaults.standard.set(encodedData, forKey: userDefaultKey)
		toggleNaturalScrolling()
	}
	
	private func toggleNaturalScrolling() {
		//If currently the natural-scroll direction is set to "false"/"disabled", then set it to "true"
		if swipeScrollDirection() && !markedDevices.isEmpty {
			guard markedDevices.first(where: { markedDevice in
				currentDevices.contains(where: { $0.name ==  markedDevice.name})
			}) != nil else { return }
			setSwipeScrollDirection(false)
		} else {
			setSwipeScrollDirection(true)
		}
	}
}

// MARK: Helpers
extension USBDelegate {
	//For Debugging Purpose
	private func logDevices() {
		print("\n--------------------")
		print("currentDevices List:")
		currentDevices.forEach { device in
			print("-\(device.name)")
		}
		print("markedDevices List:")
		markedDevices.forEach { deviceName in
			print("-\(deviceName)")
		}
		print("--------------------\n")
	}
	
	private func logSwipeDirection(_ isEnabled: Bool) {
		let result = isEnabled ? "enabled" : "NOT enabled"
		print("\n--------------------")
		print("natural swipe direciton is: \(result)")
		print("\n--------------------")
	}
}
