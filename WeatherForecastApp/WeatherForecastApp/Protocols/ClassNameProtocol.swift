//
//  ClassNameProtocol.swift
//  WeatherForecastApp
//
//  Created by Vikram Jagad on 08/06/24.
//

import Foundation

/// ClassNameProtocol is used to use className properties in all the classes.
protocol ClassNameProtocol {
    // MARK: - Properties
    // MARK: Public
    static var className: String { get }
    var className: String { get }
}

extension ClassNameProtocol {
    static var className: String {
        return String(describing: self)
    }
    var className: String {
        return type(of: self).className
    }
}

extension NSObject: ClassNameProtocol {}
