//
//  Final Project - By Pruthvi And Sakshi
//  WeatherApp
//
//  Advance IOS
//

import Foundation


extension Date {

    func isBetween(with sunrise: Date, with sunset: Date) -> Bool {

        if self > sunrise && self < sunset {
            return false
        }
        return true
    }
}


