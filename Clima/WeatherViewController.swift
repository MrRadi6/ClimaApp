//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController,CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let weatherDataModel = WeatherDataModel()
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "d90cd4ce93b47c5502640aad265ca4d3"
    var tempScale: String = " ℃"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    let locatonManager = CLLocationManager()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locatonManager.delegate = self
        locatonManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locatonManager.requestWhenInUseAuthorization()
        locatonManager.startUpdatingLocation()
        
        
    }
    
    //Swtich to setting up the temperature Scale system
    @IBAction func tempScaleButton(_ sender: UISwitch) {
        if sender.isOn{
            tempScale = " ℃"
            weatherDataModel.setTempToC()
        }
        else{
            tempScale = " ℉"
            weatherDataModel.setTempToF()
        }
        print(tempScale)
        updateUIWithWeatherData()
    }
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, param: [String:String]){
        Alamofire.request(url, method: .get, parameters: param).responseJSON { responce in
            if responce.result.isSuccess{
                print("Connection Success")
                let weather_JSON: JSON = JSON(responce.result.value!)
                self.updateWeatherData(json: weather_JSON)
            }
            else{
                self.cityLabel.text = "Connection failed"
                print("Error: \(String(describing: responce.result.error))")
            }
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON){
        if let temperature = json["main"]["temp"].double{
            weatherDataModel.temeratureC = Int(temperature - 273.15)
            weatherDataModel.temeratureF = Int(temperature - 273.15) * 9/5 + 32
            weatherDataModel.setTempToC()
            weatherDataModel.ciyName = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            weatherDataModel.weatherIconName =  weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
        }
        else{
            cityLabel.text = "Weather unavailable"
        }
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData(){
        temperatureLabel.text = String(weatherDataModel.temperature)+tempScale
        cityLabel.text = weatherDataModel.ciyName
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("setting up the location")
        let location = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0{
            locatonManager.stopUpdatingLocation()
            locatonManager.delegate = nil // top ensure not reapeating the result while it stop updating cuz the other thread might take awhile
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            print("latitude: \(latitude), Longitude: \(longitude)")
            let params: [String:String] = ["lat":latitude,"lon":longitude,"appid":self.APP_ID]
            
            getWeatherData(url: WEATHER_URL, param: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        cityLabel.text = "Location unavailable"
        print(error)
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userChangedCity(city: String) {
        let params: [String:String] = ["q":city,"appid":self.APP_ID]
        getWeatherData(url: self.WEATHER_URL, param: params)
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
    
}


