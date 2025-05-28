//
//  StorageValidator.swift
//  ModernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/28/25.
//


import Foundation
import SwiftUI

public struct StorageValidator {
	public static func validateKey(_ key: String) -> Bool {
		return !key.isEmpty && !key.contains(" ") && key.count <= 255
	}
	
	public static func validateStorageType<T>(_ type: T.Type, storageType: StorageType) -> Bool {
		let typeName = String(describing: type).lowercased()
		let sensitiveKeywords = [
			"password",
			"token",
			"secret",
			"key",
			"credential",
			"auth"
		]
		let containsSensitiveKeyword = sensitiveKeywords.contains { typeName.contains($0) }
		
		switch storageType {
		case .keychain:
			return true // Keychain can store anything, small data, not big, not media etc.
		case .userDefaults:
			return !containsSensitiveKeyword // UserDefaults should not store sensitive data
		case .automatic:
			return true // Automatic will handle properly
		}
	}
}

