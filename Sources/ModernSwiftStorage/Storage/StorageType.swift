//
//  StorageType.swift
//  modernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/27/25.
//


import Foundation

/// Defines the storage backend to use
public enum StorageType: Sendable {
	case userDefaults
	case keychain(accessibility: KeychainItemAccessibility = .whenUnlocked)
	case automatic // Uses UserDefaults for non-sensitive data, Keychain for sensitive data
}
