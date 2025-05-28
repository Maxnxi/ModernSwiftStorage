//
//  StorageError.swift
//  ModernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/28/25.
//


import Foundation

public enum StorageError: Error, LocalizedError, Sendable {
	case invalidKey(String)
	case encodingFailed
	case decodingFailed
	case keychainError(OSStatus)
	case userDefaultsError
	case unsupportedType
	
	public var errorDescription: String? {
		switch self {
		case .invalidKey(let key):
			return "Invalid storage key: \(key)"
		case .encodingFailed:
			return "Failed to encode value for storage"
		case .decodingFailed:
			return "Failed to decode value from storage"
		case .keychainError(let status):
			return "Keychain error with status: \(status)"
		case .userDefaultsError:
			return "UserDefaults operation failed"
		case .unsupportedType:
			return "Unsupported data type for storage"
		}
	}
}
