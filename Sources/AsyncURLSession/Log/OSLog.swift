//
//  OSLog.swift
//  AsyncURLSession
//
//  Created by Wonji Suh  on 10/9/24.
//

import Foundation
import OSLog

extension OSLog {
    static let subsystem = Bundle.main.bundleIdentifier ?? "com.default.subsystem"
    static let network = OSLog(subsystem: subsystem, category: "Network")
    static let debug = OSLog(subsystem: subsystem, category: "Debug")
    static let info = OSLog(subsystem: subsystem, category: "Info")
    static let error = OSLog(subsystem: subsystem, category: "Error")
    static let test = OSLog(subsystem: subsystem, category: "Test")
}
