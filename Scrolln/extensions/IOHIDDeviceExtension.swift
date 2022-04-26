//
//  IOHIDDeviceExtension.swift
//  Scrolln
//
//  Created by Luca Archidiacono on 26.04.22.
//

import Foundation


extension IOHIDDevice {
    func name() -> String? {
        let name = IOHIDDeviceGetProperty(self, kIOHIDProductKey as CFString) as? String
        guard let name = name else { return nil }
        return name
    }
}
