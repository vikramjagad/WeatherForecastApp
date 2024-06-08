//
//  WeatherModel.swift
//  WeatherForecastApp
//
//  Created by Vikram Jagad on 08/06/24.
//

import Foundation

struct WeatherModel: Decodable {
    // MARK: - Enums
    private enum RequestKeys: String {
        case cityName = "q"
        case days
        case aqi
        case alerts
    }
    enum CodingKeys: String, CodingKey {
        case current
        case last_updated_epoch
        case temp_c
        case condition
        case text
        case icon
        case wind_kph
        case humidity
        case forecast
        case forecastday
        case hour
        case time_epoch
        case date_epoch
    }
    // MARK: - Properties
    // MARK: Private
    private lazy var context = CoreDataManager.shared.persistentContainer.viewContext
    // MARK: Public
    var model: Weather?

    // MARK: - Initializers
    init() {}

    init(from decoder: Decoder) throws {
        let weather = Weather(context: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let weatherInfo = try parseCurrentObjects(from: container)
        weather.weatherInfo = weatherInfo
        let forecastData = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .forecast)
        var forecastDayList = try forecastData.nestedUnkeyedContainer(forKey: .forecastday)
        weather.weatherForecastDay = []
        try parseForecastObjects(from: &forecastDayList, weather: weather)
        model = weather
    }
    
    /// It parses the current objects and provides WeatherInfo object.
    /// - Parameter container: KeyedDecodingContainer<CodingKeys>.
    /// - Returns: WeatherInfo.
    private mutating func parseCurrentObjects(from container: KeyedDecodingContainer<CodingKeys>) throws -> WeatherInfo {
        let weatherInfo = WeatherInfo(context: context)
        let weatherCondition = WeatherCondition(context: context)
        let currentData = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .current)
        let lastUpdatedEpoch = try currentData.decode(Int32.self, forKey: .last_updated_epoch)
        weatherInfo.lastUpdatedEpoch = lastUpdatedEpoch
        let temperature = try currentData.decode(Float.self, forKey: .temp_c)
        weatherInfo.temperature = temperature
        let conditionData = try currentData.nestedContainer(keyedBy: CodingKeys.self, forKey: .condition)
        let text = try conditionData.decode(String.self, forKey: .text)
        weatherCondition.text = text
        let icon = try conditionData.decode(String.self, forKey: .icon)
        weatherCondition.icon = "https:" + icon
        weatherInfo.weatherCondition = weatherCondition
        let windSpeed = try currentData.decode(Float.self, forKey: .wind_kph)
        weatherInfo.windSpeed = windSpeed
        let humidity = try currentData.decode(Int16.self, forKey: .humidity)
        weatherInfo.humidity = humidity
        return weatherInfo
    }
    
    /// It parses the forecast objects and adds them in weather object.
    /// - Parameters:
    ///   - forecastDayList: UnkeyedDecodingContainer.
    ///   - weather: Weather.
    private mutating func parseForecastObjects(from forecastDayList: inout UnkeyedDecodingContainer, weather: Weather) throws {
        while !forecastDayList.isAtEnd {
            let weatherForecastDay = WeatherForecastDay(context: context)
            let forecastDayListObject = try forecastDayList.nestedContainer(keyedBy: CodingKeys.self)
            let dateEpochInDayList = try forecastDayListObject.decode(Int32.self, forKey: .date_epoch)
            weatherForecastDay.timeEpoch = dateEpochInDayList
            weatherForecastDay.hourList = []
            var hourList = try forecastDayListObject.nestedUnkeyedContainer(forKey: .hour)
            try parseHourListObjects(from: &hourList, weatherForecastDay: weatherForecastDay)
            weather.addToWeatherForecastDay(weatherForecastDay)
        }
    }
    
    /// It parses the hour data and adds it in WeatherForecastData.
    /// - Parameters:
    ///   - hourList: UnkeyedDecodingContainer
    ///   - weatherForecastDay: WeatherForecastDay.
    private mutating func parseHourListObjects(from hourList: inout UnkeyedDecodingContainer, weatherForecastDay: WeatherForecastDay) throws {
        while !hourList.isAtEnd {
            let hourWeatherInfo = WeatherInfo(context: context)
            let hourData = try hourList.nestedContainer(keyedBy: CodingKeys.self)
            let lastUpdatedEpochInHour = try hourData.decode(Int.self, forKey: .time_epoch)
            hourWeatherInfo.lastUpdatedEpoch = Int32(lastUpdatedEpochInHour)
            let temperatureInHour = try hourData.decode(Float.self, forKey: .temp_c)
            hourWeatherInfo.temperature = temperatureInHour
            let conditionDataInHourData = try hourData.nestedContainer(keyedBy: CodingKeys.self, forKey: .condition)
            let hourWeatherCondition = WeatherCondition(context: context)
            let textInHour = try conditionDataInHourData.decode(String.self, forKey: .text)
            hourWeatherCondition.text = textInHour
            let iconInHour = try conditionDataInHourData.decode(String.self, forKey: .icon)
            hourWeatherCondition.icon = "https:" + iconInHour
            hourWeatherInfo.weatherCondition =  hourWeatherCondition
            let windSpeedInHour = try hourData.decode(Float.self, forKey: .wind_kph)
            hourWeatherInfo.windSpeed = windSpeedInHour
            let humidityInHour = try hourData.decode(Int16.self, forKey: .humidity)
            hourWeatherInfo.humidity = humidityInHour
            weatherForecastDay.addToHourList(hourWeatherInfo)
        }
    }
}

extension WeatherModel {
    /// Get forecast method is used to get the next 5 days forecast for the city, if there is no connection, data is fetched from local database.
    /// - Parameters:
    ///   - cityName: String
    ///   - errorHandler: Closure with String.
    /// - Returns: WeatherModel?.
    static func getForecast(cityName: String, errorHandler: ((String) -> Void)?) async -> WeatherModel? {
        let queryItems = [RequestKeys.cityName.rawValue: cityName,
                          RequestKeys.days.rawValue: "5",
                          RequestKeys.aqi.rawValue: "yes",
                          RequestKeys.alerts.rawValue: "yes"]
        let response: WebServiceResponse<WeatherModel> = await WebServicesManager.shared
            .sendRequest(endPoint: .forecast, queryItems: queryItems)
        func fetchWeatherModel(cityName: String) -> Weather? {
            let fetchRequest = Weather.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "city == %@", cityName)
            do {
                let weatherList = try CoreDataManager.shared.persistentContainer.viewContext.fetch(fetchRequest)
                if let weather = weatherList.first {
                    return weather
                } else {
                    return nil
                }
            } catch {
                errorHandler?(error.localizedDescription)
                return nil
            }
        }
        switch response {
        case .failure(let webServiceErrors):
            if let model = fetchWeatherModel(cityName: cityName) {
                var weatherModel = WeatherModel()
                weatherModel.model = model
                return weatherModel
            } else {
                errorHandler?(webServiceErrors.errorDescription)
                return nil
            }
        case .success(let model):
            if let weather = fetchWeatherModel(cityName: cityName) {
                CoreDataManager.shared.persistentContainer.viewContext.delete(weather)
            }
            return model
        }
    }
}
