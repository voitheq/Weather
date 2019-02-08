//
//  ViewController.swift
//  Weather
//
//  Created by Wojciech Karaś on 02/02/2019.
//  Copyright © 2019 Wojciech Karaś. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import AlamofireImage
import SwiftyJSON

class WeatherViewController: UIViewController {

    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let ICON_URL = "http://openweathermap.org/img/w/"
    let APP_ID = "a77c0f4cc04513fc5c8ea1b5031f8afd"
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var townLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TownSegue" {
            if let townViewController = segue.destination as? TownViewController {
                townViewController.delegate = self
            }
        }
    }
    
    @IBAction func townButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "TownSegue", sender: self)
    }
    
}

//MARK: - TownViewController Methods
extension WeatherViewController: TownViewControllerDelegate {
    func townViewControllerHasNewTown(town: String) {
        let parameters = ["q" : town, "appid" : APP_ID]
        getWeatherData(parameters: parameters)
    }
}

//MARK: - LocationManager Methods
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last, location.horizontalAccuracy > 0{
            manager.stopUpdatingLocation()
            manager.delegate = nil
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let parameters = ["lat": latitude, "lon": longitude, "appid": APP_ID]
            getWeatherData(parameters: parameters)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        resetUI()
    }
}

//MARK: - Networking Methods
extension WeatherViewController {
    private func getWeatherData(parameters: [String: String]){
       Alamofire.request(WEATHER_URL, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                let weatherJSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
            } else {
                self.resetUI()
            }
        }
    }
    
    private func updateWeatherData(json: JSON) {
        if let temperature = json["main"]["temp"].double, let city = json["name"].string, let weatherIconName = json["weather"][0]["icon"].string {
            weatherDataModel.temperature = Int(temperature - 273.15)
            weatherDataModel.city = city
            weatherDataModel.weatherIconName = weatherIconName + ".png"
            updateUIWithWeatherData()
        }else{
            resetUI()
        }
    }
    
    private func updateUIWithWeatherData() {
        townLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°C"
        
        Alamofire.request(ICON_URL + weatherDataModel.weatherIconName).responseImage { response in
            if let image = response.result.value {
                self.weatherIcon.image = image
            }
        }
    }
    
    private func resetUI(){
        townLabel.text = "-"
        temperatureLabel.text = "-"
        weatherIcon.image = UIImage(named: "questionmark200")
    }
}
