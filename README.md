# ModernSwiftStorage

A comprehensive, type-safe storage solution for iOS, macOS, watchOS, and tvOS applications that intelligently handles both UserDefaults and Keychain storage with automatic security routing.

## Features

- ✅ **Type-Safe**: Generic methods with compile-time type checking
- ✅ **Automatic Security**: Sensitive data automatically routed to Keychain
- ✅ **SwiftUI Integration**: Native property wrappers and environment support  
- ✅ **Cross-Platform**: Works on all Apple platforms (iOS 13+, macOS 10.15+, watchOS 6+, tvOS 13+)
- ✅ **Protocol-Based**: Easy to mock and test
- ✅ **Built-in Analytics**: Automatic usage statistics tracking with app reinstall detection
- ✅ **Migration Support**: Tools for migrating data between storage types
- ✅ **Performance Optimized**: Efficient primitive type handling and bulk operations

## Quick Start

### 1. Basic Setup

```swift
import SwiftUI
import ModernSwiftStorage

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .withSimpleStorageService() // Enables storage throughout your app
        }
    }
}
```

### 2. Property Wrapper Usage

```swift
struct SettingsView: View {
    // Automatic storage selection - safe data goes to UserDefaults
    @Storage("user.name") private var userName = "Guest"
    @Storage("notifications.enabled") private var notificationsEnabled = true
    
    // Sensitive data automatically routed to Keychain
    @Storage("auth.token") private var authToken = ""
    @Storage("user.password") private var userPassword = ""
    
    // Explicit Keychain storage with accessibility control
    @SecureStorage("biometric.data", accessibility: .whenPasscodeSetThisDeviceOnly) 
    private var biometricData = ""
    
    // Explicit UserDefaults storage
    @UserDefaultsStorage("app.version") private var appVersion = "1.0.0"
    
    var body: some View {
        Form {
            Section("Basic Preferences") {
                TextField("Name", text: $userName)
                Toggle("Notifications", isOn: $notificationsEnabled)
            }
            
            Section("Security") {
                SecureField("Auth Token", text: $authToken)
                SecureField("Password", text: $userPassword)
            }
            
            Section("Biometric") {
                SecureField("Biometric Data", text: $biometricData)
            }
        }
    }
}
```

### 3. Type-Safe Storage Keys (Recommended)

```swift
// Define your storage keys with full type safety
extension ModernStorage.Keys {
    struct UserProfile: StorageKey {
        typealias Value = UserProfileModel
        let key = "user.profile.v2"
        let defaultValue = UserProfileModel()
        let storageType = StorageType.userDefaults
    }
    
    struct APICredentials: StorageKey {
        typealias Value = APICredentialsModel
        let key = "api.credentials"
        let defaultValue = APICredentialsModel()
        let isSensitive = true // Automatically uses Keychain
    }
    
    struct AppPreferences: StorageKey {
        typealias Value = AppPreferencesModel
        let key = "app.preferences"
        let defaultValue = AppPreferencesModel()
        let storageType = StorageType.userDefaults
    }
}

// Usage with full type safety
struct TypeSafeView: View {
    @Storage(ModernStorage.Keys.UserProfile()) private var userProfile
    @Storage(ModernStorage.Keys.APICredentials()) private var apiCredentials
    @Storage(ModernStorage.Keys.AppPreferences()) private var preferences
    
    var body: some View {
        Form {
            TextField("Name", text: $userProfile.fullName)
            SecureField("API Key", text: $apiCredentials.apiKey)
            Picker("Theme", selection: $preferences.theme) {
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
        }
    }
}
```

### 4. Direct Storage Service Access

```swift
struct DataManager: View {
    @Environment(\.simpleStorageService) private var storage
    
    var body: some View {
        VStack {
            Button("Save User Data") {
                let userData = UserData(name: "John", email: "john@example.com")
                storage.set(userData, forKey: "user.data")
            }
            
            Button("Load User Data") {
                let userData = storage.get(key: "user.data", defaultValue: UserData())
                print("Loaded: \(userData.name)")
            }
            
            Button("Clear Sensitive Data") {
                storage.remove(key: "auth.token", storageType: .keychain())
                storage.remove(key: "user.password", storageType: .keychain())
            }
        }
    }
}
```

## Storage Types & Automatic Selection

### Automatic Selection (Recommended)
The library automatically detects sensitive data and routes it appropriately:

```swift
@Storage("user.name") private var userName = "Guest"        // → UserDefaults
@Storage("user.email") private var email = ""              // → UserDefaults  
@Storage("auth.token") private var token = ""              // → Keychain (auto-detected)
@Storage("user.password") private var password = ""        // → Keychain (auto-detected)
@Storage("api.secret") private var secret = ""             // → Keychain (auto-detected)
```

**Auto-detection keywords:** `password`, `token`, `secret`, `key`, `credential`, `auth`

### Explicit Storage Type Control
```swift
@UserDefaultsStorage("app.version") private var version = "1.0"
@SecureStorage("sensitive.data") private var sensitiveData = ""
@Storage("manual.choice", storageType: .userDefaults) private var manualChoice = ""
@Storage("secure.manual", storageType: .keychain()) private var secureManual = ""
```

### Keychain Accessibility Options
```swift
@Storage("token", storageType: .keychain(accessibility: .whenUnlocked)) 
private var token = ""

@Storage("biometric", storageType: .keychain(accessibility: .whenPasscodeSetThisDeviceOnly)) 
private var biometric = ""

@Storage("backup", storageType: .keychain(accessibility: .afterFirstUnlock)) 
private var backup = ""
```

## Data Models

Any `Codable` type is automatically supported:

```swift
struct UserProfileModel: Codable {
    var fullName: String = ""
    var email: String = ""
    var age: Int = 18
    var preferences: [String: String] = [:]
    var joinDate: Date = Date()
}

struct APICredentialsModel: Codable {
    var apiKey: String = ""
    var secret: String = ""
    var baseURL: String = "https://api.example.com"
    var tokenExpiry: Date = Date()
}

// Usage
@Storage("user.profile") private var profile = UserProfileModel()
@Storage("api.credentials") private var credentials = APICredentialsModel()
```

## Testing Support

### Mock Storage for SwiftUI Previews & Tests
```swift
#if DEBUG
struct ContentView_Previews: PreviewProvider {
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

### Unit Testing
```swift
class UserSettingsTests: XCTestCase {
    var storage: ModernStorage!
    
    override func setUp() {
        super.setUp()
        storage = ModernStorage(
            userDefaultsManager: MockUserDefaultsManager(),
            keychainManager: MockKeychainManager()
        )
    }
    
    @MainActor
    func testUserDataPersistence() {
        let userData = UserProfileModel(fullName: "Test User", email: "test@example.com", age: 25)
        
        storage.set(userData, forKey: "user.profile")
        let retrieved = storage.get(key: "user.profile", defaultValue: UserProfileModel())
        
        XCTAssertEqual(retrieved.fullName, "Test User")
        XCTAssertEqual(retrieved.email, "test@example.com")
        XCTAssertEqual(retrieved.age, 25)
    }
    
    @MainActor
    func testAutomaticStorageRouting() {
        // Test that sensitive data goes to keychain
        storage.set("secret-token-123", forKey: "auth.token", storageType: .automatic)
        
        // Verify it's in keychain, not UserDefaults
        // (This would require access to internal managers for verification)
    }
}
```

## Migration Between Storage Types

```swift
@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
struct MigrationExample: View {
    @Environment(\.simpleStorageService) private var storage
    
    func performMigrations() {
        let migrationManager = StorageMigrationManager(storage: storage.storage)
        
        // Migrate sensitive data from UserDefaults to Keychain
        Task { @MainActor in
            let success = migrationManager.migrateFromUserDefaultsToKeychain(
                key: "legacy.token",
                accessibility: .whenUnlocked
            )
            print("Migration successful: \(success)")
        }
    }
}
```

## Statistics & Analytics

Built-in usage tracking with app reinstall detection:

```swift
struct StatisticsView: View {
    @Environment(\.simpleStorageService) private var storage
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("App Usage Statistics")
                .font(.headline)
            
            let stats = storage.statistics.statistics
            Text("Days using app: \(stats.daysUsingApp)")
            Text("Total app opens: \(stats.timesUsingApp)")
            Text("Today's sessions: \(stats.timesDailyUsingApp)")
            Text("Times reinstalled: \(stats.timesAppInstalled)")
            Text("Last opened: \(stats.lastDayOpened, style: .date)")
            
            Button("Update Statistics") {
                storage.statistics.updateStatistics()
            }
            
            Button("Reset Statistics") {
                storage.statistics.resetStatistics()
            }
        }
    }
}
```

## Advanced Configuration

### Custom Storage Configuration
```swift
let config = StorageConfiguration(
    serviceName: "com.myapp.storage",
    userDefaultsSuiteName: "group.myapp", // For App Groups
    defaultKeychainAccessibility: .afterFirstUnlock,
    enableStatistics: true,
    enableMigration: true
)

let customStorage = SimpleStorageService(configuration: config)

// Use in your app
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .withSimpleStorageService(customStorage)
        }
    }
}
```

### Legacy Support
For gradual migration from existing storage solutions:

```swift
// Legacy property wrapper (uses shared instance)
@LegacyStorage("old.key") private var legacyData = ""

// Modern environment-based approach (recommended)
@Storage("new.key") private var modernData = ""
```

## Error Handling & Validation

```swift
struct ValidationExample: View {
    @Environment(\.simpleStorageService) private var storage
    
    func validateAndStore() {
        let key = "user.preferences"
        
        // Validate key format
        guard StorageValidator.validateKey(key) else {
            print("Invalid key: \(key)")
            return
        }
        
        // Validate storage type for sensitive data
        guard StorageValidator.validateStorageType(APIToken.self, storageType: .userDefaults) else {
            print("Security warning: Sensitive type should use Keychain")
            return
        }
        
        storage.set("valid-data", forKey: key)
    }
}
```

## Performance Considerations

- **UserDefaults**: Synchronous, fast for small data, cached in memory
- **Keychain**: Slightly more overhead but still performant, encrypted storage
- **Primitive Types**: Optimized direct storage for `Bool`, `Int`, `Double`, `String`
- **Complex Objects**: Automatic JSON encoding/decoding for `Codable` types
- **Bulk Operations**: Internally optimized for multiple operations
- **Statistics**: Minimal overhead with efficient daily/session tracking

## Thread Safety

All storage operations are `@MainActor` isolated for SwiftUI safety:

```swift
// Safe in SwiftUI contexts
@Storage("user.data") private var userData = UserData()

// For background operations, dispatch to main:
Task { @MainActor in
    storage.set(backgroundData, forKey: "background.key")
}
```

## Platform Support

- **iOS** 13.0+
- **macOS** 10.15+  
- **watchOS** 6.0+
- **tvOS** 13.0+

## Architecture

```
ModernSwiftStorage
├── Core Storage Layer
│   ├── ModernStorage (main storage engine)
│   ├── UserDefaultsManager (UserDefaults operations)
│   └── KeychainManager (Keychain operations)
├── SwiftUI Integration
│   ├── StorageService (ObservableObject wrapper)
│   ├── SimpleStorageService (simplified interface)
│   └── Property Wrappers (@Storage, @SecureStorage, @UserDefaultsStorage)
├── Type Safety
│   ├── StorageKey protocol
│   ├── StorageType enum
│   └── StorageValidator
├── Analytics
│   ├── StorageStatistics
│   └── StorageStatisticsManager
└── Utilities
    ├── Migration tools
    ├── Configuration
    └── Testing mocks
```

## Best Practices

1. **Use Type-Safe Keys**: Define `StorageKey` structs for compile-time safety
2. **Let Auto-Detection Work**: Use `.automatic` storage type when possible
3. **Validate Sensitive Data**: Mark sensitive keys with `isSensitive = true`
4. **Test with Mocks**: Use provided mock implementations for testing
5. **Handle Migration**: Plan for data migration when changing storage requirements
6. **Monitor Statistics**: Use built-in analytics to understand app usage
7. **Optimize for Type**: Use primitive types when possible for better performance

## Common Patterns

### Settings Screen
```swift
struct SettingsView: View {
    @Storage("user.name") private var name = ""
    @Storage("notifications.enabled") private var notificationsEnabled = true
    @Storage("theme.isDark") private var isDarkMode = false
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
            Toggle("Notifications", isOn: $notificationsEnabled)
            Toggle("Dark Mode", isOn: $isDarkMode)
        }
    }
}
```

### Authentication
```swift
struct AuthManager {
    @Environment(\.simpleStorageService) private var storage
    
    func login(token: String) {
        storage.set(token, forKey: "auth.token") // Auto-routes to Keychain
    }
    
    func logout() {
        storage.remove(key: "auth.token", storageType: .keychain())
    }
    
    var isLoggedIn: Bool {
        return !storage.getString(forKey: "auth.token").isEmpty
    }
}
```

### Onboarding
```swift
struct OnboardingManager {
    @Storage("app.first.launch") private var isFirstLaunch = true
    @Storage("onboarding.completed") private var onboardingCompleted = false
    
    func completeOnboarding() {
        isFirstLaunch = false
        onboardingCompleted = true
    }
}
```

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/ModernSwiftStorage.git", from: "1.0.0")
]
```

Or use Xcode's Package Manager to add the repository URL.

## License

ModernSwiftStorage is available under the MIT license. See the LICENSE file for more info.

## Author

Maksim Ponomarev, https://github.com/Maxnxi

