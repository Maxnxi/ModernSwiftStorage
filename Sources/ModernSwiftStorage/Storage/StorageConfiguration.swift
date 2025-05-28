//
//  StorageConfiguration.swift
//  ModernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/28/25.
//

import Foundation

public struct StorageConfiguration: Sendable {
	public let serviceName: String
	public let userDefaultsSuiteName: String?
	public let defaultKeychainAccessibility: KeychainItemAccessibility
	public let enableStatistics: Bool
	public let enableMigration: Bool
	
	public init(
		serviceName: String? = nil,
		userDefaultsSuiteName: String? = nil,
		defaultKeychainAccessibility: KeychainItemAccessibility = .whenUnlocked,
		enableStatistics: Bool = true,
		enableMigration: Bool = false
	) {
		self.serviceName = serviceName ?? Bundle.main.bundleIdentifier ?? "ModernSwiftStorage"
		self.userDefaultsSuiteName = userDefaultsSuiteName
		self.defaultKeychainAccessibility = defaultKeychainAccessibility
		self.enableStatistics = enableStatistics
		self.enableMigration = enableMigration
	}
	
	// Create UserDefaults instance when needed
	public var userDefaults: UserDefaults {
		if let suiteName = userDefaultsSuiteName {
			return UserDefaults(suiteName: suiteName) ?? .standard
		}
		return .standard
	}
	
	public static let `default` = StorageConfiguration()
}
