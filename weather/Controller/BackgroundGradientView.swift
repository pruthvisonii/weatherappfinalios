//
//  Final Project - By Pruthvi And Sakshi
//  WeatherApp
//
//  Advance IOS
//
import UIKit

class BackgroundGradientView: UIView {

    private let backgroundGradientLayer = CAGradientLayer()

    private let lightColors = [
        UIColor(red: 72/255, green: 195/255, blue: 166/255, alpha: 1).cgColor,
        UIColor(red: 255/255, green: 220/255, blue: 133/255, alpha: 1).cgColor
    ]

    private let darkColors = [
        UIColor(red: 26/255, green: 188/255, blue: 156/255, alpha: 1).cgColor,
        UIColor(red: 52/255, green: 73/255, blue: 94/255, alpha: 1).cgColor
    ]

    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    //check style preferencs during setup
    private func setup() {
        if traitCollection.userInterfaceStyle == .light {
            backgroundGradientLayer.colors = lightColors
        } else {
            backgroundGradientLayer.colors = darkColors
        }
        backgroundGradientLayer.frame = bounds
        layer.addSublayer(backgroundGradientLayer)
    }

    //clip gradientView to bounds even if view size changes
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundGradientLayer.frame = bounds
    }
    
    //check if style preferencs change while app is running
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle == .light {
            backgroundGradientLayer.colors = lightColors
        } else {
            backgroundGradientLayer.colors = darkColors
        }
    }
}
