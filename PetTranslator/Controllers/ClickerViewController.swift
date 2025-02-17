//
//  ClickerViewController.swift
//  PetTranslator
//
//  Created by a.drobot on 17.02.2025.
//

import UIKit

class ClickerViewController: UIViewController {
    
    private let headerLabel = UILabel()
    private let settingsTableView = UITableView()
    
    private let tabBarMenuView = TabBarMenuView()
    
    private let settingsOptions = ["Rate Us", "Share App", "Contact Us", "Restore Purchases", "Privacy Policy", "Terms of Use"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundGradient()
        setupHeaderLabel()
        setupTabBarView()
        setupSettingsTableView()
    }
    
    @objc func translateButtonTapped() {
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
    
    private func setupHeaderLabel() {
        headerLabel.text = "Settings"
        headerLabel.font = UIFont(name: "KonkhmerSleokchher-Regular", size: 32)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupTabBarView() {
        tabBarMenuView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tabBarMenuView)
        
        NSLayoutConstraint.activate([
            tabBarMenuView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            tabBarMenuView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        tabBarMenuView.translateButton.addTarget(self, action: #selector(translateButtonTapped), for: .touchUpInside)
        
        tabBarMenuView.setActiveButton(tabBarMenuView.clickerButton)
    }
    
    private func setupSettingsTableView() {
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        settingsTableView.backgroundColor = .clear
        settingsTableView.separatorStyle = .none

        settingsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(settingsTableView)
        
        NSLayoutConstraint.activate([
            settingsTableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12),
            settingsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            settingsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            settingsTableView.bottomAnchor.constraint(equalTo: tabBarMenuView.topAnchor, constant: -14)
        ])
    }

}

extension ClickerViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        settingsOptions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = settingsOptions[indexPath.section]
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor(red: 214/255, green: 220/255, blue: 255/255, alpha: 1.0)
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let spacer = UIView()
        spacer.backgroundColor = .clear
        return spacer
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        14
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(settingsOptions[indexPath.section]) tapped")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

@available(iOS 17.0, *)
#Preview {
    ClickerViewController()
}
