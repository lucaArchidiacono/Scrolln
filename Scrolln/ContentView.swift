//
//  ContentView.swift
//  Scrolln
//
//  Created by Luca Archidiacono on 31.01.21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var usbDelegate: USBDelegate
    
    var body: some View {
        if usbDelegate.currentDevices.isEmpty {
            Text("It seems like there are no devices connected to your Mac 🧐")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(usbDelegate.currentDevices) { device in
                    DeviceListView(usbDelegate: usbDelegate, device: device)
                }
			}
		}
	}
}

struct DeviceListView: View {
    @ObservedObject var usbDelegate: USBDelegate
    let device: CurrentDevice
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Text(device.name)
                Spacer()
				Toggle("Normal Scroll", isOn: binding(for: device.name))
            }
        }
        Divider()
    }
	
	private func binding(for key: String) -> Binding<Bool> {
		return Binding(get: {
			return self.usbDelegate.markedDevices2.contains(where: { $0 == key })
		}, set: {
			self.usbDelegate.updateMarkedDevices(newValue: key, isEnabled: $0)
		})
	}
}
