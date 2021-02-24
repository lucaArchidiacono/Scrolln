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
        List {
            ForEach(usbDelegate.currentDevices.indexed(), id: \.1.id) { index, device in
                VStack(alignment: .leading) {
                    HStack() {
                        Text(device.name)
                        Toggle("Natrual Scroll",
                               isOn: self.$usbDelegate.currentDevices[index].enabled)
                            .onChange(of: device.enabled) { value in
                                if value {
                                    usbDelegate.nonNaturalScrollingDevices.append(device.name)
                                    usbDelegate.updateSystemPreferences(deviceName: device.name,
                                                                        enableScrolling: 1)
                                } else {
                                    usbDelegate.updateSystemPreferences(deviceName: device.name,
                                                                        enableScrolling: 0)
                                }
                            }
                    }
                }
            }
        }
    }
}
