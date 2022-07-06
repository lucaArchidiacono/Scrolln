//
//  IOHIDDeviceExtension.swift
//  Scrolln
//
//  Created by Luca Archidiacono on 26.04.22.
//

import Foundation


extension IOHIDDevice {
    func name() -> String? {
        let name = IOHIDDeviceGetProperty(self, kIOHIDProductKey as CFString) as? String
        guard let name = name else { return nil }
        return name
    }
	
	func manufacturer() -> String? {
		let manufacturer = IOHIDDeviceGetProperty(self, kIOHIDManufacturerKey as CFString) as? String
		guard let manufacturer = manufacturer else { return nil }
		return manufacturer
	}
	
	func productID() -> Int? {
		let productID = IOHIDDeviceGetProperty(self, kIOHIDProductIDKey as CFString) as? Int
		guard let productID = productID else { return nil }
		return productID
	}
	
	func vendorID() -> Int? {
		let vendorID = IOHIDDeviceGetProperty(self, kIOHIDVendorIDKey as CFString) as? Int
		guard let vendorID = vendorID else { return nil }
		return vendorID
	}
}
