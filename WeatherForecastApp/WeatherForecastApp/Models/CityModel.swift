//
//  CityModel.swift
//  WeatherForecastApp
//
//  Created by Vikram Jagad on 08/06/24.
//

import Foundation

/// City model to parse the search API.
struct CityModel: Codable {
    // MARK: - Enums
    /// Coding keys for city model
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case state = "region"
        case country
    }
    private enum RequestKeys: String {
        case cityName = "q"
    }

    // MARK: - Properties
    // MARK: Public
    let id: Int32
    let name: String
    let state: String
    let country: String
}

extension CityModel {
    /// Search city method is used to call Search API with query parameters.
    /// - Parameters:
    ///   - name: String
    ///   - errorHandler: Closure with WebServiceErrors.
    /// - Returns: [CityModel]?
    static func searchCity(_ name: String, errorHandler: ((WebServiceErrors) -> Void)?) async -> [CityModel]? {
        let queryItems = [RequestKeys.cityName.rawValue: name]
        let response: WebServiceResponse<[CityModel]> = await WebServicesManager.shared
            .sendRequest(endPoint: .search, method: .get, queryItems: queryItems)
        switch response {
        case .failure(let error):
            errorHandler?(error)
            return nil
        case .success(let model):
            return model
        }
    }
}
