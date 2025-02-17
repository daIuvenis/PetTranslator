//
//  ResultViewController.swift
//  PetTranslator
//
//  Created by a.drobot on 16.02.2025.
//
import UIKit

class ResultViewController: UIViewController {
    
    private let headerLabel = UILabel()
    private let resultView = UIView()
    private let selectedPetImageView = UIImageView()
    
    private let translatorConnector = TranslatorConnector()
    
    var selectedPetImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundGradient()
        setupHeader()
        setupResultView()
        setupSelectedImage()
        setupArrow()
    }
    
    @objc func xButtonTapped() {
        dismiss(animated: true)
    }
    
    private func setupBackgroundGradient() {
        let gradientLayer = CAGradientLayer()
        let startColor = UIColor(red: 243/255, green: 245/255, blue: 246/255, alpha: 1).cgColor
        let endColor = UIColor(red: 201/255, green: 255/255, blue: 224/255, alpha: 1).cgColor
        
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [startColor, endColor]
        
        view.layer.addSublayer(gradientLayer)
    }
    
    private func setupHeader() {
        let xButton = UIButton()
        xButton.addTarget(self, action: #selector(xButtonTapped), for: .touchUpInside)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "xmark.circle")
        config.baseForegroundColor = .gray
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 25)
        
        xButton.configuration = config
        xButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(xButton)
        
        headerLabel.text = "Result"
        headerLabel.textColor = .black
        headerLabel.font = UIFont(name: "KonkhmerSleokchher-Regular", size: 32)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            xButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            xButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 17),
            
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: xButton.centerYAnchor),
        ])
    }
    
    private func setupResultView() {
        resultView.backgroundColor = UIColor(red: 214/255, green: 220/255, blue: 255/255, alpha: 1.0)
        resultView.layer.cornerRadius = 16
        resultView.layer.shadowColor = UIColor.black.cgColor
        resultView.layer.shadowOpacity = 0.25
        resultView.layer.shadowRadius = 8
        resultView.layer.shadowOffset = CGSize(width: 0, height: 4)
        resultView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(resultView)
        
        let resultText = UILabel()
        resultText.text = translatorConnector.getRandomAnimalResponse()
        resultText.font = UIFont(name: "KonkhmerSleokchher-Regular", size: 12)
        resultText.numberOfLines = 0
        resultText.textColor = .black
        resultText.textAlignment = .center
        resultText.translatesAutoresizingMaskIntoConstraints = false
        
        resultView.addSubview(resultText)
        
        NSLayoutConstraint.activate([
            resultView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            resultView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            resultView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 91),
            resultView.heightAnchor.constraint(equalToConstant: 142),
            
            resultText.leadingAnchor.constraint(equalTo: resultView.leadingAnchor, constant: 8),
            resultText.trailingAnchor.constraint(equalTo: resultView.trailingAnchor, constant: -8),
            resultText.centerYAnchor.constraint(equalTo: resultView.centerYAnchor)
        ])
    }
    
    private func setupSelectedImage() {
        selectedPetImageView.image = selectedPetImage
        selectedPetImageView.frame = view.bounds
        selectedPetImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(selectedPetImageView)
     
        NSLayoutConstraint.activate([
            selectedPetImageView.topAnchor.constraint(equalTo: resultView.bottomAnchor, constant: 125),
            selectedPetImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            selectedPetImageView.heightAnchor.constraint(equalToConstant: 184),
            selectedPetImageView.widthAnchor.constraint(equalToConstant: 184),
        ])
    }
    
    private func setupArrow() {
        let arrowImageView = UIImageView(image: UIImage(named: "arrow"))
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            arrowImageView.topAnchor.constraint(equalTo: resultView.bottomAnchor, constant: -10),
            arrowImageView.trailingAnchor.constraint(equalTo: resultView.trailingAnchor, constant: -16)
        ])
    }
    
}

@available(iOS 17.0, *)
#Preview {
    ResultViewController()
}
