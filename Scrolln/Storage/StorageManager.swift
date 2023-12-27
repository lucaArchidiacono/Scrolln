//
//  StorageManager.swift
//  Scrolln
//
//  Created by Luca Archidiacono on 23.12.2023.
//

import Foundation
import OSLog

class StorageManager {
	private let logger = Logger.default
	private let decoder = JSONDecoder()
	private let encoder = JSONEncoder()
	private var storageURL: URL?

	init(fileName: String) {
		do {
			let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
			let urlWithFileName = url.appendingPathComponent(fileName, conformingTo: .json)

			if !FileManager.default.fileExists(atPath: urlWithFileName.path()) {
				FileManager.default.createFile(atPath: urlWithFileName.path(), contents: nil)
			}

			storageURL = urlWithFileName
			logger.info("ℹ️ \(urlWithFileName)")
		} catch {
			logger.info("\(error)")
			storageURL = nil
		}
	}

	func store<T: Decodable>(content: Codable) -> T? {
		guard let storageURL else {
			logger.warning("⚠️ `storageURL` is nil!")
			return nil
		}

		do {
			let data = try encoder.encode(content)
			try data.write(to: storageURL, options: .atomic)

			return fetch()
		} catch {
			logger.error("🚫 \(error)")
			return nil
		}
	}

	func fetch<T: Decodable>() -> T? {
		guard let storageURL else {
			logger.warning("⚠️ `storageURL` is nil!")
			return nil
		}

		guard let data = FileManager.default.contents(atPath: storageURL.path()) else {
			logger.warning("⚠️ Was not able to load data from: \(storageURL.path())")
			return nil
		}

		guard !data.isEmpty else {
			logger.info("ℹ️ There is no data stored inside: \(storageURL.path())")
			return nil
		}

		do {
			let result = try decoder.decode(T.self, from: data)
			return result
		} catch {
			logger.error("🚫 \(error)")
			return nil
		}
	}
}
