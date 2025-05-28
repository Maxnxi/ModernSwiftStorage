//
//  StorageServiceKeyswift
//  ModernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/28/25.
//


import Foundation
import SwiftUI

// MARK: - Environment Key

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public extension EnvironmentValues {
	var modernStorage: ModernStorage {
		get {
			// Access the underlying ModernStorage through the StorageService
			let service = self[StorageServiceKey.self]
			return service.modernStorage
		}
		set {
			// This is read-only as ModernStorage is managed by StorageService
		}
	}
}

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public extension EnvironmentValues {
	var storageService: StorageService {
		get { self[StorageServiceKey.self] }
		set { self[StorageServiceKey.self] = newValue }
	}
}

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
private struct StorageServiceKey: @preconcurrency EnvironmentKey {
	@MainActor
	static var defaultValue: StorageService {
		return _defaultStorageService
	}
	
	// Create the default instance with MainActor isolation
	@MainActor
	private static let _defaultStorageService: StorageService = {
		let userDefaultsManager = UserDefaultsManager()
		let keychainManager = KeychainManager()
		return StorageService(
			userDefaultsManager: userDefaultsManager,
			keychainManager: keychainManager
		)
	}()
}
