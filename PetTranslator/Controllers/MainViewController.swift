//
//  MainViewController.swift
//  PetTranslator
//
//  Created by a.drobot on 14.02.2025.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundGradient()
        setupHeaderBlock()
        for family in UIFont.familyNames {
            print("Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print(" - \(name)")
            }
        }
    }
    
    private func setupBackgroundGradient() {
        let gradientLayer = CAGradientLayer()
        let startColor = UIColor(red: 243/255, green: 245/255, blue: 246/255, alpha: 1).cgColor
        let endColor = UIColor(red: 201/255, green: 255/255, blue: 224/255, alpha: 1).cgColor
        
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [startColor, endColor]
        
        view.layer.addSublayer(gradientLayer)
    }
    
    private func setupHeaderBlock() {
        let appNameLabel = UILabel()
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        appNameLabel.text = "Translator"
        appNameLabel.textAlignment = .center
        appNameLabel.font = .systemFont(ofSize: 32, weight: UIFont.Weight(rawValue: 300))
        
        view.addSubview(appNameLabel)
        
        NSLayoutConstraint.activate([
            appNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            appNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            appNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            
        ])
    }
}
