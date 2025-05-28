//
//  View+Modifier.swift
//  ModernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/28/25.
//


import Foundation
import SwiftUI


// MARK: - View Modifier

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public struct StorageServiceModifier: ViewModifier {
	private let storageService: StorageService
	
	public init(
		storageService: StorageService = StorageService()
	) {
		self.storageService = storageService
	}
	
	public init(
		userDefaultsManager: UserDefaultsManaging = UserDefaultsManager(),
		keychainManager: KeychainManaging = KeychainManager()
	) {
		self.storageService = StorageService(
			userDefaultsManager: userDefaultsManager,
			keychainManager: keychainManager
		)
	}
	
	public func body(content: Content) -> some View {
		content
			.environmentObject(storageService)
			.environment(\.storageService, storageService)
	}
}

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public extension View {
	/// Provides a storage service to the view hierarchy
	/// - Parameter storageService: The storage service to provide. Creates a default one if not specified.
	/// - Returns: A view with the storage service available in the environment
	func withStorageService(_ storageService: StorageService = StorageService()) -> some View {
		modifier(StorageServiceModifier(storageService: storageService))
	}
	
	/// Provides a storage service with custom managers to the view hierarchy
	/// - Parameters:
	///   - userDefaultsManager: Custom UserDefaults manager
	///   - keychainManager: Custom Keychain manager
	/// - Returns: A view with the storage service available in the environment
	func withStorageService(
		userDefaultsManager: UserDefaultsManaging = UserDefaultsManager(),
		keychainManager: KeychainManaging = KeychainManager()
	) -> some View {
		modifier(StorageServiceModifier(
			userDefaultsManager: userDefaultsManager,
			keychainManager: keychainManager
		))
	}
}
