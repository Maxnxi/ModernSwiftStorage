//
//  ModernSwiftStorageTests.swift
//  modernSwiftStorageTests
//
//  Created by Maksim Ponomarev on 5/27/25.
//

import XCTest
@testable import ModernSwiftStorage

final class ModernSwiftStorageTests: XCTestCase {
	
	var mockUserDefaultsManager: MockUserDefaultsManager!
	var mockKeychainManager: MockKeychainManager!
	var storage: ModernStorage!
	
	override func setUp() {
		super.setUp()
		mockUserDefaultsManager = MockUserDefaultsManager()
		mockKeychainManager = MockKeychainManager()
		storage = ModernStorage(
			userDefaultsManager: mockUserDefaultsManager,
			keychainManager: mockKeychainManager
		)
	}
	
	override func tearDown() {
		storage = nil
		mockUserDefaultsManager = nil
		mockKeychainManager = nil
		super.tearDown()
	}
	
	// MARK: - Basic Storage Tests
	
	@MainActor
	func testSetAndGetString() {
		let key = "test.string"
		let value = "Hello, World!"
		
		storage.set(value, forKey: key)
		let retrieved = storage.get(key: key, defaultValue: "")
		
		XCTAssertEqual(retrieved, value)
	}
	
	@MainActor
	func testSetAndGetInt() {
		let key = "test.int"
		let value = 42
		
		storage.set(value, forKey: key)
		let retrieved = storage.get(key: key, defaultValue: 0)
		
		XCTAssertEqual(retrieved, value)
	}
	
	@MainActor
	func testSetAndGetBool() {
		let key = "test.bool"
		let value = true
		
		storage.set(value, forKey: key)
		let retrieved = storage.get(key: key, defaultValue: false)
		
		XCTAssertEqual(retrieved, value)
	}
	
	@MainActor
	func testSetAndGetDouble() {
		let key = "test.double"
		let value = 3.14159
		
		storage.set(value, forKey: key)
		let retrieved = storage.get(key: key, defaultValue: 0.0)
		
		XCTAssertEqual(retrieved, value, accuracy: 0.00001)
	}
	
	// MARK: - Codable Types Tests
	
	@MainActor
	func testSetAndGetCodableStruct() {
		let key = "test.profile"
		let value = UserProfileData(name: "John Doe", email: "john@example.com", age: 30)
		
		storage.set(value, forKey: key)
		let retrieved = storage.get(key: key, defaultValue: UserProfileData())
		
		XCTAssertEqual(retrieved.name, value.name)
		XCTAssertEqual(retrieved.email, value.email)
		XCTAssertEqual(retrieved.age, value.age)
	}
	
	// MARK: - Storage Type Tests
	
	@MainActor
	func testExplicitUserDefaultsStorage() {
		let key = "test.userdefaults"
		let value = "UserDefaults Value"
		
		storage.set(value, forKey: key, storageType: .userDefaults)
		let retrieved = storage.get(key: key, defaultValue: "", storageType: .userDefaults)
		
		XCTAssertEqual(retrieved, value)
		XCTAssertTrue(mockUserDefaultsManager.storage.keys.contains(key))
	}
	
	@MainActor
	func testExplicitKeychainStorage() {
		let key = "test.keychain"
		let value = "Keychain Value"
		
		storage.set(value, forKey: key, storageType: .keychain())
		let retrieved = storage.get(key: key, defaultValue: "", storageType: .keychain())
		
		XCTAssertEqual(retrieved, value)
		XCTAssertTrue(mockKeychainManager.storage.keys.contains(key))
	}
	
	@MainActor
	func testAutomaticStorageForSensitiveData() {
		let key = "auth.token" // Contains "token" - should go to keychain
		let value = "secret-token-123"
		
		storage.set(value, forKey: key, storageType: .automatic)
		let retrieved = storage.get(key: key, defaultValue: "", storageType: .automatic)
		
		XCTAssertEqual(retrieved, value)
		// Since it's sensitive, should be in keychain
		XCTAssertTrue(mockKeychainManager.storage.keys.contains(key))
		XCTAssertFalse(mockUserDefaultsManager.storage.keys.contains(key))
	}
	
	@MainActor
	func testAutomaticStorageForNonSensitiveData() {
		let key = "user.name" // Not sensitive - should go to UserDefaults
		let value = "John Doe"
		
		storage.set(value, forKey: key, storageType: .automatic)
		let retrieved = storage.get(key: key, defaultValue: "", storageType: .automatic)
		
		XCTAssertEqual(retrieved, value)
		// Since it's not sensitive, should be in UserDefaults
		XCTAssertTrue(mockUserDefaultsManager.storage.keys.contains(key))
		XCTAssertFalse(mockKeychainManager.storage.keys.contains(key))
	}
	
	// MARK: - Removal Tests
	@MainActor
	func testRemoveFromUserDefaults() {
		let key = "test.remove.userdefaults"
		let value = "To be removed"
		
		storage.set(value, forKey: key, storageType: .userDefaults)
		XCTAssertEqual(storage.get(key: key, defaultValue: "", storageType: .userDefaults), value)
		
		storage.remove(key: key, storageType: .userDefaults)
		XCTAssertEqual(storage.get(key: key, defaultValue: "default", storageType: .userDefaults), "default")
	}
	
	@MainActor
	func testRemoveFromKeychain() {
		let key = "test.remove.keychain"
		let value = "To be removed"
		
		storage.set(value, forKey: key, storageType: .keychain())
		XCTAssertEqual(storage.get(key: key, defaultValue: "", storageType: .keychain()), value)
		
		storage.remove(key: key, storageType: .keychain())
		XCTAssertEqual(storage.get(key: key, defaultValue: "default", storageType: .keychain()), "default")
	}
	
	// MARK: - Default Value Tests
	
	@MainActor
	func testDefaultValueReturnedWhenKeyNotFound() {
		let key = "nonexistent.key"
		let defaultValue = "default value"
		
		let retrieved = storage.get(key: key, defaultValue: defaultValue)
		
		XCTAssertEqual(retrieved, defaultValue)
	}
	
	// MARK: - Convenience Methods Tests
	
	@MainActor
	func testConvenienceBoolMethods() {
		let key = "test.convenience.bool"
		
		storage.setBool(true, forKey: key)
		XCTAssertTrue(storage.getBool(forKey: key))
		
		storage.setBool(false, forKey: key)
		XCTAssertFalse(storage.getBool(forKey: key))
	}
	
	@MainActor
	func testConvenienceIntMethods() {
		let key = "test.convenience.int"
		let value = 123
		
		storage.setInt(value, forKey: key)
		XCTAssertEqual(storage.getInt(forKey: key), value)
	}
	
	@MainActor
	func testConvenienceDoubleMethods() {
		let key = "test.convenience.double"
		let value = 123.456
		
		storage.setDouble(value, forKey: key)
		XCTAssertEqual(storage.getDouble(forKey: key), value, accuracy: 0.001)
	}
	
	@MainActor
	func testConvenienceStringMethods() {
		let key = "test.convenience.string"
		let value = "Test String"
		
		storage.setString(value, forKey: key)
		XCTAssertEqual(storage.getString(forKey: key), value)
	}
}

// MARK: - Storage Key Tests

final class StorageKeyTests: XCTestCase {
	
	func testUserNotificationsKey() {
		let key = ModernStorage.Keys.UserNotifications()
		
		XCTAssertEqual(key.key, "user.notifications.enabled")
		XCTAssertEqual(key.defaultValue, false)
		XCTAssertFalse(key.isSensitive)
		
		switch key.storageType {
		case .userDefaults:
			break // Expected
		default:
			XCTFail("Expected .userDefaults storage type")
		}
	}
	
	func testAuthTokenKey() {
		let key = ModernStorage.Keys.AuthToken()
		
		XCTAssertEqual(key.key, "auth.token")
		XCTAssertEqual(key.defaultValue, "")
		XCTAssertTrue(key.isSensitive)
		
		switch key.storageType {
		case .keychain:
			break // Expected
		default:
			XCTFail("Expected .keychain storage type")
		}
	}
}

// MARK: - Keychain Accessibility Tests

final class KeychainAccessibilityTests: XCTestCase {
	
	func testKeychainAccessibilityMappings() {
		XCTAssertEqual(KeychainItemAccessibility.afterFirstUnlock.keychainAttrValue,
					  kSecAttrAccessibleAfterFirstUnlock)
		XCTAssertEqual(KeychainItemAccessibility.afterFirstUnlockThisDeviceOnly.keychainAttrValue,
					  kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
		XCTAssertEqual(KeychainItemAccessibility.always.keychainAttrValue,
					  kSecAttrAccessibleAlways)
		XCTAssertEqual(KeychainItemAccessibility.whenPasscodeSetThisDeviceOnly.keychainAttrValue,
					  kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
		XCTAssertEqual(KeychainItemAccessibility.alwaysThisDeviceOnly.keychainAttrValue,
					  kSecAttrAccessibleAlwaysThisDeviceOnly)
		XCTAssertEqual(KeychainItemAccessibility.whenUnlocked.keychainAttrValue,
					  kSecAttrAccessibleWhenUnlocked)
		XCTAssertEqual(KeychainItemAccessibility.whenUnlockedThisDeviceOnly.keychainAttrValue,
					  kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
	}
}

// MARK: - Storage Statistics Tests

final class StorageStatisticsTests: XCTestCase {
	
	var mockUserDefaultsManager: MockUserDefaultsManager!
	var mockKeychainManager: MockKeychainManager!
	var storage: ModernStorage!
	
	override func setUp() {
		super.setUp()
		mockUserDefaultsManager = MockUserDefaultsManager()
		mockKeychainManager = MockKeychainManager()
		storage = ModernStorage(
			userDefaultsManager: mockUserDefaultsManager,
			keychainManager: mockKeychainManager
		)
	}
	
	override func tearDown() {
		storage = nil
		mockUserDefaultsManager = nil
		mockKeychainManager = nil
		super.tearDown()
	}
	
	@MainActor
	func testStatisticsInitialization() {
		let stats = storage.statistics.statistics
		
		XCTAssertGreaterThanOrEqual(stats.daysUsingApp, 0)
		XCTAssertGreaterThanOrEqual(stats.timesUsingApp, 0)
		XCTAssertGreaterThanOrEqual(stats.timesDailyUsingApp, 0)
	}
	
	@MainActor
	func testStatisticsUpdate() {
		let initialTimesUsing = storage.statistics.statistics.timesUsingApp
		
		storage.statistics.updateStatistics()
		
		XCTAssertEqual(storage.statistics.statistics.timesUsingApp, initialTimesUsing + 1)
	}
	
	@MainActor
	func testAppReloadedIncrement() {
		let initialReloads = storage.statistics.statistics.timesAppInstalled
		
		storage.statistics.incrementAppReloaded()
		
		XCTAssertEqual(storage.statistics.statistics.timesAppInstalled, initialReloads + 1)
	}
	
	@MainActor
	func testStatisticsReset() {
		storage.statistics.updateStatistics()
		storage.statistics.incrementAppReloaded()
		
		storage.statistics.resetStatistics()
		
		let stats = storage.statistics.statistics
		XCTAssertEqual(stats.daysUsingApp, 0)
		XCTAssertEqual(stats.timesUsingApp, 0)
		XCTAssertEqual(stats.timesDailyUsingApp, 0)
		XCTAssertEqual(stats.timesAppInstalled, 0)
	}
}

// MARK: - Storage Validation Tests

final class StorageValidationTests: XCTestCase {
	
	func testValidKeys() {
		XCTAssertTrue(StorageValidator.validateKey("valid.key"))
		XCTAssertTrue(StorageValidator.validateKey("user.preferences"))
		XCTAssertTrue(StorageValidator.validateKey("auth.token"))
		XCTAssertTrue(StorageValidator.validateKey("simple"))
	}
	
	func testInvalidKeys() {
		XCTAssertFalse(StorageValidator.validateKey(""))
		XCTAssertFalse(StorageValidator.validateKey("key with spaces"))
		XCTAssertFalse(StorageValidator.validateKey(String(repeating: "a", count: 300))) // Too long
	}
	
	func testStorageTypeValidation() {
		// Sensitive types should use keychain
		XCTAssertTrue(StorageValidator.validateStorageType(String.self, storageType: .keychain()))
		XCTAssertFalse(StorageValidator.validateStorageType(AuthTokenType.self, storageType: .userDefaults))
		XCTAssertTrue(StorageValidator.validateStorageType(AuthTokenType.self, storageType: .automatic))
		
		// Non-sensitive types can use either
		XCTAssertTrue(StorageValidator.validateStorageType(UserPreferencesType.self, storageType: .userDefaults))
		XCTAssertTrue(StorageValidator.validateStorageType(UserPreferencesType.self, storageType: .keychain()))
		XCTAssertTrue(StorageValidator.validateStorageType(UserPreferencesType.self, storageType: .automatic))
	}
}

// MARK: - Migration Tests

final class StorageMigrationTests: XCTestCase {
	
	var mockUserDefaultsManager: MockUserDefaultsManager!
	var mockKeychainManager: MockKeychainManager!
	var storage: ModernStorage!
	var migrationManager: StorageMigrationManager!
	
	override func setUp() {
		super.setUp()
		mockUserDefaultsManager = MockUserDefaultsManager()
		mockKeychainManager = MockKeychainManager()
		storage = ModernStorage(
			userDefaultsManager: mockUserDefaultsManager,
			keychainManager: mockKeychainManager
		)
		migrationManager = StorageMigrationManager(storage: storage)
	}
	
	override func tearDown() {
		migrationManager = nil
		storage = nil
		mockUserDefaultsManager = nil
		mockKeychainManager = nil
		super.tearDown()
	}
	
	@MainActor
	func testMigrateFromUserDefaultsToKeychain() async {
		let key = "migrate.test"
		let data = "Test Data".data(using: .utf8)!
		
		// Set in UserDefaults first
		mockUserDefaultsManager.set(data, forKey: key)
		XCTAssertTrue(mockUserDefaultsManager.storage.keys.contains(key))
		
		// Migrate to Keychain
		let success = migrationManager.migrateFromUserDefaultsToKeychain(key: key)
		
		XCTAssertTrue(success)
		XCTAssertFalse(mockUserDefaultsManager.storage.keys.contains(key)) // Removed from UserDefaults
		XCTAssertTrue(mockKeychainManager.storage.keys.contains(key)) // Added to Keychain
	}
	
	@MainActor
	func testMigrateFromKeychainToUserDefaults() async {
		let key = "migrate.test.reverse"
		let data = "Test Data".data(using: .utf8)!
		
		// Set in Keychain first
		let _ = mockKeychainManager.set(data, forKey: key, accessibility: .whenUnlocked)
		XCTAssertTrue(mockKeychainManager.storage.keys.contains(key))
		
		// Migrate to UserDefaults
		let success = migrationManager.migrateFromKeychainToUserDefaults(key: key)
		
		XCTAssertTrue(success)
		XCTAssertFalse(mockKeychainManager.storage.keys.contains(key)) // Removed from Keychain
		XCTAssertTrue(mockUserDefaultsManager.storage.keys.contains(key)) // Added to UserDefaults
	}
}

// MARK: - Performance Tests

final class StoragePerformanceTests: XCTestCase {
	
	var storage: ModernStorage!
	
	override func setUp() {
		super.setUp()
		storage = ModernStorage(
			userDefaultsManager: MockUserDefaultsManager(),
			keychainManager: MockKeychainManager()
		)
	}
	
	override func tearDown() {
		storage = nil
		super.tearDown()
	}
	
	@MainActor
	func testPerformanceOfBulkStringStorage() {
		measure {
			for i in 0..<1000 {
				storage.set("Value \(i)", forKey: "key.\(i)")
			}
		}
	}
	
	@MainActor
	func testPerformanceOfBulkStringRetrieval() {
		// Setup data first
		for i in 0..<1000 {
			storage.set("Value \(i)", forKey: "key.\(i)")
		}
		
		measure {
			for i in 0..<1000 {
				_ = storage.get(key: "key.\(i)", defaultValue: "")
			}
		}
	}
	
	@MainActor
	func testPerformanceOfComplexObjectStorage() {
		let complexObject = UserProfileData(
			name: "John Doe",
			email: "john@example.com",
			age: 30,
			preferences: ["theme": "dark", "language": "en", "notifications": "enabled"]
		)
		
		measure {
			for i in 0..<100 {
				storage.set(complexObject, forKey: "profile.\(i)")
			}
		}
	}
}

// MARK: - Integration Tests

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
final class StorageServiceIntegrationTests: XCTestCase {
	
	var storageService: StorageService!
	
	override func setUp() {
		super.setUp()
		storageService = StorageService(
			userDefaultsManager: MockUserDefaultsManager(),
			keychainManager: MockKeychainManager()
		)
	}
	
	override func tearDown() {
		storageService = nil
		super.tearDown()
	}
	
	@MainActor
	func testStorageServiceBasicOperations() {
		let key = "service.test"
		let value = "Service Value"
		
		storageService.set(value, forKey: key)
		let retrieved = storageService.get(key: key, defaultValue: "")
		
		XCTAssertEqual(retrieved, value)
	}
	
	@MainActor
	func testStorageServiceConvenienceMethods() {
		storageService.setBool(true, forKey: "bool.key")
		XCTAssertTrue(storageService.getBool(forKey: "bool.key"))
		
		storageService.setInt(42, forKey: "int.key")
		XCTAssertEqual(storageService.getInt(forKey: "int.key"), 42)
		
		storageService.setDouble(3.14, forKey: "double.key")
		XCTAssertEqual(storageService.getDouble(forKey: "double.key"), 3.14, accuracy: 0.01)
		
		storageService.setString("test", forKey: "string.key")
		XCTAssertEqual(storageService.getString(forKey: "string.key"), "test")
	}
	
	@MainActor
	func testStorageServiceRemoval() {
		let key = "remove.test"
		let value = "To be removed"
		
		storageService.set(value, forKey: key)
		XCTAssertEqual(storageService.get(key: key, defaultValue: ""), value)
		
		storageService.remove(key: key)
		XCTAssertEqual(storageService.get(key: key, defaultValue: "default"), "default")
	}
}

// MARK: - Error Handling Tests

final class StorageErrorTests: XCTestCase {
	
	func testStorageErrorDescriptions() {
		let invalidKeyError = StorageError.invalidKey("invalid key")
		XCTAssertEqual(invalidKeyError.errorDescription, "Invalid storage key: invalid key")
		
		let encodingError = StorageError.encodingFailed
		XCTAssertEqual(encodingError.errorDescription, "Failed to encode value for storage")
		
		let decodingError = StorageError.decodingFailed
		XCTAssertEqual(decodingError.errorDescription, "Failed to decode value from storage")
		
		let keychainError = StorageError.keychainError(-25300)
		XCTAssertEqual(keychainError.errorDescription, "Keychain error with status: -25300")
		
		let userDefaultsError = StorageError.userDefaultsError
		XCTAssertEqual(userDefaultsError.errorDescription, "UserDefaults operation failed")
		
		let unsupportedTypeError = StorageError.unsupportedType
		XCTAssertEqual(unsupportedTypeError.errorDescription, "Unsupported data type for storage")
	}
}

// MARK: - Configuration Tests

final class StorageConfigurationTests: XCTestCase {
	
	func testDefaultConfiguration() {
		let config = StorageConfiguration.default
		
		XCTAssertEqual(config.userDefaults, UserDefaults.standard)
		XCTAssertEqual(config.defaultKeychainAccessibility, .whenUnlocked)
		XCTAssertTrue(config.enableStatistics)
		XCTAssertFalse(config.enableMigration)
	}
	
	func testCustomConfiguration() {
		let customDefaults = UserDefaults(suiteName: "test.suite")!
		let config = StorageConfiguration(
			serviceName: "TestService",
			defaultKeychainAccessibility: .afterFirstUnlock,
			enableStatistics: false,
			enableMigration: true
		)
		
		XCTAssertEqual(config.serviceName, "TestService")
		XCTAssertEqual(config.userDefaults, customDefaults)
		XCTAssertEqual(config.defaultKeychainAccessibility, .afterFirstUnlock)
		XCTAssertFalse(config.enableStatistics)
		XCTAssertTrue(config.enableMigration)
	}
}

// MARK: - Test Helper Types

private struct AuthTokenType: Codable {
	let token: String
}

private struct UserPreferencesType: Codable {
	let theme: String
	let language: String
}

// MARK: - Mock Implementations

struct MockUserDefaultsManager: UserDefaultsManaging {
	
	var storage: [String: Any] = [:]
	
	mutating func set<T: Codable>(_ value: T, forKey key: String) {
		storage[key] = value
	}
	
	func get<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
		storage[key] as? T
	}
	
	mutating func remove(forKey key: String) {
		storage.removeValue(forKey: key)
	}
	
	mutating func setBool(_ value: Bool, forKey key: String) {
		storage[key] = value
	}
	
	func getBool(forKey key: String) -> Bool? {
		storage[key] as? Bool
	}
	
	mutating func setInt(_ value: Int, forKey key: String) {
		storage[key] = value
	}
	
	func getInt(forKey key: String) -> Int? {
		storage[key] as? Int
	}
	
	mutating func setDouble(_ value: Double, forKey key: String) {
		storage[key] = value
	}
	
	func getDouble(forKey key: String) -> Double? {
		storage[key] as? Double
	}
	
	mutating func setString(_ value: String, forKey key: String) {
		storage[key] = value
	}
	
	func getString(forKey key: String) -> String? {
		storage[key] as? String
	}
}

struct MockKeychainManager: KeychainManaging {
	
	var storage: [String: Any] = [:]
	
	mutating func setKey<T: Codable>(_ value: T, forKey key: String, accessibility: KeychainItemAccessibility) -> Bool {
		storage[key] = value
		return true
	}
	
	func get<T: Codable>(_ type: T.Type, forKey key: String, accessibility: KeychainItemAccessibility) -> T? {
		storage[key] as? T
	}
	
	mutating func remove(forKey key: String, accessibility: KeychainItemAccessibility) -> Bool {
		storage.removeValue(forKey: key)
		return true
	}
}
