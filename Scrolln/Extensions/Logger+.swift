//
//  Logger+.swift
//  Scrolln
//
//  Created by Luca Archidiacono on 23.12.2023.
//

import Foundation
import OSLog

extension Logger {
	static let `default` = Logger(subsystem: Bundle.main.bundleIdentifier!, category: #file)
}
