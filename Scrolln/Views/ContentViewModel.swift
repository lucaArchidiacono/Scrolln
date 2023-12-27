//
//  ContentViewModel.swift
//  Scrolln
//
//  Created by Luca Archidiacono on 01.02.21.
//

import Foundation
import OSLog

class ContentViewModel: ObservableObject {
	private let usbService: USBService

	private let logger = Logger.default

	@Published private(set) var isLoading: Bool = false
	@Published private(set) var devices: [Device] = []

	init(usbService: USBService) {
		self.usbService = usbService

		self.usbService.delegate = self
	}

	func updateNaturalScrolling(on device: Device, isEnabled: Bool) {
		usbService.updateNaturalScrolling(on: device.configure(isNaturalScrollingEnabled: isEnabled))
	}
}

extension ContentViewModel: USBServiceDelegate {
	internal func devicesUpdated(_ devices: [Device]) {
		self.devices = devices
	}
}

//// MARK: Helpers
//extension ContentViewModel {
//	//For Debugging Purpose
//	private func logDevices() {
//		print("\n--------------------")
//		print("current device List:")
//		devices.forEach { device in
//			print("-\(device.productID):\(device.name)")
//		}
//		print("markedDevices List:")
//		markedDevices.forEach { key, device in
//			print("-\(key):\(device.name)")
//		}
//		print("--------------------\n")
//	}
//	
//	private func logSwipeDirection(_ isEnabled: Bool) {
//		let result = isEnabled ? "enabled" : "NOT enabled"
//		print("\n--------------------")
//		print("natural swipe direciton is: \(result)")
//		print("\n--------------------")
//	}
//}
