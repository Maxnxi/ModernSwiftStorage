//
//  SimpleStorageServiceKey.swift
//  modernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/27/25.
//


import Foundation
import SwiftUI


// MARK: - Environment Key for Simplified Version

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
private struct SimpleStorageServiceKey: @preconcurrency EnvironmentKey {
	@MainActor
	static var defaultValue: SimpleStorageService {
		return _defaultStorageService
	}
	
	@MainActor
	private static let _defaultStorageService: SimpleStorageService = {
		let userDefaultsManager = UserDefaultsManager()
		let keychainManager = KeychainManager()
		return SimpleStorageService(
			userDefaultsManager: userDefaultsManager,
			keychainManager: keychainManager
		)
	}()
}

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
public extension EnvironmentValues {
	var simpleStorageService: SimpleStorageService {
		get { self[SimpleStorageServiceKey.self] }
		set { self[SimpleStorageServiceKey.self] = newValue }
	}
}
