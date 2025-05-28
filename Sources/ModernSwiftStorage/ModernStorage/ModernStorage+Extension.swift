//
//  ModernStorage+Extension.swift
//  modernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/27/25.
//


import Foundation


// Example usage - users can extend this with their own keys
public extension ModernStorage {
	enum Keys {}
}

// Example implementation
public extension ModernStorage.Keys {
	struct UserNotifications: StorageKey {
		public typealias Value = Bool
		public let key = "user.notifications.enabled"
		public let defaultValue = false
		public let storageType = StorageType.userDefaults
	}
	
	struct AuthToken: StorageKey {
		public typealias Value = String
		public let key = "auth.token"
		public let defaultValue = ""
		public let isSensitive = true
		public let storageType = StorageType.keychain()
	}
	
	struct LastLocationCoordinates: StorageKey {
		public typealias Value = [String: Double]
		public let key = "location.last.coordinates"
		public let defaultValue: [String: Double] = [:]
		public let storageType = StorageType.userDefaults
	}
}
