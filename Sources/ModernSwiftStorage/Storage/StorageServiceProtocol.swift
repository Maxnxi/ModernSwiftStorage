//
//  StorageServiceProtocol.swift
//  ModernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/28/25.
//


import Foundation
import SwiftUI

/// Protocol defining the storage service interface
@MainActor
public protocol StorageServiceProtocol: ObservableObject {
	func set<T: Codable>(_ value: T, forKey key: String, storageType: StorageType)
	func get<T: Codable>(key: String, defaultValue: T, storageType: StorageType) -> T
	func remove(key: String, storageType: StorageType)
	func setBool(_ value: Bool, forKey key: String)
	func getBool(forKey key: String, defaultValue: Bool) -> Bool
	func setInt(_ value: Int, forKey key: String)
	func getInt(forKey key: String, defaultValue: Int) -> Int
	func setDouble(_ value: Double, forKey key: String)
	func getDouble(forKey key: String, defaultValue: Double) -> Double
	func setString(_ value: String, forKey key: String)
	func getString(forKey key: String, defaultValue: String) -> String
	
	var statistics: StorageStatisticsManager { get }
}
