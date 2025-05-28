//
//  UserDefaultsStorage.swift
//  ModernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/28/25.
//

import Foundation
import SwiftUI

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
@MainActor
@propertyWrapper
public struct UserDefaultsStorage<T: Codable>: DynamicProperty {
	private let key: String
	private let defaultValue: T
	
	@Environment(\.simpleStorageService) private var storageService
	
	public var wrappedValue: T {
		get {
			storageService.get(key: key, defaultValue: defaultValue, storageType: .userDefaults)
		}
		nonmutating set {
			storageService.set(newValue, forKey: key, storageType: .userDefaults)
		}
	}
	
	public var projectedValue: Binding<T> {
		Binding(
			get: { wrappedValue },
			set: { wrappedValue = $0 }
		)
	}
	
	public init(wrappedValue defaultValue: T, _ key: String) {
		self.key = key
		self.defaultValue = defaultValue
	}
}
