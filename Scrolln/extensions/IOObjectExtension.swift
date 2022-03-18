//
//  IOObjectExtension.swift
//  Scrolln
//
//  Created by Luca Archidiacono on 31.01.21.
//

import Foundation

extension io_object_t {
    /// - Returns: The device's name.
    func name() -> String? {
        let buf = UnsafeMutablePointer<io_name_t>.allocate(capacity: 1)
		// As we allocate space we need to ensure that at the end of the function a deallocation happens.
        defer { buf.deallocate() }
        return buf.withMemoryRebound(to: CChar.self, capacity: MemoryLayout<io_name_t>.size) {
			guard IORegistryEntryGetName(self, $0) == KERN_SUCCESS else { return nil }
			return String(cString: $0)
        }
    }
}
