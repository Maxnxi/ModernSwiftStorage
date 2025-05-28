
//
//  KeychainManager.swift
//  modernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/27/25.
//

import Security
import Foundation

public protocol KeychainManaging {
	func set<T: Codable>(_ value: T, forKey key: String, accessibility: KeychainItemAccessibility) -> Bool
	func get<T: Codable>(_ type: T.Type, forKey key: String, accessibility: KeychainItemAccessibility) -> T?
	func remove(forKey key: String, accessibility: KeychainItemAccessibility) -> Bool
}

public struct KeychainManager: KeychainManaging {
	private let serviceName: String
	
	public init(serviceName: String? = nil) {
		self.serviceName = serviceName ?? Bundle.main.bundleIdentifier ?? "ModernSwiftStorage"
	}
	
	public func set<T: Codable>(_ value: T, forKey key: String, accessibility: KeychainItemAccessibility) -> Bool {
		guard let data = try? JSONEncoder().encode(value) else { return false }
		
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: serviceName,
			kSecAttrAccount as String: key,
			kSecValueData as String: data,
			kSecAttrAccessible as String: accessibility.keychainAttrValue
		]
		
		SecItemDelete(query as CFDictionary)
		let status = SecItemAdd(query as CFDictionary, nil)
		return status == errSecSuccess
	}
	
	public func get<T: Codable>(_ type: T.Type, forKey key: String, accessibility: KeychainItemAccessibility) -> T? {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: serviceName,
			kSecAttrAccount as String: key,
			kSecAttrAccessible as String: accessibility.keychainAttrValue,
			kSecReturnData as String: true,
			kSecMatchLimit as String: kSecMatchLimitOne
		]
		
		var result: AnyObject?
		let status = SecItemCopyMatching(query as CFDictionary, &result)
		
		guard status == errSecSuccess,
			  let data = result as? Data,
			  let value = try? JSONDecoder().decode(type, from: data) else {
			return nil
		}
		
		return value
	}
	
	public func remove(forKey key: String, accessibility: KeychainItemAccessibility) -> Bool {
		let query: [String: Any] = [
			kSecClass as String: kSecClassGenericPassword,
			kSecAttrService as String: serviceName,
			kSecAttrAccount as String: key,
			kSecAttrAccessible as String: accessibility.keychainAttrValue
		]
		
		let status = SecItemDelete(query as CFDictionary)
		return status == errSecSuccess
	}
}
