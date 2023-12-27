//
//  ContentView.swift
//  Scrolln
//
//  Created by Luca Archidiacono on 31.01.21.
//

import SwiftUI

struct ContentView: View {
	@StateObject private var viewModel: ContentViewModel

	init(usbService: USBService) {
		self._viewModel = .init(wrappedValue: ContentViewModel(usbService: usbService))
	}

    var body: some View {
		ZStack {
			if viewModel.isLoading {
				ProgressView()
			} else {
				if viewModel.devices.isEmpty {
					VStack {
						Text("It seems like there are no devices connected to your Mac 🧐")
						HoverableButton(action: .quit) {
							NSApplication.shared.terminate(self)
						}
					}
				} else {
					List {
						ForEach(viewModel.devices, id: \.id) { device in
							DeviceView(device: device) { isEnabled in
								viewModel.updateNaturalScrolling(on: device, isEnabled: isEnabled)
							}
						}

						HoverableButton(action: .quit) {
							NSApplication.shared.terminate(self)
						}
					}
				}
			}
		}
		.frame(minWidth: 400, minHeight: 200)
	}
}

#Preview {
	ContentView(usbService: USBService.preview)
}
