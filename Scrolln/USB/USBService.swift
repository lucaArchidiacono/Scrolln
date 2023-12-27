//
//  USBService.swift
//  Scrolln
//
//  Created by Luca Archidiacono on 31.01.21.
//

import IOKit
import Foundation
import OSLog

protocol USBServiceDelegate: AnyObject {
	/// Called on the main thread when a device is disconnected.
	func devicesUpdated(_ devices: [Device])
}

public class USBService {
	private let dispatchQueue = DispatchQueue(label: "com.luca.Scrolln.USBService", qos: .utility)
	private let logger = Logger.default
	private let runLoop: CFRunLoop = CFRunLoopGetCurrent()

	private var inverseNaturalScrollingDevices = Set<Device.ID>()
	private var allHIDDevices = [Int: IOHIDDevice]()
	private var allDevices: [Device] {
		let hidDevices = allHIDDevices.values.compactMap { Device(hidDevice: $0) }
		return hidDevices
			.compactMap { hidDevice in
				if inverseNaturalScrollingDevices.contains(hidDevice.id) {
					return hidDevice.configure(isNaturalScrollingEnabled: false)
				} else {
					return hidDevice.configure(isNaturalScrollingEnabled: true)
				}
			}
			.sorted { $0.name > $1.name }
	}
	private var isNaturalScrollingEnabled: Bool {
		swipeScrollDirection()
	}

	private let storageManager: StorageManager
	private var manager: IOHIDManager!

	weak var delegate: USBServiceDelegate? {
		didSet {
			delegate?.devicesUpdated(allDevices)
		}
	}

	init(storageManager: StorageManager) {
		self.storageManager = storageManager
		self.manager = IOHIDManagerCreate(kCFAllocatorDefault, 0)

		setup()
	}

	private func setup() {
		setupDevices()
		setupObserver()
	}

	private func setupDevices() {
		if let devices: [Device.ID] = storageManager.fetch() {
			self.inverseNaturalScrollingDevices = Set(devices)
		}
	}

	private func setupObserver() {
		var dict = IOServiceMatching(kIOHIDDeviceKey) as! [String: Any]
		dict[kIOHIDDeviceUsagePageKey] = kHIDPage_GenericDesktop
		dict[kIOHIDDeviceUsageKey] = kHIDUsage_GD_Mouse
		IOHIDManagerSetDeviceMatching(manager, dict as CFDictionary)

		let opaqueSelf = Unmanaged.passUnretained(self).toOpaque()
		IOHIDManagerRegisterDeviceMatchingCallback(
			manager,
			{ context, result, sender, device in
				guard let context = context else { return }
				let service = Unmanaged<USBService>.fromOpaque(context).takeUnretainedValue()
				service.registerNewDevice(device)
			},
			opaqueSelf
		)

		IOHIDManagerRegisterDeviceRemovalCallback(
			manager,
			{ context, result, sender, device in
				guard let context = context else { return }
				let service = Unmanaged<USBService>.fromOpaque(context).takeUnretainedValue()
				service.deregisterDevice(device)
			},
			opaqueSelf
		)

		IOHIDManagerScheduleWithRunLoop(manager, runLoop, CFRunLoopMode.commonModes.rawValue)
		IOHIDManagerSetDeviceMatching(manager, dict as CFDictionary)
		IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
	}

	private func registerNewDevice(_ hidDevice: IOHIDDevice) {
		guard let id = hidDevice.id else { return }

		// we don't want to display the already integrated tackpad in the list of available devices.
		guard !isTrackpad(hidDevice), allHIDDevices[id] == nil else { return }

		logger.info("🖱️ Add new Device:\n\(String(describing: hidDevice))")

		allHIDDevices[id] = hidDevice

		let opaqueSelf = Unmanaged.passUnretained(self).toOpaque()

		IOHIDDeviceRegisterInputValueCallback(
			hidDevice,
			{ context, result, sender, value in
				guard let context = context else { return }
				let service = Unmanaged<USBService>.fromOpaque(context).takeUnretainedValue()

				let element = IOHIDValueGetElement(value)
				let hidDevice = IOHIDElementGetDevice(element)

				if IOHIDElementGetUsagePage(element) == kHIDPage_GenericDesktop &&
					(IOHIDElementGetUsage(element) == kHIDUsage_GD_X || IOHIDElementGetUsage(element) == kHIDUsage_GD_Y) {
					guard let device = Device(hidDevice: hidDevice) else { return }

					service.dispatchQueue.async {
						let isInverseNaturalScrollingDevice = service.inverseNaturalScrollingDevices.contains(device.id)

						if service.isNaturalScrollingEnabled {
							if isInverseNaturalScrollingDevice {
								setSwipeScrollDirection(false)
							}
						} else {
							if !isInverseNaturalScrollingDevice {
								setSwipeScrollDirection(true)
							}
						}
					}
				}
			},
			opaqueSelf)

		IOHIDDeviceScheduleWithRunLoop(hidDevice, runLoop, CFRunLoopMode.commonModes.rawValue)

		delegate?.devicesUpdated(allDevices)
	}

	private func deregisterDevice(_ hidDevice: IOHIDDevice) {
		guard let id = hidDevice.id else { return }

		// we don't want to display the already integrated tackpad in the list of available devices.
		guard !isTrackpad(hidDevice), allHIDDevices[id] != nil else { return }

		logger.info("🔌 Remove old Device: \(String(describing: hidDevice))")

		allHIDDevices.removeValue(forKey: id)

		delegate?.devicesUpdated(allDevices)
	}

	private func isTrackpad(_ hidDevice: IOHIDDevice) -> Bool {
		guard let name = hidDevice.name else { return false }
		return name.lowercased().contains("trackpad")
	}

	func updateNaturalScrolling(on device: Device) {
		dispatchQueue.async { [weak self] in
			guard let self else { return }

			if device.isNaturalScrollingEnabled {
				inverseNaturalScrollingDevices.remove(device.id)
			} else {
				inverseNaturalScrollingDevices.insert(device.id)
			}

			if let devices: [Device.ID] = storageManager.store(content: Array(inverseNaturalScrollingDevices)) {
				inverseNaturalScrollingDevices = Set(devices)
			}

			if isNaturalScrollingEnabled {
				if !device.isNaturalScrollingEnabled {
					setSwipeScrollDirection(false)
				}
			} else {
				if device.isNaturalScrollingEnabled {
					setSwipeScrollDirection(true)
				}
			}

			DispatchQueue.main.async {
				self.delegate?.devicesUpdated(self.allDevices)
			}
		}
	}
}

extension USBService {
	static var preview: USBService {
		return USBService(storageManager: StorageManager(fileName: "devices"))
	}
}


/// Scroll DOWN means go UP
/// Scroll UP means go DOWN
