//
//  SimpleStorageServiceModifier.swift
//  ModernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/28/25.
//


import Foundation
import SwiftUI


// MARK: - Simplified View Modifier

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public struct SimpleStorageServiceModifier: ViewModifier {
	private let storageService: SimpleStorageService
	
	public init(
		userDefaultsManager: UserDefaultsManaging = UserDefaultsManager(),
		keychainManager: KeychainManaging = KeychainManager()
	) {
		self.storageService = SimpleStorageService(
			userDefaultsManager: userDefaultsManager,
			keychainManager: keychainManager
		)
	}
	
	public init(storageService: SimpleStorageService) {
		self.storageService = storageService
	}
	
	public func body(content: Content) -> some View {
		content
			.environmentObject(storageService)
			.environment(\.simpleStorageService, storageService)
	}
}

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public extension View {
	/// Provides a simple storage service to the view hierarchy
	func withSimpleStorageService(
		userDefaultsManager: UserDefaultsManaging = UserDefaultsManager(),
		keychainManager: KeychainManaging = KeychainManager()
	) -> some View {
		modifier(SimpleStorageServiceModifier(
			userDefaultsManager: userDefaultsManager,
			keychainManager: keychainManager
		))
	}
	
	/// Provides a specific storage service instance to the view hierarchy
	func withSimpleStorageService(_ storageService: SimpleStorageService) -> some View {
		modifier(SimpleStorageServiceModifier(storageService: storageService))
	}
}
