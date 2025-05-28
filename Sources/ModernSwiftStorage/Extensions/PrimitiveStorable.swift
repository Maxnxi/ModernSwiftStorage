//
//  PrimitiveStorable.swift
//  modernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/27/25.
//

import Foundation

internal protocol PrimitiveStorable {
	func setInUserDefaults(key: String, userDefaultsManager: any UserDefaultsManaging)
	static func getFromUserDefaults(key: String, defaultValue: Any, userDefaultsManager: any UserDefaultsManaging) -> Any
}

extension Bool: PrimitiveStorable {
	func setInUserDefaults(key: String, userDefaultsManager: any UserDefaultsManaging) {
		userDefaultsManager.setBool(self, forKey: key)
	}
	
	static func getFromUserDefaults(key: String, defaultValue: Any, userDefaultsManager: any UserDefaultsManaging) -> Any {
		return userDefaultsManager.getBool(forKey: key) ?? (defaultValue as? Bool ?? false)
	}
}

extension Int: PrimitiveStorable {
	func setInUserDefaults(key: String, userDefaultsManager: any UserDefaultsManaging) {
		userDefaultsManager.setInt(self, forKey: key)
	}
	
	static func getFromUserDefaults(key: String, defaultValue: Any, userDefaultsManager: any UserDefaultsManaging) -> Any {
		return userDefaultsManager.getInt(forKey: key) ?? (defaultValue as? Int ?? 0)
	}
}

extension Double: PrimitiveStorable {
	func setInUserDefaults(key: String, userDefaultsManager: any UserDefaultsManaging) {
		userDefaultsManager.setDouble(self, forKey: key)
	}
	
	static func getFromUserDefaults(key: String, defaultValue: Any, userDefaultsManager: any UserDefaultsManaging) -> Any {
		return userDefaultsManager.getDouble(forKey: key) ?? (defaultValue as? Double ?? 0.0)
	}
}

extension String: PrimitiveStorable {
	func setInUserDefaults(key: String, userDefaultsManager: any UserDefaultsManaging) {
		userDefaultsManager.setString(self, forKey: key)
	}
	
	static func getFromUserDefaults(key: String, defaultValue: Any, userDefaultsManager: any UserDefaultsManaging) -> Any {
		return userDefaultsManager.getString(forKey: key) ?? (defaultValue as? String ?? "")
	}
}
