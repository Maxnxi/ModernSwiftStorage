//
//  StorageServiceProtocol+Extension.swift
//  modernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/27/25.
//

import Foundation
import SwiftUI

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
extension StorageService: StorageServiceProtocol {}

// MARK: - Additional Storage Key Examples

public extension ModernStorage.Keys {
	struct UserProfile: StorageKey {
		public typealias Value = UserProfileData
		public let key = "user.profile"
		public let defaultValue = UserProfileData()
		public let storageType = StorageType.userDefaults
	}
	
	struct BiometricSettings: StorageKey {
		public typealias Value = BiometricData
		public let key = "biometric.settings"
		public let defaultValue = BiometricData()
		public let isSensitive = true
		public let storageType = StorageType.keychain(accessibility: .whenPasscodeSetThisDeviceOnly)
	}
	
	struct AppVersion: StorageKey {
		public typealias Value = String
		public let key = "app.version"
		public let defaultValue = "1.0.0"
		public let storageType = StorageType.userDefaults
	}
	
	struct FirstLaunch: StorageKey {
		public typealias Value = Bool
		public let key = "app.first.launch"
		public let defaultValue = true
		public let storageType = StorageType.userDefaults
	}
}

// MARK: - Sample Data Models

public struct UserProfileData: Codable {
	public var name: String = ""
	public var email: String = ""
	public var age: Int = 0
	public var preferences: [String: String] = [:]
	
	public init() {}
	
	public init(name: String, email: String, age: Int, preferences: [String: String] = [:]) {
		self.name = name
		self.email = email
		self.age = age
		self.preferences = preferences
	}
}

public struct BiometricData: Codable {
	public var isEnabled: Bool = false
	public var biometricType: String = "none"
	public var lastUsed: Date = Date()
	
	public init() {}
	
	public init(isEnabled: Bool, biometricType: String, lastUsed: Date = Date()) {
		self.isEnabled = isEnabled
		self.biometricType = biometricType
		self.lastUsed = lastUsed
	}
}



@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public extension StorageService {
	convenience init(configuration: StorageConfiguration) {
		self.init(
			userDefaultsManager: UserDefaultsManager(userDefaults: configuration.userDefaults),
			keychainManager: KeychainManager(serviceName: configuration.serviceName)
		)
	}
}

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public extension SimpleStorageService {
	convenience init(configuration: StorageConfiguration) {
		self.init(
			userDefaultsManager: UserDefaultsManager(userDefaults: configuration.userDefaults),
			keychainManager: KeychainManager(serviceName: configuration.serviceName)
		)
	}
}
