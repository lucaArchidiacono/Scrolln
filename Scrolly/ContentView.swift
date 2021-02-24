//
//  ContentView.swift
//  Scrolly
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
                    DeviceView(usbDelegate: usbDelegate, device: device)
                }
            }
        }
    }
}

struct DeviceView: View {
    @ObservedObject var usbDelegate: USBDelegate
    let device: CurrentDevice
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Text(device.name)
                Spacer()
                Toggle("Natrual Scroll",
                       isOn: $usbDelegate.isNonNaturalScrollable)
                    .onChange(of: usbDelegate.isNonNaturalScrollable) { value in
                        if value {
                            usbDelegate.nonNaturalScrollingDevices.append(device.name)
                            usbDelegate.updateSystemPreferences(deviceName: device.name,
                                                                enableScrolling: 1)
                        } else {
                            usbDelegate.updateSystemPreferences(deviceName: device.name,
                                                                enableScrolling: 0)
                            usbDelegate.nonNaturalScrollingDevices.removeAll(where: { $0 == device.name })
                        }
                    }
            }
        }
        Divider()
    }
}
