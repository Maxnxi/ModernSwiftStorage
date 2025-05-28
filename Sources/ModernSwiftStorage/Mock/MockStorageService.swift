//
//  MockStorageService.swift
//  ModernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/28/25.
//

import Foundation

// MARK: - Testing Utilities

#if DEBUG
public final class MockStorageService: ObservableObject {
	private var userDefaultsStorage: [String: Any] = [:]
	private var keychainStorage: [String: Any] = [:]
	
	@MainActor
	public var statistics: StorageStatisticsManager {
		fatalError("Statistics not available in mock")
	}
	
	@MainActor
	public func set<T: Codable>(_ value: T, forKey key: String, storageType: StorageType = .automatic) {
		switch storageType {
		case .userDefaults, .automatic:
			userDefaultsStorage[key] = value
		case .keychain:
			keychainStorage[key] = value
		}
	}
	
	@MainActor
	public func get<T: Codable>(key: String, defaultValue: T, storageType: StorageType = .automatic) -> T {
		switch storageType {
		case .userDefaults, .automatic:
			return userDefaultsStorage[key] as? T ?? defaultValue
		case .keychain:
			return keychainStorage[key] as? T ?? defaultValue
		}
	}
	
	@MainActor
	public func remove(key: String, storageType: StorageType = .automatic) {
		switch storageType {
		case .userDefaults, .automatic:
			userDefaultsStorage.removeValue(forKey: key)
		case .keychain:
			keychainStorage.removeValue(forKey: key)
		}
	}
	
	@MainActor
	public func setBool(_ value: Bool, forKey key: String) {
		userDefaultsStorage[key] = value
	}
	
	@MainActor
	public func getBool(forKey key: String, defaultValue: Bool = false) -> Bool {
		return userDefaultsStorage[key] as? Bool ?? defaultValue
	}
	
	@MainActor
	public func setInt(_ value: Int, forKey key: String) {
		userDefaultsStorage[key] = value
	}
	
	@MainActor
	public func getInt(forKey key: String, defaultValue: Int = 0) -> Int {
		return userDefaultsStorage[key] as? Int ?? defaultValue
	}
	
	@MainActor
	public func setDouble(_ value: Double, forKey key: String) {
		userDefaultsStorage[key] = value
	}
	
	@MainActor
	public func getDouble(forKey key: String, defaultValue: Double = 0.0) -> Double {
		return userDefaultsStorage[key] as? Double ?? defaultValue
	}
	
	@MainActor
	public func setString(_ value: String, forKey key: String) {
		userDefaultsStorage[key] = value
	}
	
	@MainActor
	public func getString(forKey key: String, defaultValue: String = "") -> String {
		return userDefaultsStorage[key] as? String ?? defaultValue
	}
	
	public func clearAll() {
		userDefaultsStorage.removeAll()
		keychainStorage.removeAll()
	}
}
#endif
