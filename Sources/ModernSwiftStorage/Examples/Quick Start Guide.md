# ModernSwiftStorage - Quick Start Guide

## 5-Minute Setup

### 1. Add to Your Project
```swift
// Package.swift
dependencies: [
	.package(url: "https://github.com/yourusername/ModernSwiftStorage.git", from: "1.0.0")
]
```

### 2. Setup Your App
```swift
import SwiftUI
import ModernSwiftStorage

@main
struct MyApp: App {
	var body: some Scene {
		WindowGroup {
			ContentView()
				.withSimpleStorageService() // One line setup!
		}
	}
}
```

### 3. Use Property Wrappers
```swift
struct SettingsView: View {
	// Automatic storage selection
	@Storage("user.name") private var userName = "Guest"
	@Storage("auth.token") private var authToken = "" // Auto-routes to Keychain
	
	// Explicit storage types
	@SecureStorage("sensitive.data") private var sensitiveData = ""
	@UserDefaultsStorage("app.version") private var version = "1.0.0"
	
	var body: some View {
		Form {
			TextField("Name", text: $userName)
			SecureField("Token", text: $authToken)
		}
	}
}
```

## Common Patterns

### User Settings
```swift
struct UserSettings: View {
	@Storage("settings.notifications") private var notifications = true
	@Storage("settings.theme") private var theme = "system"
	@Storage("settings.language") private var language = "en"
	
	var body: some View {
		Form {
			Toggle("Notifications", isOn: $notifications)
			Picker("Theme", selection: $theme) {
				Text("System").tag("system")
				Text("Light").tag("light")
				Text("Dark").tag("dark")
			}
		}
	}
}
```

### Authentication
```swift
struct AuthManager {
	@Storage("auth.isLoggedIn") private var isLoggedIn = false
	@Storage("auth.token") private var token = "" // Keychain
	@Storage("auth.refreshToken") private var refreshToken = "" // Keychain
	
	func login(token: String, refreshToken: String) {
		self.token = token
		self.refreshToken = refreshToken
		self.isLoggedIn = true
	}
	
	func logout() {
		token = ""
		refreshToken = ""
		isLoggedIn = false
	}
}
```

### Type-Safe Storage Keys
```swift
extension ModernStorage.Keys {
	struct UserProfile: StorageKey {
		typealias Value = UserProfileModel
		let key = "user.profile"
		let defaultValue = UserProfileModel()
		let storageType = StorageType.userDefaults
	}
	
	struct APICredentials: StorageKey {
		typealias Value = APICredentialsModel
		let key = "api.credentials"
		let defaultValue = APICredentialsModel()
		let isSensitive = true // Auto-routes to Keychain
	}
}

// Usage
@Storage(ModernStorage.Keys.UserProfile()) private var profile
@Storage(ModernStorage.Keys.APICredentials()) private var credentials
```

### Direct Storage Access
```swift
struct DataManager: View {
	@Environment(\.simpleStorageService) private var storage
	
	func saveUserData() {
		let userData = UserData(name: "John", email: "john@example.com")
		storage.set(userData, forKey: "user.data")
	}
	
	func loadUserData() -> UserData {
		return storage.get(key: "user.data", defaultValue: UserData())
	}
	
	func clearSensitiveData() {
		storage.remove(key: "auth.token", storageType: .keychain())
	}
}
```

## Key Features

### Automatic Security Routing
Keys containing these words automatically go to Keychain:
- `password`, `token`, `secret`, `key`, `credential`, `auth`

```swift
@Storage("user.name") private var name = "" // → UserDefaults
@Storage("auth.token") private var token = "" // → Keychain (auto)
@Storage("api.secret") private var secret = "" // → Keychain (auto)
```

### Storage Types
```swift
// Let the library decide (recommended)
@Storage("data", storageType: .automatic) private var data = ""

// Force UserDefaults
@Storage("data", storageType: .userDefaults) private var data = ""

// Force Keychain with accessibility
@Storage("data", storageType: .keychain(accessibility: .whenUnlocked)) private var data = ""
```

### Built-in Analytics
```swift
struct StatsView: View {
	@Environment(\.simpleStorageService) private var storage
	
	var body: some View {
		let stats = storage.statistics.statistics
		VStack {
			Text("Days using app: \(stats.daysUsingApp)")
			Text("Total sessions: \(stats.timesUsingApp)")
			Text("Today's sessions: \(stats.timesDailyUsingApp)")
		}
	}
}
```

### Testing Support
```swift
#if DEBUG
struct SettingsView_Previews: PreviewProvider {
	static var previews: some View {
		SettingsView()
			.withSimpleStorageService(
				userDefaultsManager: MockUserDefaultsManager(),
				keychainManager: MockKeychainManager()
			)
	}
}
#endif
```

## Best Practices

### ✅ Do
- Use `@Storage` with `.automatic` for most cases
- Define type-safe storage keys for complex data
- Use mock storage for testing and previews
- Let the library handle security routing
- Use descriptive key names like `"user.preferences.theme"`

### ❌ Don't
- Store sensitive data in UserDefaults manually
- Use spaces or special characters in keys
- Store large binary data (use file system instead)
- Forget to handle default values properly

## Data Types Supported

All `Codable` types work automatically:

```swift
// Primitives
@Storage("count") private var count = 0
@Storage("isEnabled") private var isEnabled = false
@Storage("rating") private var rating = 4.5
@Storage("message") private var message = ""

// Complex objects
@Storage("user") private var user = User()
@Storage("settings") private var settings = AppSettings()

// Collections
@Storage("tags") private var tags = [String]()
@Storage("preferences") private var preferences = [String: String]()
```

## Migration

Moving data between storage types:

```swift
struct MigrationView: View {
	@Environment(\.simpleStorageService) private var storage
	
	func migrateToSecureStorage() {
		let migrationManager = StorageMigrationManager(storage: storage.storage)
		
		Task { @MainActor in
			// Move sensitive data from UserDefaults to Keychain
			let success = migrationManager.migrateFromUserDefaultsToKeychain(
				key: "legacy.token",
				accessibility: .whenUnlocked
			)
			print("Migration successful: \(success)")
		}
	}
}
```

## Performance Tips

- **UserDefaults**: Fast for small data, synchronous
- **Keychain**: Slightly slower, encrypted, secure
- **Primitive types**: Optimized direct storage
- **Complex objects**: JSON encoding/decoding
- **Bulk operations**: Use direct storage service for many operations

## Troubleshooting

### Common Issues

**Property wrapper not updating UI:**
```swift
// Make sure your view is using the environment
struct MyView: View {
	@Storage("key") private var value = ""
	// ✅ Environment is automatically available
}
```

**Mock storage not working:**
```swift
// ✅ Correct setup
.withSimpleStorageService(
	userDefaultsManager: MockUserDefaultsManager(),
	keychainManager: MockKeychainManager()
)
```

**Keychain access issues:**
```swift
// ✅ Use appropriate accessibility
@SecureStorage("data", accessibility: .whenUnlocked) private var data = ""
```

**Key validation errors:**
```swift
// ❌ Invalid
@Storage("invalid key with spaces") private var data = ""

// ✅ Valid
@Storage("valid.key.name") private var data = ""
```

## Next Steps

1. Check out the comprehensive examples in `ComprehensiveExamples.swift`
2. Read the full README for advanced features
3. Set up unit tests with mock storage
4. Configure custom storage for your needs
5. Implement proper key validation

Need help? Check the validation examples and performance testing tools included in the library!
