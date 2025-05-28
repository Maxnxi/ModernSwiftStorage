//
//  UserDefaultsManager.swift
//  modernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/27/25.
//

import Foundation

public protocol UserDefaultsManaging {
	func set<T: Codable>(_ value: T, forKey key: String)
	func get<T: Codable>(_ type: T.Type, forKey key: String) -> T?
	func remove(forKey key: String)
	func setBool(_ value: Bool, forKey key: String)
	func getBool(forKey key: String) -> Bool?
	func setInt(_ value: Int, forKey key: String)
	func getInt(forKey key: String) -> Int?
	func setDouble(_ value: Double, forKey key: String)
	func getDouble(forKey key: String) -> Double?
	func setString(_ value: String, forKey key: String)
	func getString(forKey key: String) -> String?
}

public struct UserDefaultsManager: UserDefaultsManaging {
	private let userDefaults: UserDefaults
	
	public init(userDefaults: UserDefaults = .standard) {
		self.userDefaults = userDefaults
	}
	
	public func set<T: Codable>(_ value: T, forKey key: String) {
		if let data = try? JSONEncoder().encode(value) {
			userDefaults.set(data, forKey: key)
		}
	}
	
	public func get<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
		guard let data = userDefaults.data(forKey: key),
			  let value = try? JSONDecoder().decode(type, from: data) else {
			return nil
		}
		return value
	}
	
	public func remove(forKey key: String) {
		userDefaults.removeObject(forKey: key)
	}
	
	// Convenience methods for primitive types
	public func setBool(_ value: Bool, forKey key: String) {
		userDefaults.set(value, forKey: key)
	}
	
	public func getBool(forKey key: String) -> Bool? {
		guard userDefaults.object(forKey: key) != nil else { return nil }
		return userDefaults.bool(forKey: key)
	}
	
	public func setInt(_ value: Int, forKey key: String) {
		userDefaults.set(value, forKey: key)
	}
	
	public func getInt(forKey key: String) -> Int? {
		guard userDefaults.object(forKey: key) != nil else { return nil }
		return userDefaults.integer(forKey: key)
	}
	
	public func setDouble(_ value: Double, forKey key: String) {
		userDefaults.set(value, forKey: key)
	}
	
	public func getDouble(forKey key: String) -> Double? {
		guard userDefaults.object(forKey: key) != nil else { return nil }
		return userDefaults.double(forKey: key)
	}
	
	public func setString(_ value: String, forKey key: String) {
		userDefaults.set(value, forKey: key)
	}
	
	public func getString(forKey key: String) -> String? {
		return userDefaults.string(forKey: key)
	}
}
