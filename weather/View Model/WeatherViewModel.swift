//
//  Final Project - By Pruthvi And Sakshi
//  WeatherApp
//
//  Advance IOS
//

import UIKit
import CoreLocation

protocol ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable
}

protocol ViewModelDelegate: AnyObject {
    func updateCurrentUI(city: String, temperature: String, image: UIImage, forecastImage: UIImage, forecastMinTemp: String, forecastMaxTemp: String)
    func presentAuthAlert(with title: String, with message: String, with cancel: UIAlertAction, with action: UIAlertAction)
    func updateForecastUI(with forecastUIModels: [ForecastUIModel])
    func didCatchError(errorMsg: String, errorImage: UIImage)
}

class WeatherViewModel: NSObject {

    private var locationManager = CLLocationManager()
    weak var delegate: ViewModelDelegate?
    private let weatherManager = WeatherManager()
    private var timer: Timer?
    private let defaults = UserDefaults.standard
    private let cities = ["Honolulu", "Hobart", "Pattani", "Manaus", "Stavanger", "Taipei", "Dhaka"]

    private var networkRequestCheckCoordinates: CLLocationCoordinate2D?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers    //faster response + energy efficient
        let prefSource = try? defaults.getObject(forKey: "PrefSource", castTo: PreferedLocationSource.self)
        switch prefSource {
        case .currentLocation:
            preferedLocationSource = .currentLocation
        case .city(let cityname):
            preferedLocationSource = .city(cityname)
        default:
            preferedLocationSource = .randomCity    //opening app first time
        }
    }

    enum PreferedLocationSource: Equatable, Codable {
        case currentLocation
        case city(String)
        case randomCity
    }

    private var preferedLocationSource: PreferedLocationSource? {
        didSet {
            switch preferedLocationSource {
            case .currentLocation:
                locationManager.startUpdatingLocation()
                getWeatherWithCoordinates()
                try? defaults.setObject(PreferedLocationSource.currentLocation, forKey: "PrefSource")
            case .city(let cityname):
                locationManager.stopUpdatingLocation()
                getWeatherWithCity(with: cityname)
                try? defaults.setObject(PreferedLocationSource.city(cityname), forKey: "PrefSource")
            case .randomCity:
                locationManager.stopUpdatingLocation()
                getWeatherWithRandomCity()
                print("preferedLocationSource .randomCity")
            case nil:
                break
            }
        }
    }

    func getWeatherWithRandomCity() {
        print(#function)
        let randomCity = cities.randomElement()!
        weatherManager.requestCurrentCityURL(city: randomCity) { [self] currentWeather in
            if preferedLocationSource == .randomCity{
                evaluateCurrent(result: currentWeather)
            }
        }
        weatherManager.requestForecastCityURL(city: randomCity) { [self] forecastWeather in
            if preferedLocationSource == .randomCity {
                evaluateForecast(result: forecastWeather)
            }
        }
    }

    func getWeatherWithCity(with cityname: String) {
        print(#function)
        weatherManager.requestCurrentCityURL(city: cityname) { [self] currentWeather in
            if preferedLocationSource == .city(cityname) {
                evaluateCurrent(result: currentWeather)
            }
        }
        weatherManager.requestForecastCityURL(city: cityname) { [self] forecastWeather in
            if preferedLocationSource == .city(cityname) {
                evaluateForecast(result: forecastWeather)
            }
        }
    }

    func getWeatherWithCoordinates() {
        if let location = locationManager.location {
            let coordinates = location.coordinate
            weatherManager.requestCurrentGeoURL(with: coordinates) { [self] currentWeather in
                if self.preferedLocationSource == .currentLocation {
                    evaluateCurrent(result: currentWeather)
                }
            }
            weatherManager.requestForecastGeoURL(with: coordinates) { [self] forecastWeather in
                if self.preferedLocationSource == .currentLocation {
                    evaluateForecast(result: forecastWeather)
                }
            }
        }
    }

    private func handleAuthCase() {
        switch locationManager.authorizationStatus {
        case .authorizedAlways:
            preferedLocationSource = .currentLocation
        case .authorizedWhenInUse:
            preferedLocationSource = .currentLocation
        case .denied:
            print("auth denied")
            createAlert()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            print("auth not determined")
        case .restricted:
            createAlert()
        default:
            print("auth status unknown")
        }
    }

    private func getLocationBasedOnUserPref() {
        print(#function)
        switch preferedLocationSource {
        case .currentLocation:
            print(".currentLocation")
            let auth = locationManager.authorizationStatus
            if auth == .authorizedWhenInUse || auth == .authorizedAlways {
                preferedLocationSource = .currentLocation
            } else if auth == .notDetermined || auth == .denied || auth == .restricted {
                print("change pref source to .randomCity")
                preferedLocationSource = .randomCity
            }
        case .city(let cityname):
            print(".city")
            getWeatherWithCity(with: cityname)
        case .randomCity:
            print(".randomCity")
            getWeatherWithRandomCity()
        case nil:
            break
        }
    }

    func didTapLocation() {
        preferedLocationSource = .currentLocation
        handleAuthCase()
    }

    func didBecomeActive() {
        print("WVM: \(#function)")
        getLocationBasedOnUserPref()
    }

    func didEnterCity(with name: String) {
        preferedLocationSource = .city(name)
    }

    // MARK: check self!
   private func createAlert(){
        let title = "Turn on your location in Weather Pal"
        let message = "Allow location access in settings."
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in  
            print("tapped cancel")
            self.getLocationBasedOnUserPref()
        }
        let settingsAction = UIAlertAction(title: "Settings", style: .cancel) { _ in
            self.preferedLocationSource = .currentLocation
            let settingsUrl = NSURL(string: UIApplication.openSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url as URL)
            }
        }
        delegate?.presentAuthAlert(with: title, with: message, with: cancelAction, with: settingsAction)
    }


    //MARK:  - Evaluate network request > prepare data for UI or error handling

    private func evaluateCurrent(result: (Result<CurrentModel, Error>)) {
        switch result {
        case .success(let currentData):
            didFetchCurrent(with: currentData)
        case .failure(let error):
            print(error)
            didCatchError(error: error as NSError)
        }
    }

    private func evaluateForecast(result: (Result<[ForecastModel], Error>)) {
        switch result {
        case .success(let forecastData):
            didFetchForecast(with: forecastData)
        case .failure(let error):
            print(error)
            didCatchError(error: error as NSError)
        }
    }

    private func didCatchError(error: NSError) {
        let text: String
        let image: UIImage

        if error.code == 4865 {
            text = "City Not Found"
            image = UIImage(systemName: "globe.asia.australia")!
        } else if error.code == -1009 {
            text = "No Internet"
            image = UIImage(systemName: "wifi.slash")!
        } else if error.code == -1001 {
            text = "No Internet"   // "Request Timed Out" > updates also automatic and not always requested
            image = UIImage(systemName: "wifi.slash")!
        } else {
            text = "Error"
            image = UIImage(systemName: "exclamationmark.icloud")!
        }
        delegate?.didCatchError(errorMsg: text, errorImage: image)
    }


    //MARK: - Preparation current and forecast data for VC

     private func didFetchCurrent(with currentWeather: CurrentModel) {
        let city = currentWeather.name
        let currentTemp = currentWeather.tempString
        let image = UIImage(systemName: "\(currentWeather.symbolName(isNight: currentWeather.isNight!, isForecast: currentWeather.isForecast))")!
        let conditionImage = UIImage(systemName: "\(currentWeather.symbolName(isNight: currentWeather.isNight!, isForecast: currentWeather.isForecast)).fill")!
        let minTemp = createTempString(temp: currentWeather.minTemp)
        let maxTemp = createTempString(temp: currentWeather.maxTemp)

        delegate?.updateCurrentUI(city: city, temperature: currentTemp, image: image, forecastImage: conditionImage, forecastMinTemp: minTemp, forecastMaxTemp: maxTemp)
    }

    private func didFetchForecast(with forecastEntries: [ForecastModel]) {
        var x = 1
        let forecastUIModels: [ForecastUIModel] = forecastEntries.compactMap { item in
            let allEntries = filterDay(unfilteredList: forecastEntries, dayNumber: x)
            let day = allEntries.first!.getDayOfWeek()
            let image = UIImage(systemName: allEntries[4].symbolName(isNight: allEntries.first!.isNight!, isForecast: allEntries.first!.isForecast ))
            let tempMin = createTempString(temp: getMinTemp(unfilteredList: allEntries))
            let tempMax = createTempString(temp: getMaxTemp(unfilteredList: allEntries))
            if x <= 3 {
                x += 1
            }
            return ForecastUIModel(forecastDay: day, forecastImage: image!, forecastTempMin: tempMin, forecastTempMax: tempMax)
        }
        delegate?.updateForecastUI(with: forecastUIModels)
    }

    private func filterDay(unfilteredList: [ForecastModel], dayNumber: Int) -> [ForecastModel] {
        var forecastDay =  Date.now
        switch dayNumber {
        case 1:
            forecastDay = Date.now.addingTimeInterval(86400)  //in 1 Day
        case 2:
            forecastDay = Date.now.addingTimeInterval(172800)  //in 2 Days
        case 3:
            forecastDay = Date.now.addingTimeInterval(259200)  //in 3 Days
        case 4:
            forecastDay = Date.now.addingTimeInterval(345600)  //in 4 Days
        default:
            print("Error getting values for current day.")
        }
        let forecastDayComponent = Calendar.current.dateComponents(in: .current, from: forecastDay).day
        let filteredList = unfilteredList.filter { item in
            let date = Date(timeIntervalSince1970: Double(item.day!))
            let dayComponent = Calendar.current.dateComponents(in: .current, from: date).day
            return dayComponent == forecastDayComponent
        }
        return filteredList
    }

    //style depends on temp unit and region setting > if temp unit selected that's less common will show unit (e.g. °C for USA or °F for DE)
    private func createTempString(temp: Double) -> String {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 0
        formatter.numberFormatter.roundingMode = .halfEven
        formatter.unitStyle = .short
        let tempUnit = Measurement(value: temp, unit: UnitTemperature.celsius)
        let temp = formatter.string(from: tempUnit)
        return (temp)
    }

    private func getMinTemp(unfilteredList: [ForecastModel]) -> Double {
        let temp: [Double] = unfilteredList.map { item in
            return item.currentTemp
        }
        return (temp.min()!)
    }

    private func getMaxTemp(unfilteredList: [ForecastModel]) -> Double {
        let temp: [Double] = unfilteredList.map { item in
            return item.currentTemp
        }
        return (temp.max()!)
    }
}

//MARK: - Extension CLLocationManagerDelegate

extension WeatherViewModel: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(#function)
        getWeatherWithCoordinates()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function)
        //didBecomeActive will call func to get weather
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function)
        //handle CLLocationManager error
    }
}


//MARK: - Extension: ObjectSavable UserDefaults

extension UserDefaults: ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey)
        } catch {
            throw ObjectSavableError.unableToEncode
        }
    }

    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable {
        guard let data = data(forKey: forKey) else { throw ObjectSavableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            throw ObjectSavableError.unableToDecode
        }
    }

    enum ObjectSavableError: String, LocalizedError {
        case unableToEncode = "Unable to encode object into data"
        case noValue = "No data object found for the given key"
        case unableToDecode = "Unable to decode object into given type"

        var errorDescription: String? {
            rawValue
        }
    }
}
