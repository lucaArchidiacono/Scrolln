//
//  ContentViewModel.swift
//  Scrolln
//
//  Created by Luca Archidiacono on 01.02.21.
//

import Foundation
import IOKit
import IOKit.usb
import IOKit.hid

class ContentViewModel: USBWatcherDelegate, ObservableObject {
    private var usbWatcher: USBWatcher!
	private let userDefaultKey = "devices"
	private var markedDevices: [Int:Device]

	@Published private(set) var devices: [Device] = []
	
    init() {
		if let data = UserDefaults.standard.data(forKey: userDefaultKey),
		   let markedDevices = try? JSONDecoder().decode([Int:Device].self, from: data) {
			self.markedDevices = markedDevices
		} else {
			self.markedDevices = [:]
		}
		self.usbWatcher = USBWatcher(delegate: self)
    }
    
    internal func deviceAdded(_ device: IOHIDDevice) {
		guard let name = device.name(),
			  let manufacturer = device.manufacturer(),
			  let productID = device.productID() else { return }
        print("device added: \(name)")
		
		if markedDevices[productID] != nil {
			devices.append(Device(name: name, manufacturer: manufacturer, productID: productID, isMarked: true))
			toggleNaturalScrolling()
		} else {
			devices.append(Device(name: name, manufacturer: manufacturer, productID: productID, isMarked: false))
		}
    }

    internal func deviceRemoved(_ device: IOHIDDevice) {
		guard let deviceName = device.name(), let productID = device.productID() else { return }
        print("device removed: \(deviceName)")
		
		devices.removeAll { $0.productID == productID }
		toggleNaturalScrolling()
    }
	
	func updateMarkedDevices(newValue: Device, isEnabled: Bool) {
		guard let index = devices.firstIndex(where: { $0.productID == newValue.productID }) else { return }
		
		let device = Device(name: newValue.name,
							manufacturer: newValue.manufacturer,
							productID: newValue.productID,
							isMarked: isEnabled)
		devices[index] = device
		
		if markedDevices[newValue.productID] != nil && !isEnabled {
			markedDevices.removeValue(forKey: newValue.productID)
		} else {
			markedDevices[newValue.productID] = device
		}
		
		toggleNaturalScrolling()

		guard let data = try? JSONEncoder().encode(markedDevices) else { return }
		UserDefaults.standard.set(data, forKey: userDefaultKey)
	}
	
	private func toggleNaturalScrolling() {
		//If currently the natural-scroll direction is set to "false"/"disabled", then set it to "true"
		let hasMarkedDevice = devices.contains(where: { $0.isMarked })
		
		if swipeScrollDirection() {
			if !devices.isEmpty && hasMarkedDevice {
				setSwipeScrollDirection(false)
			}
		} else {
			if !hasMarkedDevice {
				setSwipeScrollDirection(true)
			}
		}
	}
}

// MARK: Helpers
extension ContentViewModel {
	//For Debugging Purpose
	private func logDevices() {
		print("\n--------------------")
		print("current device List:")
		devices.forEach { device in
			print("-\(device.productID):\(device.name)")
		}
		print("markedDevices List:")
		markedDevices.forEach { key, device in
			print("-\(key):\(device.name)")
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
