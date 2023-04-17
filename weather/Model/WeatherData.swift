//
//  Final Project - By Pruthvi And Sakshi
//  WeatherApp
//
//  Advance IOS
//
import Foundation

struct OpenWeatherAPI {
    
    struct Current: Decodable {
        let name: String
        let main: Temperature
        let weather: [Weather]
        let sys: Sys
        
        struct Sys: Decodable {
            let sunrise: Double
            let sunset: Double
        }
    }
    
    struct Forecast: Decodable {
        let list: [Entry]
        struct Entry: Decodable, DateContaining {
            let dt: Int //Date
            let main: Temperature
            let weather: [Weather]
        }
    }
    
    struct Temperature: Decodable {
        let temp: Double
        let temp_min: Double
        let temp_max: Double
    }
    
    struct Weather: Decodable {
        let id: Int
    }
}

protocol DateContaining {
    var dt: Int { get }
}


