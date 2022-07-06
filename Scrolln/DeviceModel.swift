//
//  DeviceModel.swift
//  Scrolln
//
//  Created by Luca Archidiacono on 04.07.22.
//

import Foundation

struct Device: Identifiable, Codable {
	var id: UUID
	var name: String
	var manufacturer: String
	var productID: Int
	var isMarked: Bool
	
	init(id: UUID, name: String, manufacturer: String, productID: Int, isMarked: Bool) {
		self.id = id
		self.name = name
		self.manufacturer = manufacturer
		self.productID = productID
		self.isMarked = isMarked
	}
	
	init(name: String, manufacturer: String, productID: Int, isMarked: Bool = false) {
		self.id = UUID()
		self.name = name
		self.manufacturer = manufacturer
		self.productID = productID
		self.isMarked = isMarked
	}
}
