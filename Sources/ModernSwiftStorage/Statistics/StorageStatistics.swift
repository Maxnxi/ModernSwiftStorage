//
//  StorageStatistics.swift
//  modernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/27/25.
//


import Foundation

public struct StorageStatistics: Codable {
	public var daysUsingApp: Int = 0
	public var timesUsingApp: Int = 0
	public var timesDailyUsingApp: Int = 0
	public var lastDayOpened: Date = Date()
	public var timesAppInstalled: Int = 0
	
	public init() {}
}
