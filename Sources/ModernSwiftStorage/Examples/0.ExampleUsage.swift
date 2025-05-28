//
//  ExampleUsage.swift
//  modernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/27/25.
//

import SwiftUI
import ModernSwiftStorage

// MARK: - Complete Example App

@available(iOS 14.0, macOS 12.0, watchOS 7.0, tvOS 14.0, *)
struct ExampleApp: App {
	var body: some Scene {
		WindowGroup {
			ContentView()
				.withSimpleStorageService() // Enable storage throughout the app
		}
	}
}

// MARK: - Main Content View

@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
struct ContentView: View {
	var body: some View {
		NavigationView {
			List {
				NavigationLink("User Settings", destination: UserSettingsView())
				NavigationLink("Type-Safe Examples", destination: TypeSafeExampleView())
				NavigationLink("Storage Statistics", destination: StatisticsView())
				NavigationLink("Advanced Examples", destination: AdvancedExampleView())
			}
			.navigationTitle("ModernStorage Demo")
		}
	}
}

// MARK: - User Settings Example

@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
struct UserSettingsView: View {
	// Basic property wrappers with automatic storage selection
	@Storage("user.name") private var userName = "Guest"
	@Storage("notifications.enabled") private var notificationsEnabled = true
	@Storage("theme.isDark") private var isDarkTheme = false
	
	// Explicit keychain storage for sensitive data
	@SecureStorage("auth.token") private var authToken = ""
	@SecureStorage("user.password") private var userPassword = ""
	
	// Explicit UserDefaults storage
	@UserDefaultsStorage("app.version") private var appVersion = "1.0.0"
	
	// Access to storage service for direct operations
	@Environment(\.simpleStorageService) private var storageService
	
	var body: some View {
		NavigationView {
			Form {
				Section("Basic Preferences") {
					TextField("Name", text: $userName)
					Toggle("Enable Notifications", isOn: $notificationsEnabled)
					Toggle("Dark Theme", isOn: $isDarkTheme)
				}
				
				Section("Security") {
					SecureField("Auth Token", text: $authToken)
					SecureField("Password", text: $userPassword)
				}
				
				Section("App Info") {
					TextField("App Version", text: $appVersion)
						.disabled(true)
				}
				
				Section("Storage Operations") {
					Button("Clear All Non-Secure Data") {
						storageService.remove(key: "user.name")
						storageService.remove(key: "notifications.enabled")
						storageService.remove(key: "theme.isDark")
						// Note: Secure data remains intact
					}
					.foregroundColor(.orange)
					
					Button("Clear All Secure Data") {
						storageService.remove(key: "auth.token", storageType: .keychain())
						storageService.remove(key: "user.password", storageType: .keychain())
					}
					.foregroundColor(.red)
				}
			}
			.navigationTitle("Settings")
		}
	}
}

// MARK: - Type-Safe Storage Keys Example

// Define your own storage keys for type safety
extension ModernStorage.Keys {
	struct NewUserProfile: StorageKey {
		typealias Value = UserProfileModel
		let key = "user.profile.v2"
		let defaultValue = UserProfileModel()
		let storageType = StorageType.userDefaults
	}
	
	struct APICredentials: StorageKey {
		typealias Value = APICredentialsModel
		let key = "api.credentials"
		let defaultValue = APICredentialsModel()
		let isSensitive = true // Automatically uses keychain
	}
	
	struct AppPreferences: StorageKey {
		typealias Value = AppPreferencesModel
		let key = "app.preferences.v3"
		let defaultValue = AppPreferencesModel()
		let storageType = StorageType.userDefaults
	}
}

@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
struct TypeSafeExampleView: View {
	// Using custom storage keys for type safety
	@Storage(ModernStorage.Keys.NewUserProfile()) private var userProfile
	@Storage(ModernStorage.Keys.APICredentials()) private var apiCredentials
	@Storage(ModernStorage.Keys.AppPreferences()) private var appPreferences
	
	var body: some View {
		NavigationView {
			Form {
				Section("User Profile") {
					TextField("Full Name", text: $userProfile.fullName)
					TextField("Email", text: $userProfile.email)
					Stepper("Age: \(userProfile.age)", value: $userProfile.age, in: 13...120)
				}
				
				Section("API Credentials (Secure)") {
					SecureField("API Key", text: $apiCredentials.apiKey)
					SecureField("Secret", text: $apiCredentials.secret)
					TextField("Base URL", text: $apiCredentials.baseURL)
				}
				
				Section("App Preferences") {
					Picker("Language", selection: $appPreferences.language) {
						Text("English").tag("en")
						Text("Spanish").tag("es")
						Text("French").tag("fr")
					}
					
					Picker("Theme", selection: $appPreferences.theme) {
						Text("System").tag("system")
						Text("Light").tag("light")
						Text("Dark").tag("dark")
					}
					
					Toggle("Analytics", isOn: $appPreferences.analyticsEnabled)
				}
				
				Section("Data Info") {
					Text("Profile stored in: UserDefaults")
						.font(.caption)
						.foregroundColor(.secondary)
					
					Text("Credentials stored in: Keychain")
						.font(.caption)
						.foregroundColor(.secondary)
					
					Text("Preferences stored in: UserDefaults")
						.font(.caption)
						.foregroundColor(.secondary)
				}
			}
			.navigationTitle("Type-Safe Storage")
		}
	}
}

// MARK: - Statistics View

@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
struct StatisticsView: View {
	@Environment(\.simpleStorageService) private var storageService
	
	var body: some View {
		NavigationView {
			VStack(spacing: 20) {
				Text("App Usage Statistics")
					.font(.largeTitle)
					.fontWeight(.bold)
				
				VStack(alignment: .leading, spacing: 12) {
					StatRow(
						title: "Days Using App",
						value: "\(storageService.statistics.statistics.daysUsingApp)"
					)
					
					StatRow(
						title: "Total App Opens",
						value: "\(storageService.statistics.statistics.timesUsingApp)"
					)
					
					StatRow(
						title: "Today's Sessions",
						value: "\(storageService.statistics.statistics.timesDailyUsingApp)"
					)
					
					StatRow(
						title: "App Installs",
						value: "\(storageService.statistics.statistics.timesAppInstalled)"
					)
					
					StatRow(
						title: "Last Opened",
						value: formattedDate(storageService.statistics.statistics.lastDayOpened)
					)
				}
				.padding()
				.background(Color(.brown))
				.cornerRadius(12)
				
				VStack(spacing: 12) {
					Button("Update Statistics") {
						storageService.statistics.updateStatistics()
					}
					.buttonStyle(.borderedProminent)
										
					Button("Reset All Statistics") {
						storageService.statistics.resetStatistics()
					}
					.buttonStyle(.bordered)
					.foregroundColor(.red)
				}
				
				Spacer()
			}
			.padding()
			.navigationTitle("Statistics")
		}
	}
	
	private func formattedDate(_ date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .short
		return formatter.string(from: date)
	}
}

struct StatRow: View {
	let title: String
	let value: String
	
	var body: some View {
		HStack {
			Text(title)
				.fontWeight(.medium)
			Spacer()
			Text(value)
				.foregroundColor(.secondary)
		}
	}
}

// MARK: - Advanced Usage Examples

@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
struct AdvancedExampleView: View {
	@Environment(\.simpleStorageService) private var storageService
	@State private var migrationStatus = "Ready"
	@State private var validationResults: [String] = []
	
	var body: some View {
		NavigationView {
			Form {
				Section("Storage Migration") {
					Text("Status: \(migrationStatus)")
					
					Button("Migrate Sample Data to Keychain") {
						performMigration()
					}
					.disabled(migrationStatus == "In Progress")
				}
				
				Section("Storage Validation") {
					ForEach(validationResults, id: \.self) { result in
						Text(result)
							.font(.caption)
					}
					
					Button("Validate Storage Keys") {
						validateStorageKeys()
					}
				}
				
				Section("Bulk Operations") {
					Button("Store Sample Data") {
						storeBulkSampleData()
					}
					
					Button("Clear Sample Data") {
						clearBulkSampleData()
					}
				}
				
				Section("Storage Types Demo") {
					Button("Demo Automatic Storage") {
						demoAutomaticStorage()
					}
					
					Button("Demo Explicit Storage") {
						demoExplicitStorage()
					}
				}
			}
			.navigationTitle("Advanced Examples")
		}
	}
	
	private func performMigration() {
		migrationStatus = "In Progress"
		
		// Simulate migration
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			let migrationManager = StorageMigrationManager(storage: storageService.storage)
			
			// Store some test data in UserDefaults first
			storageService.set("sensitive-data", forKey: "migration.test", storageType: .userDefaults)
			
			// Migrate to keychain
			Task { @MainActor in
				let success = migrationManager.migrateFromUserDefaultsToKeychain(
					key: "migration.test",
					accessibility: .whenUnlocked
				)
				migrationStatus = success ? "Migration Successful" : "Migration Failed"
			}
		}
	}
	
	private func validateStorageKeys() {
		validationResults.removeAll()
		
		let testKeys = [
			"valid.key",
			"invalid key with spaces",
			"auth.token",
			"",
			String(repeating: "a", count: 300)
		]
		
		for key in testKeys {
			let isValid = StorageValidator.validateKey(key)
			validationResults.append("\(key.isEmpty ? "(empty)" : key): \(isValid ? "✅" : "❌")")
		}
	}
	
	private func storeBulkSampleData() {
		for i in 1...10 {
			storageService.set("Sample Value \(i)", forKey: "bulk.sample.\(i)")
		}
	}
	
	private func clearBulkSampleData() {
		for i in 1...10 {
			storageService.remove(key: "bulk.sample.\(i)")
		}
	}
	
	private func demoAutomaticStorage() {
		// These will automatically go to appropriate storage
		storageService.set("user preference", forKey: "user.theme", storageType: .automatic)
		storageService.set("secret-token-123", forKey: "auth.secret.token", storageType: .automatic)
		storageService.set("my-password", forKey: "user.password", storageType: .automatic)
	}
	
	private func demoExplicitStorage() {
		// Explicitly specify storage types
		storageService.set("UserDefaults data", forKey: "explicit.userdefaults", storageType: .userDefaults)
		storageService.set("Keychain data", forKey: "explicit.keychain", storageType: .keychain())
		storageService.set("Secure keychain data", forKey: "explicit.secure",
						  storageType: .keychain(accessibility: .whenPasscodeSetThisDeviceOnly))
	}
}

// MARK: - Data Models

struct UserProfileModel: Codable {
	var fullName: String = ""
	var email: String = ""
	var age: Int = 18
	var joinDate: Date = Date()
	
	init() {}
}

struct APICredentialsModel: Codable {
	var apiKey: String = ""
	var secret: String = ""
	var baseURL: String = "https://api.example.com"
	var tokenExpiry: Date = Date().addingTimeInterval(3600)
	
	init() {}
}

struct AppPreferencesModel: Codable {
	var language: String = "en"
	var theme: String = "system"
	var analyticsEnabled: Bool = true
	var notificationsEnabled: Bool = true
	var autoBackup: Bool = false
	
	init() {}
}

// MARK: - Testing Example

@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
struct TestingExampleView: View {
	var body: some View {
		UserSettingsView()
			.withSimpleStorageService()
	}
}

// MARK: - Custom Storage Service Example

@available(iOS 15.0, macOS 12.0, watchOS 8.0, tvOS 15.0, *)
struct CustomStorageExampleApp: App {
	// Create a custom storage service with specific configuration
	private let customStorageService: SimpleStorageService = {
		let customUserDefaults = UserDefaults(suiteName: "com.myapp.custom")!
		let customKeychain = KeychainManager(serviceName: "com.myapp.secure")
		
		return SimpleStorageService(
			userDefaultsManager: UserDefaultsManager(userDefaults: customUserDefaults),
			keychainManager: customKeychain
		)
	}()
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.withSimpleStorageService(customStorageService)
		}
	}
}
