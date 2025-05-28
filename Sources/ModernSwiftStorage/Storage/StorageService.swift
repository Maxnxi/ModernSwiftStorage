//
//  StorageService.swift
//  modernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/27/25.
//


import Foundation
import SwiftUI


/// Main storage service that wraps ModernStorage for SwiftUI
@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public final class StorageService: ObservableObject {
	private let modernStorageInstance: ModernStorage
	
	@MainActor
	public var statistics: StorageStatisticsManager {
		modernStorageInstance.statistics
	}
	
	// Expose ModernStorage safely
	public var modernStorage: ModernStorage {
		modernStorageInstance
	}
	
	public init(
		userDefaultsManager: UserDefaultsManaging = UserDefaultsManager(),
		keychainManager: KeychainManaging = KeychainManager()
	) {
		self.modernStorageInstance = ModernStorage(
			userDefaultsManager: userDefaultsManager,
			keychainManager: keychainManager
		)
	}
	
	public convenience init() {
		self.init(
			userDefaultsManager: UserDefaultsManager(),
			keychainManager: KeychainManager()
		)
	}
	
	// MARK: - StorageServiceProtocol Implementation
	
	@MainActor
	public func set<T: Codable>(_ value: T, forKey key: String, storageType: StorageType = .automatic) {
		modernStorageInstance.set(value, forKey: key, storageType: storageType)
	}
	
	@MainActor
	public func get<T: Codable>(key: String, defaultValue: T, storageType: StorageType = .automatic) -> T {
		modernStorageInstance.get(key: key, defaultValue: defaultValue, storageType: storageType)
	}
	
	@MainActor
	public func remove(key: String, storageType: StorageType = .automatic) {
		modernStorageInstance.remove(key: key, storageType: storageType)
	}
	
	@MainActor
	public func setBool(_ value: Bool, forKey key: String) {
		modernStorageInstance.setBool(value, forKey: key)
	}
	
	@MainActor
	public func getBool(forKey key: String, defaultValue: Bool = false) -> Bool {
		modernStorageInstance.getBool(forKey: key, defaultValue: defaultValue)
	}
	
	@MainActor
	public func setInt(_ value: Int, forKey key: String) {
		modernStorageInstance.setInt(value, forKey: key)
	}
	
	@MainActor
	public func getInt(forKey key: String, defaultValue: Int = 0) -> Int {
		modernStorageInstance.getInt(forKey: key, defaultValue: defaultValue)
	}
	
	@MainActor
	public func setDouble(_ value: Double, forKey key: String) {
		modernStorageInstance.setDouble(value, forKey: key)
	}
	
	@MainActor
	public func getDouble(forKey key: String, defaultValue: Double = 0.0) -> Double {
		modernStorageInstance.getDouble(forKey: key, defaultValue: defaultValue)
	}
	
	@MainActor
	public func setString(_ value: String, forKey key: String) {
		modernStorageInstance.setString(value, forKey: key)
	}
	
	@MainActor
	public func getString(forKey key: String, defaultValue: String = "") -> String {
		modernStorageInstance.getString(forKey: key, defaultValue: defaultValue)
	}
}





