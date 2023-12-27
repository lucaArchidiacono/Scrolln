//
//  IOHIDDevice+.swift
//  Scrolln
//
//  Created by Luca Archidiacono on 26.04.22.
//

import Foundation


extension IOHIDDevice {
	var name: String? {
		guard let name = IOHIDDeviceGetProperty(self, kIOHIDProductKey as CFString) as? String else {
			return nil
		}
        return name
    }

	var manufacturer: String? {
		guard let manufacturer = IOHIDDeviceGetProperty(self, kIOHIDManufacturerKey as CFString) as? String else {
			return nil
		}
		return manufacturer
	}
	
	var productID: Int? {
		guard let productID = IOHIDDeviceGetProperty(self, kIOHIDProductIDKey as CFString) as? Int else {
			return nil
		}
		return productID
	}
	
	var vendorID: Int? {
		guard let vendorID = IOHIDDeviceGetProperty(self, kIOHIDVendorIDKey as CFString) as? Int else {
			return nil
		}
		return vendorID
	}

	var id: Int? {
		guard let id = IOHIDDeviceGetProperty(self, kIOHIDUniqueIDKey as CFString) as? Int else {
			return nil
		}
		return id
	}
}
