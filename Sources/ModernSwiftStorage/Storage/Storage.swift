//
//  Storage.swift
//  modernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/27/25.
//

import Foundation
import SwiftUI

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
@MainActor
@propertyWrapper
public struct Storage<T: Codable>: DynamicProperty {
	private let key: String
	private let defaultValue: T
	private let storageType: StorageType
	
	@Environment(\.simpleStorageService) private var storageService
	
	public var wrappedValue: T {
		get {
			storageService.get(key: key, defaultValue: defaultValue, storageType: storageType)
		}
		nonmutating set {
			storageService.set(newValue, forKey: key, storageType: storageType)
		}
	}
	
	public var projectedValue: Binding<T> {
		Binding(
			get: { wrappedValue },
			set: { wrappedValue = $0 }
		)
	}
	
	public init(wrappedValue defaultValue: T, _ key: String, storageType: StorageType = .automatic) {
		self.key = key
		self.defaultValue = defaultValue
		self.storageType = storageType
	}
	
	public init<K: StorageKey>(_ storageKey: K) where K.Value == T {
		self.key = storageKey.key
		self.defaultValue = storageKey.defaultValue
		self.storageType = storageKey.storageType
	}
}

// MARK: - Legacy Support

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
@MainActor
@propertyWrapper
public struct LegacyStorage<T: Codable>: DynamicProperty {
	private let key: String
	private let defaultValue: T
	private let storageType: StorageType
	
	public var wrappedValue: T {
		get {
			ModernStorage.shared.get(key: key, defaultValue: defaultValue, storageType: storageType)
		}
		nonmutating set {
			ModernStorage.shared.set(newValue, forKey: key, storageType: storageType)
		}
	}
	
	public var projectedValue: Binding<T> {
		Binding(
			get: { wrappedValue },
			set: { wrappedValue = $0 }
		)
	}
	
	public init(wrappedValue defaultValue: T, _ key: String, storageType: StorageType = .automatic) {
		self.key = key
		self.defaultValue = defaultValue
		self.storageType = storageType
	}
	
	public init<K: StorageKey>(_ storageKey: K) where K.Value == T {
		self.key = storageKey.key
		self.defaultValue = storageKey.defaultValue
		self.storageType = storageKey.storageType
	}
}
