//
//  DateConverterManager.swift
//  WeatherForecastApp
//
//  Created by Vikram Jagad on 08/06/24.
//

import UIKit

/// DateConverterManager is used to convert date into user readable format.s
final class DateConverterManager: NSObject {
    // MARK: - Enums
    enum DateFormat: String {
        case eMMMddHHmm = "E, MMM, dd, HH:mm"
        case HHmm = "HH:mm"
        case ddMMM = "dd, MMM"
    }

    // MARK: - Properties
    // MARK: Public
    static let shared = DateConverterManager()

    // MARK: - Initializer
    private override init() {}

    // MARK: - Methods
    // MARK: Public
    /// Function to convert date epoch time to string.
    /// - Parameters:
    ///   - epoch: Int32
    ///   - dateFormat: DateFormat
    /// - Returns: String.
    func convertToString(_ epoch: Int32, dateFormat: DateFormat) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(epoch))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat.rawValue
        return dateFormatter.string(from: date)
    }
}
