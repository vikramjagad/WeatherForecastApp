//
//  UIView+Extension.swift
//  WeatherForecastApp
//
//  Created by Vikram Jagad on 08/06/24.
//

import UIKit

extension UIView {
    /// Adds corner radius and border to view calling this method.
    func addCornerAndBorder() {
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray6.cgColor
        layer.cornerRadius = 8
    }
}
