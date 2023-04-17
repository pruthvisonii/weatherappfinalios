//
//  Final Project - By Pruthvi And Sakshi
//  WeatherApp
//
//  Advance IOS
//

import UIKit
import CoreLocation

enum NetworkError: Error {
    case invalidURL
}

extension String {
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
}

class WeatherManager {

    //current weather
    private let currentWeatherURL = "https://api.openweathermap.org/data/2.5/weather?&units=metric"

    //forecasted weather of today and next 5 days every 3h
    private let weatherForecastURL = "https://api.openweathermap.org/data/2.5/forecast?&units=metric"

    private let id = Secrets.openWeatherAppID       //replace with OpenWeather API keyclass

    func requestCurrentCityURL(city: String, completion: @escaping (Result<CurrentModel, Error>) -> Void) {
        let currentURLString = "\(currentWeatherURL)&appid=\(id)&q=\(city.trimmingCharacters(in: .whitespaces).stringByAddingPercentEncodingForRFC3986()!)"
        print(currentURLString)
        perform(urlString: currentURLString, transform: parseJSONCurrent, completion: completion)
    }

    func requestForecastCityURL(city: String, completion: @escaping (Result<[ForecastModel], Error>) -> Void) {
        let forecastURLString = "\(weatherForecastURL)&appid=\(id)&q=\(city.trimmingCharacters(in: .whitespaces).stringByAddingPercentEncodingForRFC3986()!)"
        perform(urlString: forecastURLString, transform: parseJSONForecast, completion: completion)
        print(forecastURLString)
    }

    func requestCurrentGeoURL(with coordinates: CLLocationCoordinate2D, completion: @escaping (Result<CurrentModel, Error>) -> Void) {
        let currentURLString = "\(currentWeatherURL)&appid=\(id)&lat=\(coordinates.latitude)&lon=\(coordinates.longitude)"
        perform(urlString: currentURLString, transform: parseJSONCurrent, completion: completion)
    }

    func requestForecastGeoURL(with coordinates: CLLocationCoordinate2D, completion: @escaping (Result<[ForecastModel], Error>) -> Void) {
        let forecastURLString = "\(weatherForecastURL)&appid=\(id)&lat=\(coordinates.latitude)&lon=\(coordinates.longitude)"
        perform(urlString: forecastURLString, transform: parseJSONForecast, completion: completion)
    }

    //Generics: types not defined
    private func perform<T>(urlString: String,
                    transform: @escaping (Data) throws -> T,      //T: Current or Forecast Model
                    completion: @escaping (Result<T, Error>) -> Void  //Result T > .success > Current or Forecast Model
    ) {
        performNetworkRequest(with: urlString) { result in

            switch result {
            case .success(let data):        // Network request successful:
                do {
                    let entity = try transform(data)  //transform calls parseJSONCurrent or parseJSONForecast
                    completion(.success(entity))      //if parsing success > data passed on
                } catch {
                    completion(.failure(error))     //if parsing failure > throws error
                    print("Error parsing JSON: \(error)")
                }
            case .failure(let error):       //Network request not succesful
                completion(.failure(error))
            }
        }
    }

    private func performNetworkRequest(with urlString: String, completion: @escaping (Result<Data, Error>) -> Void ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        let task = URLSession.shared
            .dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                } else if let weatherData = data {
                    completion(.success(weatherData))
                }
            }
        task.resume()
    }

    private func parseJSONCurrent(with encodedData: Data) throws -> CurrentModel {
        let decoder = JSONDecoder()
        let decodedWeather = try decoder.decode(OpenWeatherAPI.Current.self, from: encodedData)
        let decodedTemp = decodedWeather.main.temp
        let decodedName = decodedWeather.name
        let decodedCondition = decodedWeather.weather[0].id
        let sunrise = Date(timeIntervalSince1970: decodedWeather.sys.sunrise)
        let sunset = Date(timeIntervalSince1970: decodedWeather.sys.sunset)
        let answer = Date().isBetween(with: sunrise, with: sunset)
        let decodedMinTemp = decodedWeather.main.temp_min
        let decodedMaxTemp = decodedWeather.main.temp_max

        return CurrentModel(currentTemp: decodedTemp, minTemp: decodedMinTemp, maxTemp: decodedMaxTemp, condition: decodedCondition, name: decodedName, isNight: answer, isForecast: false)
    }

    private func parseJSONForecast(with encodedData: Data) throws -> [ForecastModel] {
        let decoder = JSONDecoder()
        let decodedForecast = try decoder.decode(OpenWeatherAPI.Forecast.self, from: encodedData)
        //only get temp, weather id and date of filtered list

        let forecastModels: [ForecastModel] = decodedForecast.list.compactMap { item in
            let forecastTemp = item.main.temp
            let forecastCondition = item.weather[0].id
            let foracastDay = item.dt

            let today = Calendar.current.component(.weekday, from: Date())
            let foracastDate = Date(timeIntervalSince1970: Double(item.dt))
            let forecastWeekday = Calendar.current.component(.weekday, from: foracastDate)

            if forecastWeekday != today {
                return ForecastModel(currentTemp: forecastTemp, condition: forecastCondition, day: foracastDay, isForecast: true, isNight: false)
            } else {
                return nil
            }
        }
        return forecastModels
    }
}
