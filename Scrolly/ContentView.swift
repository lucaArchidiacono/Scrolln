//
//  ContentView.swift
//  Scrolly
//
//  Created by Luca Archidiacono on 31.01.21.
//

import SwiftUI

struct ContentView: View {
    let example = usbDelegate()
    var body: some View {
        Text("Hello, World!")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

class usbDelegate: USBWatcherDelegate {
    private var usbWatcher: USBWatcher!
    
    init() {
        usbWatcher = USBWatcher(delegate: self)
    }
    internal func deviceAdded(_ device: io_object_t) {
        print("device added: \(device.name() ?? "<unknown>")")
    }
    internal func deviceRemoved(_ device: io_object_t) {
        print("device removed: \(device.name() ?? "<unknown>")")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
