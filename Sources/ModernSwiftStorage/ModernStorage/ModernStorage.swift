//
//  ModernStorage.swift
//  modernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/27/25.
//

import Foundation
import SwiftUI

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public final class ModernStorage: ObservableObject {
	@MainActor
	public static let shared = ModernStorage()
	
	@MainActor
	public private(set) lazy var statistics = StorageStatisticsManager(storage: self)
	
	private let userDefaultsManager: UserDefaultsManaging
	private let keychainManager: KeychainManaging
	
	public init(
		userDefaultsManager: UserDefaultsManaging = UserDefaultsManager(),
		keychainManager: KeychainManaging = KeychainManager()
	) {
		self.userDefaultsManager = userDefaultsManager
		self.keychainManager = keychainManager
	}
	
	// MARK: - Generic Storage Methods
	
	@MainActor
	public func set<T: Codable>(
		_ value: T,
		forKey key: String,
		storageType: StorageType = .automatic
	) {
		switch resolveStorageType(storageType, for: T.self) {
		case .userDefaults:
			if let primitiveValue = value as? any PrimitiveStorable {
				primitiveValue.setInUserDefaults(
					key: key,
					userDefaultsManager: userDefaultsManager
				)
			} else {
				userDefaultsManager.set(
					value,
					forKey: key
				)
			}
			
		case .keychain(let accessibility):
			_ = keychainManager.set(
				value,
				forKey: key,
				accessibility: accessibility
			)
			
		case .automatic:
			// This shouldn't happen after resolution, but fallback to UserDefaults
			userDefaultsManager.set(
				value,
				forKey: key
			)
		}
	}
	
	@MainActor
	public func get<T: Codable>(
		key: String,
		defaultValue: T,
		storageType: StorageType = .automatic
	) -> T {
		
		switch resolveStorageType(storageType, for: T.self) {
		case .userDefaults:
			if let primitiveType = T.self as? any PrimitiveStorable.Type {
				return primitiveType.getFromUserDefaults(key: key, defaultValue: defaultValue, userDefaultsManager: userDefaultsManager) as? T ?? defaultValue
			} else {
				return userDefaultsManager.get(T.self, forKey: key) ?? defaultValue
			}
			
		case .keychain(let accessibility):
			return keychainManager.get(T.self, forKey: key, accessibility: accessibility) ?? defaultValue
			
		case .automatic:
			// This shouldn't happen after resolution, but fallback to UserDefaults
			return userDefaultsManager.get(T.self, forKey: key) ?? defaultValue
		}
	}
	
	@MainActor
	public func remove(key: String, storageType: StorageType = .automatic) {
		switch storageType {
		case .userDefaults, .automatic:
			userDefaultsManager.remove(forKey: key)
			
		case .keychain(let accessibility):
			_ = keychainManager.remove(
				forKey: key,
				accessibility: accessibility
			)
		}
	}
	
	// MARK: - Convenience Methods for Common Types
	
	@MainActor
	public func setBool(_ value: Bool, forKey key: String) {
		userDefaultsManager.setBool(value, forKey: key)
	}
	
	@MainActor
	public func getBool(forKey key: String, defaultValue: Bool = false) -> Bool {
		return userDefaultsManager.getBool(forKey: key) ?? defaultValue
	}
	
	@MainActor
	public func setInt(_ value: Int, forKey key: String) {
		userDefaultsManager.setInt(value, forKey: key)
	}
	
	@MainActor
	public func getInt(forKey key: String, defaultValue: Int = 0) -> Int {
		return userDefaultsManager.getInt(forKey: key) ?? defaultValue
	}
	
	@MainActor
	public func setDouble(_ value: Double, forKey key: String) {
		userDefaultsManager.setDouble(value, forKey: key)
	}
	
	@MainActor
	public func getDouble(forKey key: String, defaultValue: Double = 0.0) -> Double {
		return userDefaultsManager.getDouble(forKey: key) ?? defaultValue
	}
	
	@MainActor
	public func setString(_ value: String, forKey key: String) {
		userDefaultsManager.setString(value, forKey: key)
	}
	
	@MainActor
	public func getString(forKey key: String, defaultValue: String = "") -> String {
		return userDefaultsManager.getString(forKey: key) ?? defaultValue
	}
	
	// MARK: - Internal Access for Statistics Manager
	
	internal var internalUserDefaultsManager: UserDefaultsManaging {
		userDefaultsManager
	}
	
	internal var internalKeychainManager: KeychainManaging {
		keychainManager
	}
	
	// MARK: - Private Methods
	
	private func resolveStorageType<T>(_ storageType: StorageType, for type: T.Type) -> StorageType {
		switch storageType {
		case .automatic:
			return isSensitiveType(type) ? .keychain() : .userDefaults
		default:
			return storageType
		}
	}
	
	private func isSensitiveType<T>(_ type: T.Type) -> Bool {
		let typeName = String(describing: type).lowercased()
		let sensitiveKeywords = [
			"password",
			"token",
			"secret",
			"key",
			"credential",
			"auth"
		]
		return sensitiveKeywords.contains { typeName.contains($0) }
	}
}
