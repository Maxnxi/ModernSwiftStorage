////
////  StorageServiceExamples.swift
////  modernSwiftStorage
////
////  Created by Maksim Ponomarev on 5/27/25.
////
//
//import SwiftUI
//
//// MARK: - Example App Structure
//
//@available(iOS 14.0, macOS 12.0, watchOS 7.0, tvOS 14.0, *)
//struct ExampleApp: App {
//	var body: some Scene {
//		WindowGroup {
//			ContentView()
//				.withStorageService() // Default storage service
//		}
//	}
//}
//
//// MARK: - Example with Custom Storage Service
//
//@available(iOS 14.0, macOS 12.0, watchOS 7.0, tvOS 14.0, *)
//struct ExampleAppWithCustomStorage: App {
//	private let customStorageService = StorageService(
//		userDefaultsManager: UserDefaultsManager(),
//		keychainManager: KeychainManager(serviceName: "com.myapp.custom")
//	)
//	
//	var body: some Scene {
//		WindowGroup {
//			ContentView()
//				.withStorageService(customStorageService)
//		}
//	}
//}
//
//// MARK: - Example Views Using Storage
//
//@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
//struct UserSettingsView: View {
//	// Using the new environment-based @Storage
//	@Storage("user.name") private var userName = "Guest"
//	@Storage("notifications.enabled") private var notificationsEnabled = true
//	@Storage("theme.isDark") private var isDarkTheme = false
//	@Storage("auth.token", storageType: .keychain()) private var authToken = ""
//	
//	// Direct access to storage service via environment
//	@EnvironmentObject private var storageService: StorageService
//	
//	var body: some View {
//		NavigationView {
//			Form {
//				Section("User Preferences") {
//					TextField("Name", text: $userName)
//					Toggle("Notifications", isOn: $notificationsEnabled)
//					Toggle("Dark Theme", isOn: $isDarkTheme)
//				}
//				
//				Section("Security") {
//					SecureField("Auth Token", text: $authToken)
//					
//					Button("Clear All Data") {
//						storageService.remove(key: "user.name")
//						storageService.remove(key: "notifications.enabled")
//						storageService.remove(key: "theme.isDark")
//						storageService.remove(key: "auth.token", storageType: .keychain())
//					}
//				}
//				
//				Section("Statistics") {
//					StatisticsView()
//				}
//			}
//			.navigationTitle("Settings")
//		}
//	}
//}
//
//@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
//struct StatisticsView: View {
//	@EnvironmentObject private var storageService: StorageService
//	
//	var body: some View {
//		VStack(alignment: .leading, spacing: 8) {
//			Text("App Usage Statistics")
//				.font(.headline)
//			
//			Text("Days using app: \(storageService.statistics.statistics.daysUsingApp)")
//			Text("Times opened: \(storageService.statistics.statistics.timesUsingApp)")
//			Text("Today's sessions: \(storageService.statistics.statistics.timesDailyUsingApp)")
//			Text("Last opened: \(formattedDate(storageService.statistics.statistics.lastDayOpened))")
//			
//			Button("Update Statistics") {
//				storageService.statistics.updateStatistics()
//			}
//			.buttonStyle(.bordered)
//		}
//	}
//	
//	private func formattedDate(_ date: Date) -> String {
//		let formatter = DateFormatter()
//		formatter.dateStyle = .medium
//		formatter.timeStyle = .short
//		return formatter.string(from: date)
//	}
//}
//
//// MARK: - Example with Type-Safe Storage Keys
//
//@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
//struct TypeSafeStorageExample: View {
//	@Storage(UserPreferencesKey()) private var preferences
//	@Storage(APITokenKey()) private var apiToken
//	
//	var body: some View {
//		VStack {
//			Text("Username: \(preferences.username)")
//			Text("Theme: \(preferences.theme)")
//			Text("API Token: \(apiToken.isEmpty ? "Not set" : "Set")")
//		}
//	}
//}
//
//// MARK: - Custom Storage Keys
//
//struct UserPreferencesKey: StorageKey {
//	typealias Value = UserPreferences
//	let key = "user.preferences"
//	let defaultValue = UserPreferences()
//	let storageType = StorageType.userDefaults
//}
//
//struct APITokenKey: StorageKey {
//	typealias Value = String
//	let key = "api.token"
//	let defaultValue = ""
//	let isSensitive = true // Automatically uses Keychain
//}
//
//struct UserPreferences: Codable {
//	var username: String = "Guest"
//	var theme: String = "light"
//	var language: String = "en"
//}
//
//// MARK: - Testing Example
//
//@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
//struct TestingExampleView: View {
//	var body: some View {
//		UserSettingsView()
//			.withStorageService(
//				userDefaultsManager: MockUserDefaultsManager(),
//				keychainManager: MockKeychainManager()
//			)
//	}
//}
//
//// MARK: - Mock Implementations for Testing
//
//struct MockUserDefaultsManager: UserDefaultsManaging {
//	private var storage: [String: Any] = [:]
//	
//	func set<T: Codable>(_ value: T, forKey key: String) {
//		storage[key] = value
//	}
//	
//	func get<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
//		storage[key] as? T
//	}
//	
//	func remove(forKey key: String) {
//		storage.removeValue(forKey: key)
//	}
//	
//	func setBool(_ value: Bool, forKey key: String) {
//		storage[key] = value
//	}
//	
//	func getBool(forKey key: String) -> Bool? {
//		storage[key] as? Bool
//	}
//	
//	func setInt(_ value: Int, forKey key: String) {
//		storage[key] = value
//	}
//	
//	func getInt(forKey key: String) -> Int? {
//		storage[key] as? Int
//	}
//	
//	func setDouble(_ value: Double, forKey key: String) {
//		storage[key] = value
//	}
//	
//	func getDouble(forKey key: String) -> Double? {
//		storage[key] as? Double
//	}
//	
//	func setString(_ value: String, forKey key: String) {
//		storage[key] = value
//	}
//	
//	func getString(forKey key: String) -> String? {
//		storage[key] as? String
//	}
//}
//
//struct MockKeychainManager: KeychainManaging {
//	private var storage: [String: Any] = [:]
//	
//	func set<T: Codable>(_ value: T, forKey key: String, accessibility: KeychainItemAccessibility) -> Bool {
//		storage[key] = value
//		return true
//	}
//	
//	func get<T: Codable>(_ type: T.Type, forKey key: String, accessibility: KeychainItemAccessibility) -> T? {
//		storage[key] as? T
//	}
//	
//	func remove(forKey key: String, accessibility: KeychainItemAccessibility) -> Bool {
//		storage.removeValue(forKey: key)
//		return true
//	}
//}
