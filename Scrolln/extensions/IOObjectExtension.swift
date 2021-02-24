//
//  IOObjectExtension.swift
//  Scrolly
//
//  Created by Luca Archidiacono on 31.01.21.
//

import Foundation

extension io_object_t {
    /// - Returns: The device's name.
    func name() -> String? {
        let buf = UnsafeMutablePointer<io_name_t>.allocate(capacity: 1)
        defer { buf.deallocate() }
        return buf.withMemoryRebound(to: CChar.self, capacity: MemoryLayout<io_name_t>.size) {
            if IORegistryEntryGetName(self, $0) == KERN_SUCCESS {
                return String(cString: $0)
            }
            return nil
        }
    }
}
