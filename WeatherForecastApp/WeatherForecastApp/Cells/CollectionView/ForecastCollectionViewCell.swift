//
//  ForecastCollectionViewCell.swift
//  WeatherForecastApp
//
//  Created by Vikram Jagad on 08/06/24.
//

import UIKit

class ForecastCollectionViewCell: UICollectionViewCell {
    // MARK: - IBOutlet
    // UILabel
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelHumidity: UILabel!
    @IBOutlet weak var labelWindSpeed: UILabel!

    // UIImageView
    @IBOutlet weak var imageViewCondition: UIImageView!

    // MARK: - Methods
    // MARK: Public
    /// Configure cell method to fill the value of the cell.
    /// - Parameter model: WeatherInfo model.
    func configureCell(_ model: WeatherInfo) {
        guard let imageUrl = model.weatherCondition?.icon else { return }
        imageViewCondition.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: ImageNameConstants.kPlaceholder))
        labelTime.text = DateConverterManager.shared.convertToString(model.lastUpdatedEpoch, dateFormat: .HHmm)
        labelHumidity.text = "\(model.humidity)%"
        labelWindSpeed.text = "\(model.windSpeed) km/h"
    }
}
