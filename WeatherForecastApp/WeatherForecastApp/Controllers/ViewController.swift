//
//  ViewController.swift
//  WeatherForecastApp
//
//  Created by Vikram Jagad on 07/06/24.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {
    // MARK: - Outlets
    // UIScrollView
    @IBOutlet weak var scrollView: UIScrollView!

    // UITextField
    @IBOutlet weak var textFieldCityName: UITextField!

    // UIView
    @IBOutlet weak var todaysWeatherData: UIStackView!

    // UILabel
    @IBOutlet weak var labelTodaysDate: UILabel!
    @IBOutlet weak var labelTemperature: UILabel!
    @IBOutlet weak var labelCondition: UILabel!
    @IBOutlet weak var labelHumidity: UILabel!
    @IBOutlet weak var labelWindSpeed: UILabel!
    
    // UIImageView
    @IBOutlet weak var imageViewWeatherCondition: UIImageView!

    // UICollectionView
    @IBOutlet weak var collectionViewTodaysForecast: UICollectionView!

    // UITableView
    @IBOutlet weak var tableViewForecast: UITableView!

    // NSLayoutConstraint
    @IBOutlet weak var tableViewForecastHeightConstraint: NSLayoutConstraint!

    // MARK: - Properties
    // MARK: Private
    private lazy var viewModel: ViewModel = {
        let viewModel = ViewModel(delegate: self)
        return viewModel
    }()

    // MARK: - Methods
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViewController()
    }

    // MARK: Private
    /// Set up view controller method which includes all the initial loading of the UI.
    private func setUpViewController() {
        collectionViewTodaysForecast.dataSource = self
        collectionViewTodaysForecast.register(UINib(nibName: ForecastCollectionViewCell.className, bundle: .main),
                                              forCellWithReuseIdentifier: ForecastCollectionViewCell.className)
        tableViewForecast.dataSource = self
        tableViewForecast.register(UINib(nibName: ForecastTableViewCell.className, bundle: .main),
                                   forCellReuseIdentifier: ForecastTableViewCell.className)
        collectionViewTodaysForecast.superview?.addCornerAndBorder()
        tableViewForecast.superview?.addCornerAndBorder()
        hideViews(true)
    }
    
    /// Hide views method to hide and show views based on the search.
    /// - Parameter hide: Boolean.
    private func hideViews(_ hide: Bool) {
        labelTodaysDate.isHidden = hide
        labelCondition.superview?.isHidden = hide
        todaysWeatherData.isHidden = hide
        collectionViewTodaysForecast.superview?.isHidden = hide
        tableViewForecast.superview?.isHidden = hide
    }
    
    /// Error handling function to handle errors from API.
    /// - Parameter error: String
    private func errorHandler(error: String) {
        DispatchQueue.main.async { [unowned self] in
            ActivityIndicatorView.shared.hideIndicator()
            hideViews(true)
            let alertController = UIAlertController(title: error, message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: TextConstants.kOk, style: .default))
            present(alertController, animated: true)
        }
    }
    
    /// Fill weather info method to fill the values of all the UI.
    private func fillWeatherInfo() {
        guard let weatherInfo = viewModel.weather?.model?.weatherInfo else { return }
        labelTodaysDate.text = DateConverterManager.shared
            .convertToString(weatherInfo.lastUpdatedEpoch, dateFormat: .eMMMddHHmm)
        labelTemperature.text = "\(weatherInfo.temperature)°"
        labelHumidity.text = "\(weatherInfo.humidity)%"
        labelWindSpeed.text = "\(weatherInfo.windSpeed) km/h"
        guard let weatherConditionText = weatherInfo.weatherCondition?.text else { return }
        labelCondition.text = weatherConditionText
        guard let weatherConditionIcon = weatherInfo.weatherCondition?.icon else { return }
        imageViewWeatherCondition.sd_setImage(with: URL(string: weatherConditionIcon),
                                              placeholderImage: UIImage(named: ImageNameConstants.kPlaceholder))
    }
}

// MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        ActivityIndicatorView.shared.showIndicator(view)
        viewModel.searchCity(name: text, errorHandler: errorHandler)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - ViewModelProtocol
extension ViewController: ViewModelProtocol {
    func listUpdated() {
        guard let city = viewModel.cityList.first else { return }
        textFieldCityName.text = city.name + ", " + city.state + ", " + city.country
    }

    func weatherUpdated() {
        ActivityIndicatorView.shared.hideIndicator()
        hideViews(false)
        fillWeatherInfo()
        collectionViewTodaysForecast.reloadData()
        tableViewForecast.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [unowned self] in
            tableViewForecastHeightConstraint.constant = tableViewForecast.contentSize.height
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (viewModel.weather?.model?.weatherForecastDay?.allObjects as? [WeatherForecastDay])?.first?.hourList?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ForecastCollectionViewCell.className,
                                                            for: indexPath) as? ForecastCollectionViewCell,
              let model = ((viewModel.weather?.model?.weatherForecastDay?
                .allObjects as? [WeatherForecastDay])?.first?.hourList?
                .allObjects as? [WeatherInfo])?.sorted(by: { object1, object2 in
                    return object1.lastUpdatedEpoch < object2.lastUpdatedEpoch
                })[indexPath.row] else {
            return UICollectionViewCell()
        }
        cell.configureCell(model)
        return cell
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (viewModel.weather?.model?.weatherForecastDay?.allObjects as? [WeatherForecastDay])?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ForecastTableViewCell.className,
                                                       for: indexPath) as? ForecastTableViewCell,
              let model = ((viewModel.weather?.model?.weatherForecastDay?
                .allObjects as? [WeatherForecastDay])?.sorted(by: { object1, object2 in
                    return object1.timeEpoch < object2.timeEpoch
                })[indexPath.row].hourList?
                .allObjects as? [WeatherInfo])?.first else {
            return UITableViewCell()
        }
        cell.configureCell(model)
        return cell
    }
}
