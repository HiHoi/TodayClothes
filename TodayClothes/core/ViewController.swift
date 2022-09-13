//
//  ViewController.swift
//  TodayClothes
//
//  Created by Hosung Lim on 2022/09/09.
//


import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //위치 서비스 속성
    var locationManager : CLLocationManager!
    var lat : Double!
    var lon: Double!
   
    
    //날씨 서비스 속성
    var weather : Weather?
    var main : Main?
    var name : String?
    
    //날씨 서비스 UI 연결
    //StoryBoard와 연결
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var feelsLike : UILabel!
    
    private func setWeatherUI(){
        let url = URL(string: "https://openweathermap.org/img/wn/\(self.weather?.icon ?? "00")@2x.png")
        let data = try? Data(contentsOf: url!)
        if let data = data {
            iconImageView.image = UIImage(data: data)
        }
        tempLabel.text = "\(main!.temp)"
        minTempLabel.text = "\(main!.temp_min)"
        maxTempLabel.text = "\(main!.temp_max)"
        feelsLike.text = "\(main!.feels_like)"
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //위치 함수 
        getLocation()
        //날씨 함수
        getWeather { result in
            switch result {
            case .success(let weatherResponse) :
                DispatchQueue.main.async {
                    self.weather = weatherResponse.weather.first
                    self.main = weatherResponse.main
                    self.name = weatherResponse.name
                    self.setWeatherUI()
                }
            case .failure(_ ):
                print("error")
            }
        }
    }
    
    //위치 정보 얻기
    func getLocation () {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        let location = locationManager.location?.coordinate
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            lat = location?.latitude
            lon = location?.longitude
        } else {
            print("위치 서비스 허용 Off")
        }
    }

    //날씨정보 얻기
    private var apiKey : String {
        get {
            guard let filePath = Bundle.main.path(forResource: "weatherApi", ofType: "plist") else { fatalError("Couldn't find file.")
            }
            let plist = NSDictionary(contentsOfFile: filePath)
            
            guard let value = plist?.object(forKey: "OPENWEATHERAPI_KEY") as? String else { fatalError("I can't find my key...where...")
            }
            return value
        }
    }
    enum NetworkError : Error {
        case badURL
        case noData
        case decodingError
    }
    
    func getWeather(completion: @escaping (Result<WeatherResponse, NetworkError>)->Void) {
        let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat!)&lon=\(lon!)&appid=\(apiKey)&units=metric")
      
        guard let url = url else {
            return completion(.failure(.badURL))
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return completion(.failure(.noData))
            }
            
            let weatherResponse = try? JSONDecoder().decode(WeatherResponse.self, from: data)
            
            if let weatherResponse = weatherResponse {
                print(weatherResponse)
                completion(.success(weatherResponse))
            } else {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}

