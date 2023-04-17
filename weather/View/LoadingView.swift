//
//  Final Project - By Pruthvi And Sakshi
//  WeatherApp
//
//  Advance IOS
//

import UIKit

extension CAGradientLayer {

    static var loading: CAGradientLayer {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.clear.cgColor,
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.clear.cgColor
        ]
        layer.locations = [0, 0.48, 0.52, 1]
        layer.startPoint = .init(x: 0.0, y: 0.5)
        layer.endPoint = .init(x: 1.0, y: 0.5)
        return layer
    }
}

class LoadingView: UIView {

    private let gradientLayer = CAGradientLayer.loading
    private let animation = CABasicAnimation(keyPath: "transform.translation.x")

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        animation.repeatCount = Float.infinity
        animation.duration = 1.7
        layer.mask = gradientLayer
        NotificationCenter.default.addObserver(self, selector: #selector(addAnimation), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        animation.fromValue = -self.frame.width
        animation.toValue = self.frame.width
        gradientLayer.frame = bounds
        addAnimation()
    }

    @objc private func addAnimation() {
        gradientLayer.add(animation, forKey: "Null")
    }

}

