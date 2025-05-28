//
//  SimpleStorageService.swift
//  ModernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/28/25.
//


import Foundation
import SwiftUI

/// Simplified storage service that directly exposes ModernStorage
@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public final class SimpleStorageService: ObservableObject {
	public let storage: ModernStorage
	
	@MainActor
	public var statistics: StorageStatisticsManager {
		storage.statistics
	}
	
	public init(
		userDefaultsManager: UserDefaultsManaging = UserDefaultsManager(),
		keychainManager: KeychainManaging = KeychainManager()
	) {
		self.storage = ModernStorage(
			userDefaultsManager: userDefaultsManager,
			keychainManager: keychainManager
		)
	}
	
	// MARK: - Convenience Methods
	
	@MainActor
	public func set<T: Codable>(_ value: T, forKey key: String, storageType: StorageType = .automatic) {
		storage.set(value, forKey: key, storageType: storageType)
	}
	
	@MainActor
	public func get<T: Codable>(key: String, defaultValue: T, storageType: StorageType = .automatic) -> T {
		storage.get(key: key, defaultValue: defaultValue, storageType: storageType)
	}
	
	@MainActor
	public func remove(key: String, storageType: StorageType = .automatic) {
		storage.remove(key: key, storageType: storageType)
	}
	
	@MainActor
	public func setBool(_ value: Bool, forKey key: String) {
		storage.setBool(value, forKey: key)
	}
	
	@MainActor
	public func getBool(forKey key: String, defaultValue: Bool = false) -> Bool {
		storage.getBool(forKey: key, defaultValue: defaultValue)
	}
	
	@MainActor
	public func setInt(_ value: Int, forKey key: String) {
		storage.setInt(value, forKey: key)
	}
	
	@MainActor
	public func getInt(forKey key: String, defaultValue: Int = 0) -> Int {
		storage.getInt(forKey: key, defaultValue: defaultValue)
	}
	
	@MainActor
	public func setDouble(_ value: Double, forKey key: String) {
		storage.setDouble(value, forKey: key)
	}
	
	@MainActor
	public func getDouble(forKey key: String, defaultValue: Double = 0.0) -> Double {
		storage.getDouble(forKey: key, defaultValue: defaultValue)
	}
	
	@MainActor
	public func setString(_ value: String, forKey key: String) {
		storage.setString(value, forKey: key)
	}
	
	@MainActor
	public func getString(forKey key: String, defaultValue: String = "") -> String {
		storage.getString(forKey: key, defaultValue: defaultValue)
	}
}
