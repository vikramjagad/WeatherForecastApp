//
//  ViewModel.swift
//  WeatherForecastApp
//
//  Created by Vikram Jagad on 08/06/24.
//

import UIKit

/// ViewModelProtocol contains methods to notify View to update the UI.
protocol ViewModelProtocol: NSObjectProtocol {
    /// City list updates are shared to UI using this method.
    func listUpdated()
    /// Weather Info updates are shared to UI using this method.
    func weatherUpdated()
}

class ViewModel: NSObject {
    // MARK: - Properties
    // MARK: Private
    weak var delegate: ViewModelProtocol?
    // MARK: Public
    var cityList: [CityModel] = []
    var weather: WeatherModel?

    // MARK: - Initializer
    init(delegate: ViewModelProtocol?) {
        self.delegate = delegate
    }

    // MARK: - Methods
    // MARK: Public
    /// Search city API call is done and if there is no internet connection, data is fetched from local database.
    /// - Parameters:
    ///   - name: String.
    ///   - errorHandler: Closure with String.
    func searchCity(name: String, errorHandler: ((String) -> Void)?) {
        cityList.removeAll()
        Task { @MainActor in
            if let cityList = await CityModel.searchCity(name, errorHandler: { [unowned self] error in
                errorHandler?(error.errorDescription)
                switch error {
                case .noInternetConnection:
                    getForecast(cityName: name, errorHandler: errorHandler)
                default:
                    break
                }
            }) {
                self.cityList = cityList
                delegate?.listUpdated()
                getForecast(cityName: name, errorHandler: errorHandler)
            }
        }
    }
    
    /// Forecast API is called, if data is there in city list, which means, Search API is success, if city list doesnot have value, which means, there was no
    /// internet connection at the time of Search API call and this method is called from there.
    /// - Parameters:
    ///   - cityName: String.
    ///   - errorHandler: Closure with String.
    func getForecast(cityName: String, errorHandler: ((String) -> Void)?) {
        Task { @MainActor in
            if let weatherModel = await WeatherModel.getForecast(cityName: cityName, errorHandler: errorHandler) {
                if let city = cityList.first {
                    weatherModel.model?.identifier = city.id
                    weatherModel.model?.city = city.name
                    weatherModel.model?.state = city.state
                    weatherModel.model?.country = city.country
                } else if let model = weatherModel.model {
                    cityList = [CityModel(id: model.identifier, name: model.city ?? "",
                                          state: model.state ?? "", country: model.country ?? "")]
                    delegate?.listUpdated()
                }
                weather = weatherModel
                CoreDataManager.shared.saveContext()
                delegate?.weatherUpdated()
            }
        }
    }
}
