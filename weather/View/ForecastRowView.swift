//
//  Final Project - By Pruthvi And Sakshi
//  WeatherApp
//
//  Advance IOS
//

import UIKit


class ForecastRowView: UIStackView {

    private let label = ForecastLabel()
    private let imageView = UIImageView()
    private let tempMinLabel = ForecastLabel()
    private let tempMaxLabel = ForecastLabel()

    init() {
        super.init(frame: .zero)

        let tempStack = UIStackView()
        let hyphen = ForecastLabel()

        addArrangedSubview(label)
        addArrangedSubview(imageView)
        addArrangedSubview(tempStack)
        tempStack.addArrangedSubview(tempMinLabel)
        tempStack.addArrangedSubview(hyphen)
        tempStack.addArrangedSubview(tempMaxLabel)

        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true

        spacing = 22
        alignment = .center
        hyphen.text = " - "
        tempMinLabel.textAlignment = .right
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        configure(day: "Wednesday", image: UIImage(systemName: "sun.max")!, minTemp: "14*", maxTemp: "22*")
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func constrainRelative(to other: ForecastRowView) {
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: other.label.widthAnchor),
            imageView.widthAnchor.constraint(equalTo: other.imageView.widthAnchor),
            tempMinLabel.widthAnchor.constraint(equalTo: other.tempMinLabel.widthAnchor),
            tempMaxLabel.widthAnchor.constraint(equalTo: other.tempMaxLabel.widthAnchor)
        ])
    }

    func configure(day: String, image: UIImage, minTemp: String, maxTemp: String) {
        label.text = day
        imageView.image = image
        tempMinLabel.text = minTemp
        tempMaxLabel.text = maxTemp
    }
}

private class ForecastLabel: UILabel {

    init() {
        super.init(frame: .zero)
        let forecastFont = UIFont.scriptFont(size: 20, style: .medium)
        self.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: forecastFont)
        self.adjustsFontForContentSizeCategory = true
        self.textColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
