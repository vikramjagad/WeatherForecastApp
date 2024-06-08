//
//  LogManager.swift
//  WeatherForecastApp
//
//  Created by Vikram Jagad on 07/06/24.
//

import UIKit

final class LogManager: NSObject {
    // MARK: - Enum
    /// LogType enum for logging.
    enum LogType {
        case debug
        case information
        case error
        case fatal
    }
    // MARK: - Properties
    // MARK: Public
    static let shared = LogManager()

    // MARK: - Initializers
    private override init() {}

    // MARK: - Methods
    // MARK: Public
    /// Log the tag and message along with time.
    /// - Parameters:
    ///   - tag: Tag
    ///   - message: Message
    func log(_ logType: LogType, tag: String, message: String, args: CVarArg...) {
        var logTypeString = ""
        switch logType {
        case .debug:
            #if DEBUG
            print(Date(), "🐞", "\(tag):", "\(String(format: message, arguments: args))", separator: " ")
            return
            #endif
        case .information:
            logTypeString = "ℹ️"
        case .error:
            logTypeString = "🔴"
        case .fatal:
            fatalError("\(Date()), \(tag): \(String(format: message, arguments: args))")
        }
        print(Date(), logTypeString, "\(tag):", "\(String(format: message, arguments: args))", separator: " ")
    }
}
