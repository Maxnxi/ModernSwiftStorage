//
//  StorageMigrationManager.swift
//  ModernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/28/25.
//

import Foundation

// MARK: - Storage Migration Helper

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public final class StorageMigrationManager {
	private let storage: ModernStorage
	
	public init(storage: ModernStorage) {
		self.storage = storage
	}
	
	// Convenience initializer that uses shared instance
	@MainActor
	public convenience init() {
		self.init(storage: ModernStorage.shared)
	}
	
	@MainActor
	public func migrateFromUserDefaultsToKeychain(key: String, accessibility: KeychainItemAccessibility = .whenUnlocked) -> Bool {
		// Get value from UserDefaults
		guard let data = storage.internalUserDefaultsManager.get(Data.self, forKey: key) else {
			return false
		}
		
		// Save to Keychain
		let success = storage.internalKeychainManager.set(data, forKey: key, accessibility: accessibility)
		
		// Remove from UserDefaults if successful
		if success {
			storage.internalUserDefaultsManager.remove(forKey: key)
		}
		
		return success
	}
	
	@MainActor
	public func migrateFromKeychainToUserDefaults(key: String, accessibility: KeychainItemAccessibility = .whenUnlocked) -> Bool {
		// Get value from Keychain
		guard let data = storage.internalKeychainManager.get(Data.self, forKey: key, accessibility: accessibility) else {
			return false
		}
		
		// Save to UserDefaults
		storage.internalUserDefaultsManager.set(data, forKey: key)
		
		// Remove from Keychain
		return storage.internalKeychainManager.remove(forKey: key, accessibility: accessibility)
	}
}
