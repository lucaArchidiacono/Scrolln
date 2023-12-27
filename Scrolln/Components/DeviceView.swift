//
//  DeviceView.swift
//  Scrolln
//
//  Created by Luca Archidiacono on 23.12.2023.
//

import Foundation
import SwiftUI

struct DeviceView: View {
	let device: Device

	let isOn: (Bool) -> Void

	var body: some View {
		VStack(alignment: .leading) {
			Text("[\(device.id.formatted(.number.grouping(.never)))] ")
				.frame(maxWidth: .infinity)
			HStack() {
				Text("\(device.manufacturer ?? "<UNKNOWN>") : \(device.name)")
				Spacer()
				Toggle("Natural Scroll", isOn: Binding(
					get: {
						return device.isNaturalScrollingEnabled
					}, set: { isEnabled in
						isOn(isEnabled)
					}))
			}
		}
		.padding()
	}
}

#Preview {
	let trackpad = Device(id: 134343434,
						  name: "Trackpad",
						  manufacturer: "Apple",
						  productID: 696969,
						  vendorID: 1234,
						  isNaturalScrollingEnabled: true)
	return DeviceView(device: trackpad) { isEnabled in
		print("Natural scrolling on device \(trackpad.name) is enabled: \(isEnabled)")
	}
}
