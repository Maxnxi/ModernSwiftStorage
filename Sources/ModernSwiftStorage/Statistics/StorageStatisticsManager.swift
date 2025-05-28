//
//  StorageStatisticsManager.swift
//  modernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/27/25.
//

import Foundation

@available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *)
@MainActor
public final class StorageStatisticsManager: ObservableObject {
	@Published public private(set) var statistics = StorageStatistics()
	
	private let storage: ModernStorage
	private let statisticsKey = "com.modernstorage.statistics"
	private let keychainStatisticsKey = "com.modernstorage.statistics.keychain"
	
	init(storage: ModernStorage) {
		self.storage = storage
		loadStatistics()
		updateStatistics()
	}
	
	// MARK: - Private
	
	private func loadStatistics() {
		// Load from UserDefaults first
		if let userDefaultsData = storage.internalUserDefaultsManager.get(
			StorageStatistics.self,
			forKey: statisticsKey
		) {
			statistics = userDefaultsData
		}
		
		// Check if we have keychain data to determine install count
		detectAppReinstallation()
	}
	
	private func detectAppReinstallation() {
		// Get keychain statistics (survives app deletion)
		guard let keychainStats = storage.internalKeychainManager.get(
			StorageStatistics.self,
			forKey: keychainStatisticsKey,
			accessibility: .afterFirstUnlock
		) else {
			// First time ever - save initial data to keychain
			saveStatisticsToKeychain()
			return
		}
		
		// Compare daysUsingApp between keychain and UserDefaults
		if keychainStats.daysUsingApp > statistics.daysUsingApp {
			// App was reinstalled - keychain has more days than UserDefaults
			statistics.timesAppInstalled = keychainStats.timesAppInstalled + 1
			statistics.daysUsingApp = keychainStats.daysUsingApp
			statistics.timesUsingApp = keychainStats.timesUsingApp
			
			// Update UserDefaults with the corrected data
			saveStatisticsToUserDefaults()
		} else {
			// Normal launch - sync any missing data from keychain
			statistics.timesAppInstalled = keychainStats.timesAppInstalled
		}
	}
	
	private func saveStatisticsToUserDefaults() {
		storage.internalUserDefaultsManager.set(
			statistics,
			forKey: statisticsKey
		)
	}
	
	private func saveStatisticsToKeychain() {
		let _ = storage.internalKeychainManager.set(
			statistics,
			forKey: keychainStatisticsKey,
			accessibility: .afterFirstUnlock
		)
	}
	
	// MARK: - Public methods
	
	private func saveStatistics() {
		saveStatisticsToUserDefaults()
		saveStatisticsToKeychain()
	}
	
	public func updateStatistics() {
		let today = Date()
		let calendar = Calendar.current
		
		// Update times using app
		statistics.timesUsingApp += 1
		
		// Update daily usage
		if calendar.isDate(statistics.lastDayOpened, inSameDayAs: today) {
			statistics.timesDailyUsingApp += 1
		} else {
			statistics.timesDailyUsingApp = 1
			statistics.daysUsingApp += 1
		}
		
		statistics.lastDayOpened = today
		saveStatistics()
	}
		
	public func resetStatistics() {
		statistics = StorageStatistics()
		saveStatistics()
	}
}
