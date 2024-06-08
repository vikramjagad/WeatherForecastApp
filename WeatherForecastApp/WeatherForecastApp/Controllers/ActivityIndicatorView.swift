//
//  ActivityIndicatorView.swift
//  WeatherForecastApp
//
//  Created by Vikram Jagad on 08/06/24.
//

import UIKit

/// ActivityIndicatorView class is used to show activity indicator on the UI.
final class ActivityIndicatorView: UIView {
    // MARK: - Properties
    // MARK: Private
    private lazy var centerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addCornerAndBorder()
        return view
    }()

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = UIColor(named: ColorNameConstants.k8AB9E3) ?? .systemGray2
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.heightAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicator.widthAnchor.constraint(equalTo: activityIndicator.heightAnchor).isActive = true
        return activityIndicator
    }()

    // MARK: Public
    static let shared = ActivityIndicatorView(frame: .zero)

    // MARK: - Initializers
    private init() {
        super.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    // MARK: - Methods
    // MARK: Private
    private func commonInit() {
        backgroundColor = .label.withAlphaComponent(0.5)
        addSubview(centerView)
        centerView.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            centerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            centerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            centerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicatorView.leadingAnchor.constraint(equalTo: centerView.leadingAnchor, constant: 24),
            activityIndicatorView.trailingAnchor.constraint(equalTo: centerView.trailingAnchor, constant: -24),
            activityIndicatorView.topAnchor.constraint(equalTo: centerView.topAnchor, constant: 24),
            activityIndicatorView.bottomAnchor.constraint(equalTo: centerView.bottomAnchor, constant: -24),
        ])
    }

    // MARK: Public
    /// Show view on the full screen with activity indicator.
    /// - Parameter view: UIView.
    func showIndicator(_ view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        tag = 10000000
        if let activityIndicatorView = view.viewWithTag(10000000) {
            activityIndicatorView.removeFromSuperview()
        }
        view.addSubview(self)
        view.addConstraints([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        activityIndicatorView.startAnimating()
    }
    
    /// Hide view with indicator.
    func hideIndicator() {
        activityIndicatorView.stopAnimating()
        removeFromSuperview()
    }
}
