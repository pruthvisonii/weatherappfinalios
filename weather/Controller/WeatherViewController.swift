//
//  Final Project - By Pruthvi And Sakshi
//  WeatherApp
//
//  Advance IOS
//
import UIKit


class WeatherViewController: UIViewController {

    @IBOutlet var cityTextField: UITextField!
    @IBOutlet var cityTextLabel: UILabel!               //back View
    @IBOutlet var tempTextLabel: UILabel!
    @IBOutlet var weatherImageView: UIImageView!
    @IBOutlet var forecastViewBackground: UIView!                 //back View
    @IBOutlet var forecastAnimationView: LoadingView!         //front View
    @IBOutlet var animationLabel: UILabel!
    @IBOutlet var errorImageview: UIImageView!

    private let forecastRowView1 = ForecastRowView()
    private let forecastRowView2 = ForecastRowView()
    private let forecastRowView3 = ForecastRowView()
    private let forecastRowView4 = ForecastRowView()
    private let forecastRowView5 = ForecastRowView()

    @IBOutlet var forecastStackView: UIStackView!

    @IBOutlet var searchButton: UIButton!
    @IBOutlet var locationUIButton: UIButton!

    private var weatherViewModel = WeatherViewModel()
    private let cornerRadius = CGFloat(10)
    private let animationText = "Loading ..."

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)

        addForecastStackView()

        searchButton?.isUserInteractionEnabled = false
        searchButton?.alpha = 0.4

        cityTextField.delegate = self
        weatherViewModel.delegate = self

        cityTextField.backgroundColor = .white.withAlphaComponent(0.3)
        cityTextField.keyboardType = .asciiCapable
        cityTextField.enablesReturnKeyAutomatically = true

        cityTextLabel.textColor = .white.withAlphaComponent(0.15)
        cityTextLabel.text = animationText

        tempTextLabel.isHidden = true
        weatherImageView.isHidden = true
        errorImageview.isHidden = true
        forecastStackView.isHidden = true

        forecastViewBackground.backgroundColor = .white.withAlphaComponent(0.15)
        forecastViewBackground.layer.cornerRadius = cornerRadius

        forecastAnimationView.layer.cornerRadius = cornerRadius
        forecastAnimationView.backgroundColor = .white.withAlphaComponent(0.45)

        animationLabel.textColor = .white.withAlphaComponent(0.65)
        animationLabel.text = cityTextLabel.text
        animationLabel.font = cityTextLabel.font
        animationLabel.textAlignment = cityTextLabel.textAlignment

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTapScreen))
        view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    private func addForecastStackView() {
        forecastStackView.addArrangedSubview(forecastRowView1)
        forecastStackView.addArrangedSubview(forecastRowView2)
        forecastStackView.addArrangedSubview(forecastRowView3)
        forecastStackView.addArrangedSubview(forecastRowView4)
        forecastStackView.addArrangedSubview(forecastRowView5)

        forecastRowView1.constrainRelative(to: forecastRowView2)
        forecastRowView1.constrainRelative(to: forecastRowView3)
        forecastRowView1.constrainRelative(to: forecastRowView4)
        forecastRowView1.constrainRelative(to: forecastRowView5)
    }

    @objc func didBecomeActive() {
        print("VC: \(#function)")
        weatherViewModel.didBecomeActive()
    }

    @objc func didTapScreen() {
        cityTextField.endEditing(true)
    }

    private func prepareViewForAnimation() {
        tempTextLabel.isHidden = true
        errorImageview.isHidden = true
        weatherImageView.isHidden = true
        forecastStackView.isHidden = true
        animationLabel.isHidden = false
        forecastAnimationView.isHidden = false
        cityTextLabel.text = animationText
        cityTextLabel.textColor = .white.withAlphaComponent(0.15)
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        self.view.frame.origin.y = 40 - keyboardSize.height
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }

    @IBAction func didTapLocation(_ sender: UIButton) {
        prepareViewForAnimation()
        weatherViewModel.didTapLocation()
        sender.alpha = 0.2
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sender.alpha = 1.0
            self.cityTextField.endEditing(true)
        }
    }

    @IBAction func didTapSearch(_ sender: UIButton) {
        print(#function)
        prepareViewForAnimation()
        handleTextField()
    }

    private func handleTextField() {
        if cityTextField.text?.isEmpty == false {
            weatherViewModel.didEnterCity(with: cityTextField.text!)
            searchButton?.isUserInteractionEnabled = false
            searchButton?.alpha = 0.3
            cityTextField.text = ""
            cityTextField.endEditing(true)
        }
    }
}

//MARK: - Extension WeatherViewController: UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        prepareViewForAnimation()
        handleTextField()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if !text.isEmpty {
            searchButton.isUserInteractionEnabled = true
            searchButton.alpha = 1
        } else {
            searchButton.isUserInteractionEnabled = false
            searchButton.alpha = 0.3
        }
        return true
    }
}

//MARK: - Extension WeatherViewController: ViewModelDelegate

extension WeatherViewController: ViewModelDelegate {

    func presentAuthAlert(with title: String, with message: String, with cancel: UIAlertAction, with action: UIAlertAction) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true)
    }

    func updateCurrentUI(city: String, temperature: String, image: UIImage, forecastImage: UIImage, forecastMinTemp: String, forecastMaxTemp: String) {
        DispatchQueue.main.async {
            self.cityTextLabel.text = city
            self.tempTextLabel.text = temperature
            self.weatherImageView.image = image
            self.errorImageview.isHidden = true

            self.forecastRowView1.configure(day: "Today",
                                            image: forecastImage,
                                            minTemp: forecastMinTemp,
                                            maxTemp: forecastMaxTemp)

            self.cityTextLabel.textColor = .white
            self.tempTextLabel.isHidden = false
            self.weatherImageView.isHidden = false
            self.animationLabel.isHidden = true
        }
    }

    func updateForecastUI(with forecastUIModels: [ForecastUIModel]) {
        DispatchQueue.main.async {
            self.forecastRowView2.configure(day: forecastUIModels[1].forecastDay,
                                            image: forecastUIModels[1].forecastImage,
                                            minTemp: forecastUIModels[1].forecastTempMin,
                                            maxTemp: forecastUIModels[1].forecastTempMax)

            self.forecastRowView3.configure(day: forecastUIModels[2].forecastDay,
                                            image: forecastUIModels[2].forecastImage,
                                            minTemp: forecastUIModels[2].forecastTempMin,
                                            maxTemp: forecastUIModels[2].forecastTempMax)

            self.forecastRowView4.configure(day: forecastUIModels[3].forecastDay,
                                            image: forecastUIModels[3].forecastImage,
                                            minTemp: forecastUIModels[3].forecastTempMin,
                                            maxTemp: forecastUIModels[3].forecastTempMax)

            self.forecastRowView5.configure(day: forecastUIModels[4].forecastDay,
                                            image: forecastUIModels[4].forecastImage,
                                            minTemp: forecastUIModels[4].forecastTempMin,
                                            maxTemp: forecastUIModels[4].forecastTempMax)

            self.forecastStackView.isHidden = false
            self.forecastAnimationView.isHidden = true
        }
    }

    func didCatchError(errorMsg: String, errorImage: UIImage) {
        DispatchQueue.main.async {
            self.cityTextLabel.text = errorMsg
            self.errorImageview.image = errorImage

            self.tempTextLabel.isHidden = true
            self.weatherImageView.isHidden = true
            self.forecastStackView.isHidden = true
            self.cityTextLabel.textColor = .white
            self.errorImageview.isHidden = false

            self.forecastAnimationView.isHidden = true
            self.animationLabel.isHidden = true
        }
    }
}
