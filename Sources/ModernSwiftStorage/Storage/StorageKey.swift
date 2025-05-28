//
//  StorageKey.swift
//  modernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/27/25.
//


import Foundation

/// Protocol for defining storage keys with type safety
public protocol StorageKey {
	associatedtype Value: Codable
	var key: String { get }
	var defaultValue: Value { get }
	var storageType: StorageType { get }
	var isSensitive: Bool { get }
}

public extension StorageKey {
	var isSensitive: Bool { false }
	var storageType: StorageType {
		isSensitive ? .keychain() : .userDefaults
	}
}
