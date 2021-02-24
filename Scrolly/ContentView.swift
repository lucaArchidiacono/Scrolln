//
//  ContentView.swift
//  Scrolly
//
//  Created by Luca Archidiacono on 31.01.21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var usbDelegate = USBDelegate()

    var body: some View {
        List(usbDelegate.currentDevices) { device in
            VStack(alignment: .leading) {
                Text(device.name)
            }
        }
//        Text("Hello, Scroller!")
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
