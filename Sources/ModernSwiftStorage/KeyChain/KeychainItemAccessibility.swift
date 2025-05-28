//
//  KeychainItemAccessibility.swift
//  modernSwiftStorage
//
//  Created by Maksim Ponomarev on 5/27/25.
//


import Foundation

public enum KeychainItemAccessibility: Sendable {
	case afterFirstUnlock
	case afterFirstUnlockThisDeviceOnly
	case always
	case whenPasscodeSetThisDeviceOnly
	case alwaysThisDeviceOnly
	case whenUnlocked
	case whenUnlockedThisDeviceOnly
	
	var keychainAttrValue: CFString {
		switch self {
		case .afterFirstUnlock:
			return kSecAttrAccessibleAfterFirstUnlock
		case .afterFirstUnlockThisDeviceOnly:
			return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
		case .always:
			return kSecAttrAccessibleAlways
		case .whenPasscodeSetThisDeviceOnly:
			return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
		case .alwaysThisDeviceOnly:
			return kSecAttrAccessibleAlwaysThisDeviceOnly
		case .whenUnlocked:
			return kSecAttrAccessibleWhenUnlocked
		case .whenUnlockedThisDeviceOnly:
			return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
		}
	}
}
