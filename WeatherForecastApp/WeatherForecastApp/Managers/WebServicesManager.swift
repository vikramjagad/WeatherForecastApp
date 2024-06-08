//
//  WebServicesManager.swift
//  WeatherForecastApp
//
//  Created by Vikram Jagad on 08/06/24.
//

import UIKit

/// WebServiceErrors.
enum WebServiceErrors: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case invalidStatus(Int)
    case invalidError(String)
    case noInternetConnection

    public var errorDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid Url"
        case .invalidResponse:
            return "Invalid Response"
        case .invalidStatus(let code):
            return "Invalid Status code: \(code)"
        case .invalidError(let description):
            return "Invalid Error: \(description)"
        case .noInternetConnection:
            return "No Internet Connection"
        }
    }
}

/// WebServiceResponse.
enum WebServiceResponse<T> {
    case failure(WebServiceErrors)
    case success(T)
}

/// WebServicesManager class is used to call the Web APIs.
final class WebServicesManager: NSObject {
    // MARK: - Enum
    /// Environment of the API.
    private enum Environments: Int {
        case live

        var baseUrl: String {
            switch self {
            case .live:
                return "https://api.weatherapi.com"
            }
        }
    }
    /// Common Request Keys
    private enum RequestKeys: String {
        case apiKey = "key"
    }
    /// Common Request Values
    private enum RequestValues: String {
        case apiKey = "aeb3583d46e048a38c170507240606"
    }
    /// Version of the API.
    private enum Versions: String {
        case v1
    }
    /// HTTP Method of the API.
    enum HttpMethod: String {
        case get
    }
    /// Endpoints of the API.
    enum EndPoints: String {
        case search = "search.json"
        case forecast = "forecast.json"
    }

    // MARK: - Properties
    // MARK: Private
    private let environment = Environments.live
    private let version = Versions.v1
    private let logTag = "WebServicesManager"
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.networkServiceType = .default
        return URLSession(configuration: config)
    }()
    // MARK: Public
    static let shared = WebServicesManager()

    // MARK: - Initializers
    private override init() {}

    // MARK: - Methods
    // MARK: Private
    /// Build url function is used to build url with endpoint.
    /// - Parameter endPoint: EndPoints
    /// - Returns: URL
    private func buildUrl(endPoint: EndPoints) throws -> URL {
        guard var baseUrl = URL(string: environment.baseUrl) else { throw WebServiceErrors.invalidURL }
        baseUrl.appendPathComponent(version.rawValue)
        baseUrl.appendPathComponent(endPoint.rawValue)
        return baseUrl
    }
    
    /// To add query parameters in the URL
    /// - Parameters:
    ///   - url: URL
    ///   - queryItems: [String: String]?
    private func addQueryParametersInUrl(_ url: inout URL, queryItems: [String: String]?) {
        if let queryItems = queryItems {
            var urlComps = URLComponents(string: url.absoluteString)
            urlComps?.queryItems = queryItems.map({ URLQueryItem(name: $0.key, value: $0.value) })
            
            if let urlComps = urlComps?.url {
                url = urlComps.absoluteURL
            }
        }
    }

    // MARK: Public
    /// Send request to Web API.
    /// - Parameters:
    ///   - endPoint: EndPoint
    ///   - headers: Headers
    ///   - body: Body
    ///   - method: Method
    ///   - queryItems: [String: String]?
    /// - Returns: WebServiceResponse with failure or success.
    func sendRequest<T: Decodable>(endPoint: EndPoints, headers: [String: String] = [:], body: Data? = nil,
                                   method: HttpMethod = .get, queryItems: [String: String]? = nil) async -> WebServiceResponse<T> {
        if NetworkManager.shared.isReachable {
            do {
                var updatedQueryItems = [RequestKeys.apiKey.rawValue: RequestValues.apiKey.rawValue]
                if let queryItems = queryItems {
                    updatedQueryItems = updatedQueryItems.merging(queryItems,
                                                                  uniquingKeysWith: { (_, second) in second })
                }
                var url = try buildUrl(endPoint: endPoint)
                addQueryParametersInUrl(&url, queryItems: updatedQueryItems)
                var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
                request.httpMethod = method.rawValue
                request.httpBody = body
                LogManager.shared.log(.debug, tag: logTag, message: "Request: %@, url: %@",
                                      args: method.rawValue, url.absoluteString)
                for (key, value) in headers {
                    request.setValue(value, forHTTPHeaderField: key)
                }
                if let headerFields = request.allHTTPHeaderFields {
                    LogManager.shared.log(.debug, tag: logTag, message: "Headers: \(headerFields)", args: [])
                }
                if let body = body, let string = String(data: body, encoding: .utf8) {
                    LogManager.shared.log(.debug, tag: logTag, message: "Body: %@", args: string)
                }
                let (data, response) = try await session.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw WebServiceErrors.invalidResponse
                }
                LogManager.shared.log(.debug, tag: logTag, message: "StatusCode: %d", args: httpResponse.statusCode)
                if let string = String(data: data, encoding: .utf8) {
                    LogManager.shared.log(.debug, tag: logTag, message: "Response: %@", args: string)
                }
                guard httpResponse.statusCode == 200 else {
                    return .failure(WebServiceErrors.invalidStatus(httpResponse.statusCode))
                }
                guard let responseModel = try? JSONDecoder().decode(T.self, from: data) else {
                    return .failure(WebServiceErrors.invalidResponse)
                }
                return .success(responseModel)
            } catch let error {
                return .failure(WebServiceErrors.invalidError(error.localizedDescription))
            }
        } else {
            return .failure(WebServiceErrors.noInternetConnection)
        }
    }
}
