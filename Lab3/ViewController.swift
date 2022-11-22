//
//  ViewController.swift
//  Lab3
//
//  Created by Sergio Golbert on 2022-11-20.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var weatherConditionImage: UIImageView!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var conditionLabel: UILabel!
    
    @IBOutlet weak var degreeLabel: UILabel!
    
    //Bool used for changing between Celsius and Fahrenheit
    var isCelsius = true
    
    //Variables used for current Location
    var currentLatitude: Double = 0.0
    var currentLongitude: Double = 0.0
    
    //Location Manager
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        displaySampleImageForDemo()
        searchTextField.delegate = self
        
        //Ask for permission to get the user's location
        locationManager.requestWhenInUseAuthorization()
        //Setting up a Delegate for the location manager
        locationManager.delegate = self
        //Start getting location
        locationManager.startUpdatingLocation()
        
    }
    
    
    @IBAction func onSwitchChange(_ sender: UISwitch) {
        isCelsius = !isCelsius
        if(isCelsius){
            degreeLabel.text = "°C"
        } else {
            degreeLabel.text = "°F"
        }
    }
    
    //Used for the text keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        loadWeather(search: searchTextField.text)
        return true
    }

    @IBAction func onLocationTapped(_ sender: UIButton) {
        loadWeather(search: "\(currentLatitude),\(currentLongitude)")
    }
    
    @IBAction func onSearchTapped(_ sender: UIButton) {
        loadWeather(search: searchTextField.text)
    }
    
    //Use as base for setting weather images
    private func displaySampleImageForDemo(){
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemYellow,.systemBlue,.systemRed])
        weatherConditionImage.preferredSymbolConfiguration = config
        
        weatherConditionImage.image = UIImage(systemName: "sparkles")
    }
    
    private func loadWeather(search: String?){
        //Guard so function quits if there's nothing on search
        guard let search = search else {
            return
        }
        //Step 1: Get URL
        guard let url = getURL(query: search) else {
            print("Couldn't get URL")
            return
        }
        
        //Step 2: Create URLSession
        let session = URLSession.shared
        
        //Step 3: Create the task for the session
        let dataTask = session.dataTask(with: url) { data, response, error in
                //network call finished
            print("Network Call complete")


            guard error == nil else {
                print("Error happened")
                return
            }
            
            guard let data = data else {
                print("No data found")
                return
            }
            
            //Decode the data
            if let weatherResponse = self.parseJson(data: data){
                print(weatherResponse.location.name)
                print(weatherResponse.current.temp_c)
                
                DispatchQueue.main.async {
                    self.locationLabel.text = weatherResponse.location.name
                    
                    if(self.isCelsius){
                        self.temperatureLabel.text = "\(weatherResponse.current.temp_c)°C"
                    } else {
                        self.temperatureLabel.text = "\(weatherResponse.current.temp_f)°F"
                    }
                    
                    self.setWeatherImage(code: weatherResponse.current.condition.code)
                }
                
                //You cannot update the UI from a background thread
                //self.locationLabel.text = weatherResponse.location.name
                //self.temperatureLabel.text = "\(weatherResponse.current.temp_c)C"
            }

        }
        
        //Step 4: Start the task(because the task starts suspended)
        dataTask.resume()
    }
    
    //Get API URL
    private func getURL(query: String) -> URL?{
        
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        //In a real app you shouldn't add the apiKey in your code -> should be get from another server to be downloaded securelly
        let apiKey = "1a8ee67e40f84690baf183338222011"
        guard let url = "\(baseUrl)\(currentEndpoint)?key=\(apiKey)&q=\(query)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            print("Error")
            return nil
        }
        
        return URL(string: url)
    }
    
    private func parseJson(data: Data) -> WeatherResponse? {
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        do {
            weather = try decoder.decode(WeatherResponse.self,from: data)
        } catch {
            print("Error Decoding")
        }
        return weather
    }
    
    //Setting weather image and condition
    private func setWeatherImage(code: Int){
        switch code {
            
        case 1000: weatherConditionImage.image = UIImage(systemName: "sun.max.fill")
                    conditionLabel.text = "Sunny"
            
        case 1003: weatherConditionImage.image = UIImage(systemName: "cloud")
            conditionLabel.text = "Partly Cloudy"
            
        case 1006: weatherConditionImage.image = UIImage(systemName: "cloud.fill")
            conditionLabel.text = "Cloudy"
            
        case 1009: weatherConditionImage.image = UIImage(systemName: "cloud.fill")
            conditionLabel.text = "Overcast"
            
        case 1030: weatherConditionImage.image = UIImage(systemName: "cloud")
            conditionLabel.text = "Mist"
            
        case 1063: weatherConditionImage.image = UIImage(systemName: "cloud.drizzle")
            conditionLabel.text = "Patchy Rain Possible"
            
        case 1066: weatherConditionImage.image = UIImage(systemName: "cloud.snow")
            conditionLabel.text = "Patchy Snow Possible"
            
        case 1069: weatherConditionImage.image = UIImage(systemName: "cloud.hail")
            conditionLabel.text = "Patchy Sleet Possible"
            
        case 1072: weatherConditionImage.image = UIImage(systemName: "cloud.drizzle")
            conditionLabel.text = "Patchy Freezing Drizzle Possible"
            
        case 1087: weatherConditionImage.image = UIImage(systemName: "cloud.bolt")
            conditionLabel.text = "Patchy Sleet Possible"
            
        case 1114: weatherConditionImage.image = UIImage(systemName: "wind.snow")
            conditionLabel.text = "Blowing Snow"
            
        case 1117: weatherConditionImage.image = UIImage(systemName: "wind.snow.circle.fill")
            conditionLabel.text = "Blizzard"
            
        case 1135: weatherConditionImage.image = UIImage(systemName: "cloud.fog")
            conditionLabel.text = "Fog"
            
        case 1147: weatherConditionImage.image = UIImage(systemName: "cloud.snow.fill")
            conditionLabel.text = "Freezing Fog"
            
        case 1150: weatherConditionImage.image = UIImage(systemName: "cloud.drizzle")
            conditionLabel.text = "Patchy Light Drizzle"
            
        case 1153: weatherConditionImage.image = UIImage(systemName: "cloud.drizzle")
            conditionLabel.text = "Light Drizzle"
            
        case 1168: weatherConditionImage.image = UIImage(systemName: "cloud.drizzle")
            conditionLabel.text = "Freezing Drizzle"
            
        case 1171: weatherConditionImage.image = UIImage(systemName: "cloud.heavyrain.fill")
            conditionLabel.text = "Heavy Freezing drizzle"
            
        case 1180: weatherConditionImage.image = UIImage(systemName: "cloud.drizzle")
            conditionLabel.text = "Patchy Light Rain"
            
        case 1183: weatherConditionImage.image = UIImage(systemName: "cloud.drizzle")
            conditionLabel.text = "Light Rain"
            
        case 1186: weatherConditionImage.image = UIImage(systemName: "cloud.drizzle.fill")
            conditionLabel.text = "Moderate rain at times"
            
        case 1189: weatherConditionImage.image = UIImage(systemName: "cloud.drizzle.fill")
            conditionLabel.text = "Moderate rain"
            
        case 1192: weatherConditionImage.image = UIImage(systemName: "cloud.heavyrain")
            conditionLabel.text = "Heavy Rain at times"
            
        case 1195: weatherConditionImage.image = UIImage(systemName: "cloud.heavyrain.fill")
            conditionLabel.text = "Heavy Rain"
            
        case 1198: weatherConditionImage.image = UIImage(systemName: "cloud.drizzle")
            conditionLabel.text = "Light Freezing Rain"
            
        case 1201: weatherConditionImage.image = UIImage(systemName: "cloud.drizzle")
            conditionLabel.text = "Moderate or heavy freezing rain"
            
        case 1204: weatherConditionImage.image = UIImage(systemName: "cloud.hail")
            conditionLabel.text = "Light Sleet"
            
        case 1207: weatherConditionImage.image = UIImage(systemName: "cloud.hail.fill")
            conditionLabel.text = "Moderate or heavy sleet"
            
        case 1210: weatherConditionImage.image = UIImage(systemName: "cloud.snow")
            conditionLabel.text = "Patchy light snow"
            
        case 1213: weatherConditionImage.image = UIImage(systemName: "cloud.snow")
            conditionLabel.text = "Light Snow"
            
        case 1216: weatherConditionImage.image = UIImage(systemName: "cloud.snow.fill")
            conditionLabel.text = "Patchy Moderate Snow"
            
        case 1219: weatherConditionImage.image = UIImage(systemName: "cloud.snow.fill")
            conditionLabel.text = "Moderate Snow"
            
        case 1222: weatherConditionImage.image = UIImage(systemName: "cloud.snow.fill")
            conditionLabel.text = "Patchy heavy snow"
            
        case 1225: weatherConditionImage.image = UIImage(systemName: "cloud.snow.fill")
            conditionLabel.text = "Heavy Snow"
            
        case 1237: weatherConditionImage.image = UIImage(systemName: "cloud.hail.fill")
            conditionLabel.text = "Ice Pellets"
            
        case 1240: weatherConditionImage.image = UIImage(systemName: "cloud.drizzle")
            conditionLabel.text = "Light rain shower"
            
        case 1243: weatherConditionImage.image = UIImage(systemName: "cloud.heavyrain")
            conditionLabel.text = "Moderate or heavy rain shower"
            
        case 1246: weatherConditionImage.image = UIImage(systemName: "cloud.heavyrain.fill")
            conditionLabel.text = "Torrential rain shower"
            
        case 1249: weatherConditionImage.image = UIImage(systemName: "cloud.sleet")
            conditionLabel.text = "Light Sleet Showers"
            
        case 1252: weatherConditionImage.image = UIImage(systemName: "cloud.sleet.fill")
            conditionLabel.text = "Moderate or heavy sleet showers"
            
        case 1255: weatherConditionImage.image = UIImage(systemName: "cloud.snow")
            conditionLabel.text = "Light Snow Showers"
            
        case 1258: weatherConditionImage.image = UIImage(systemName: "cloud.snow.fill")
            conditionLabel.text = "Moderate or heavy snow showers"
            
        case 1261: weatherConditionImage.image = UIImage(systemName: "cloud.hail")
            conditionLabel.text = "Light showers of ice pellets"
            
        case 1264: weatherConditionImage.image = UIImage(systemName: "cloud.hail.fill")
            conditionLabel.text = "Moderate or heavy showers of ice pellets"
            
        case 1273: weatherConditionImage.image = UIImage(systemName: "cloud.bolt.rain")
            conditionLabel.text = "Patchy light rain with thunder"
            
        case 1276: weatherConditionImage.image = UIImage(systemName: "cloud.bolt.rain.fill")
            conditionLabel.text = "Light Snow Showers"
            
        case 1279: weatherConditionImage.image = UIImage(systemName: "cloud.bolt.rain.circle")
            conditionLabel.text = "Patchy light snow with thunder"
            
        case 1282: weatherConditionImage.image = UIImage(systemName: "cloud.bolt.rain.circle.fill")
            conditionLabel.text = "Moderate or heavy snow with thunder"
            
        default: weatherConditionImage.image = UIImage(systemName: "sparkles")
            
        }
    }
    
    //Get current location
    private func getLocation(latitude: Double, longitude: Double){
        currentLongitude = longitude
        currentLatitude = latitude
    }
    
    //Structs for handling Data
    struct WeatherResponse: Decodable{
        let location: Location
        let current: Weather
    }
    
    struct Location: Decodable {
        let name: String
    }
    
    struct Weather: Decodable {
        let temp_c: Float
        let temp_f: Float
        let condition: WeatherCondition
    }
    
    struct WeatherCondition: Decodable {
        let text: String
        let code: Int
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Got Location")
        if let location = locations.last{
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            print("LatLng: (\(latitude),\(longitude))")
            getLocation(latitude: latitude,longitude: longitude);
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

//Location Manager Delegate class
class MyLocationManagerDelegate: NSObject,CLLocationManagerDelegate{
    
}

