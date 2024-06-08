//
//  NetworkManager.swift
//  WeatherForecastApp
//
//  Created by Vikram Jagad on 08/06/24.
//

import UIKit
import Network

final class NetworkManager: NSObject {
    // MARK: - Properties
    // MARK: Private
    private let monitor = NWPathMonitor()
    private let logTag = "NetworkManager"
    private var status: NWPath.Status = .requiresConnection
    private var isReachableOnCellular: Bool = true
    // MARK: Public
    static let shared = NetworkManager()
    var isReachable: Bool { status == .satisfied }

    // MARK: - Initializers
    private override init() {}
    
    /// Start monitoring of the network.
    func startMonitoring() {
        monitor.pathUpdateHandler = { [unowned self] path in
            status = path.status
            isReachableOnCellular = path.isExpensive
            LogManager.shared.log(.debug, tag: logTag, message: "Network is %@, isExpensive: %d",
                                  args: path.status == .satisfied ? "connected" : "disconnected", path.isExpensive)
        }
        let queue = DispatchQueue(label: logTag, qos: .utility)
        monitor.start(queue: queue)
    }

    /// Stop monitoring of the network.
    func stopMonitoring() {
        monitor.cancel()
    }
}
