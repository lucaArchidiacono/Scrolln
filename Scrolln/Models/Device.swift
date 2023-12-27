//
//  Device.swift
//  Scrolln
//
//  Created by Luca Archidiacono on 04.07.22.
//

import Foundation

struct Device: Identifiable, Hashable, Codable {
	var id: Int
	var name: String
	var manufacturer: String?
	var productID: Int?
	var vendorID: Int?
	var isNaturalScrollingEnabled: Bool

	init?(hidDevice: IOHIDDevice) {
		guard let id = hidDevice.id,
			  let name = hidDevice.name else {
			return nil
		}

		self.init(id: id, 
				  name: name, 
				  manufacturer: hidDevice.manufacturer,
				  productID: hidDevice.productID,
				  vendorID: hidDevice.vendorID,
				  isNaturalScrollingEnabled: true)
	}
	
	init(id: Int, name: String, manufacturer: String?, productID: Int?, vendorID: Int?, isNaturalScrollingEnabled: Bool) {
		self.id = id
		self.name = name
		self.manufacturer = manufacturer
		self.productID = productID
		self.isNaturalScrollingEnabled = isNaturalScrollingEnabled
	}

	func configure(isNaturalScrollingEnabled: Bool) -> Self {
		Device(id: id,
			   name: name,
			   manufacturer: manufacturer,
			   productID: productID,
			   vendorID: vendorID,
			   isNaturalScrollingEnabled: isNaturalScrollingEnabled)
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
