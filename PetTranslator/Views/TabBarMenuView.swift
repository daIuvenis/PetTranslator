//
//  TabBarMenuView.swift
//  PetTranslator
//
//  Created by a.drobot on 17.02.2025.
//

import UIKit

class TabBarMenuView: UIView {

    private let buttonStackView = UIStackView()
    
    let translateButton = UIButton()
    let clickerButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtonView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButtonView()
    }
    
    private func setupButtonView() {
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        
        applyButtonStyle(for: translateButton, with: "translate", title: "Translator")
        applyButtonStyle(for: clickerButton, with: "gearshape", title: "Clicker")
        
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 42
        buttonStackView.alignment = .center
        buttonStackView.distribution = .fillEqually
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(translateButton)
        buttonStackView.addArrangedSubview(clickerButton)
        
        NSLayoutConstraint.activate([
            buttonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            buttonStackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            buttonStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            heightAnchor.constraint(equalToConstant: 82)
        ])
        
    }
    
    private func applyButtonStyle(for button: UIButton, with image: String, title: String) {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: image)
        config.baseForegroundColor = .gray
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 18)
        config.title = title
        config.imagePlacement = .top
        
        button.configuration = config
        button.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setActiveButton(_ button: UIButton) {
        translateButton.configuration?.baseForegroundColor = .gray
        clickerButton.configuration?.baseForegroundColor = .gray
        
        button.configuration?.baseForegroundColor = .black
    }
    
}

@available(iOS 17.0, *)
#Preview {
    TabBarMenuView()
}
