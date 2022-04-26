//
//  ContentView.swift
//  Scrolln
//
//  Created by Luca Archidiacono on 31.01.21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        if viewModel.currentDevices.isEmpty {
            Text("It seems like there are no devices connected to your Mac 🧐")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(viewModel.currentDevices) { device in
                    DeviceListView(viewModel: viewModel, device: device)
                }
			}
		}
	}
}

struct DeviceListView: View {
    @ObservedObject var viewModel: ContentViewModel
    let device: Device
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Text(device.name)
                Spacer()
				Toggle("Normal Scroll", isOn: binding(for: device))
            }
        }
        Divider()
    }
	
	private func binding(for device: Device) -> Binding<Bool> {
		return Binding(
		get: {
			return self.viewModel.markedDevices.contains(where: { $0.name == device.name })
		}, set: {
			self.viewModel.updateMarkedDevices(newValue: device, isEnabled: $0)
		})
	}
}
