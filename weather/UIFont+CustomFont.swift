//
//  Final Project - By Pruthvi And Sakshi
//  WeatherApp
//
//  Advance IOS
//

import UIKit


public enum FontStyle {
    case regular
    case medium
}

extension UIFont {

    static func scriptFont(size: CGFloat, style: FontStyle) -> UIFont {
        switch style {
        case .regular:
            return UIFont(name: "AvenirNext-Regular", size: size)!
        case .medium:
            return UIFont(name: "AvenirNext-Medium", size: size)!
        }
    }
}
