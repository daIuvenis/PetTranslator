//
//  MainViewController.swift
//  PetTranslator
//
//  Created by a.drobot on 14.02.2025.
//

import UIKit
import AVFAudio

final class MainViewController: UIViewController {
    
    private let appNameLabel = UILabel()
    private let translateFromLabel = UILabel()
    private let translateToLabel = UILabel()
    private let languageStackView = UIStackView()
    private let petTypeView = UIView()
    private let selectedPetImageView = UIImageView()
    private let microphoneButtonView = UIView()
    private let microphoneImageView = UIImageView()
    private let microphoneLabel = UILabel()
    private let barLayer = CAShapeLayer()
    private var displayLink: CADisplayLink?
    
    private var audioRecorder: AVAudioRecorder?
    private var audioSession = AVAudioSession.sharedInstance()
    private var isRecording = false
    private var state: SwitchStateLanguage = .human {
        didSet { updateLanguageUI() }
    }
    private var selectedPetView: UIView?
    
    private let tabBarMenuView = TabBarMenuView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundGradient()
        setupHeaderBlock()
        setupLanguageSwitchUI()
        setupMicrophoneButtonView()
        setupPetTypeView()
        setupSelectedPetImageView()
        setupMicrophoneButtonView()
        setupBarform()
        setupTabBarView()
    }
    
    @objc func switchLanguageButtonTapped() {
        state = (state == .human) ? .pet : .human
    }
    
    @objc func petTypeViewTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view else { return }

        selectedPetView?.alpha = 0.5
        tappedView.alpha = 1.0
        selectedPetView = tappedView
        
        if selectedPetView?.backgroundColor == UIColor(red: 209/255, green: 231/255, blue: 252/255, alpha: 1.0) {
            selectedPetImageView.image = UIImage(named: "catImage")
        } else if selectedPetView?.backgroundColor == UIColor(red: 236/255, green: 251/255, blue: 199/255, alpha: 1.0) {
            selectedPetImageView.image = UIImage(named: "dogImage")
        }
        
    }
    
    @objc func microphoneButtonTapped() {
        checkMicrophonePermission()
    }
    
    @objc private func updateBarform() {
        guard let recorder = audioRecorder else { return }
        recorder.updateMeters()
        
        let power = max(0, CGFloat(recorder.averagePower(forChannel: 0)) + 50) / 50
        drawBars(amplitude: power)
    }
    
    @objc func clickerButtonTapped() {
        let clickerVC = ClickerViewController()
        clickerVC.modalPresentationStyle = .fullScreen
        
        present(clickerVC, animated: true)
    }
    
    private func setupMicrophoneButtonView() {
        microphoneButtonView.backgroundColor = .white
        microphoneButtonView.layer.cornerRadius = 16
        microphoneButtonView.layer.shadowColor = UIColor.black.cgColor
        microphoneButtonView.layer.shadowOpacity = 0.2
        microphoneButtonView.layer.shadowOffset = CGSize(width: 0, height: 4)
        microphoneButtonView.layer.shadowRadius = 8
        microphoneButtonView.translatesAutoresizingMaskIntoConstraints = false
        
        microphoneImageView.image = UIImage(systemName: "microphone")
        microphoneImageView.tintColor = .black
        microphoneImageView.contentMode = .scaleAspectFit
        microphoneImageView.translatesAutoresizingMaskIntoConstraints = false
        microphoneImageView.isUserInteractionEnabled = true
        
        microphoneLabel.text = "Start Speak"
        microphoneLabel.font = UIFont(name: "KonkhmerSleokchher-Regular", size: 16)
        microphoneLabel.textColor = .black
        microphoneLabel.translatesAutoresizingMaskIntoConstraints = false
        
        microphoneButtonView.addSubview(microphoneImageView)
        microphoneButtonView.addSubview(microphoneLabel)
        
        view.addSubview(microphoneButtonView)
        
        NSLayoutConstraint.activate([
            microphoneButtonView.topAnchor.constraint(equalTo: languageStackView.bottomAnchor, constant: 58),
            microphoneButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 35),
            microphoneButtonView.heightAnchor.constraint(equalToConstant: 178),
            microphoneButtonView.widthAnchor.constraint(equalToConstant: 176),
            
            microphoneImageView.centerXAnchor.constraint(equalTo: microphoneButtonView.centerXAnchor),
            microphoneImageView.centerYAnchor.constraint(equalTo: microphoneButtonView.centerYAnchor, constant: -12),
            microphoneImageView.widthAnchor.constraint(equalToConstant: 70),
            microphoneImageView.heightAnchor.constraint(equalToConstant: 70),
            
            microphoneLabel.topAnchor.constraint(equalTo: microphoneImageView.bottomAnchor, constant: 8),
            microphoneLabel.centerXAnchor.constraint(equalTo: microphoneButtonView.centerXAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(microphoneButtonTapped))
        microphoneButtonView.addGestureRecognizer(tapGesture)
    }
    
    private func setupBarform() {
        barLayer.strokeColor = UIColor.systemBlue.cgColor
        barLayer.lineWidth = 2.0
        barLayer.fillColor = UIColor.systemBlue.cgColor
        microphoneButtonView.layer.insertSublayer(barLayer, at: 0)
    }
    
    private func checkMicrophonePermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            toggleRecording()
        case .denied:
            showAccessDeniedAlert()
        case .undetermined:
            requestMicrophoneAccess()
        @unknown default:
            break
        }
    }
    
    private func requestMicrophoneAccess() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if !granted {
                    self.showAccessDeniedAlert()
                }
            }
        }
    }
    
    private func showAccessDeniedAlert() {
        let alert = UIAlertController(
            title: "Enable Microphone Access",
            message: "Please allow access to your mircophone to use the app’s features",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsURL)
        })
        
        present(alert, animated: true)
    }
    
    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func startRecording() {
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try audioSession.setActive(true)
            
            let temporaryURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("translateFromAudio.m4a")
            audioRecorder = try AVAudioRecorder(url: temporaryURL, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            microphoneImageView.isHidden = true
            barLayer.isHidden = false
            microphoneLabel.text = "Reccording..."
            isRecording = true
            
            startBarformAnimation()
            
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }
        
    private func stopRecording() {
        audioRecorder?.stop()
        microphoneImageView.isHidden = false
        microphoneLabel.text = "Start Speak"
        barLayer.isHidden = true
        isRecording = false
        stopBarformAnimation()
        
        let resultViewController = ResultViewController()
        resultViewController.selectedPetImage = selectedPetImageView.image
        resultViewController.modalPresentationStyle = .fullScreen
        
        present(resultViewController, animated: true)
    }
    
    private func startBarformAnimation() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateBarform))
        displayLink?.add(to: .main, forMode: .common)
    }
        
    private func stopBarformAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    private func drawBars(amplitude: CGFloat) {
        let barCount = 20
        let spacing: CGFloat = 10
        let totalSpacing = CGFloat(barCount - 1) * spacing
        let barWidth = (microphoneButtonView.bounds.width - totalSpacing) / CGFloat(barCount)
        
        let maxHeight = microphoneButtonView.bounds.height / 2
        let centerY = microphoneButtonView.bounds.midY
        
        let path = UIBezierPath()
        
        for i in 0..<barCount {
            let x = CGFloat(i) * (barWidth + spacing)
            let barHeight = maxHeight * (0.2 + CGFloat.random(in: 0.5...1.0) * amplitude)
            
            let barRect = CGRect(x: x, y: centerY - barHeight / 2, width: barWidth, height: barHeight)
            path.append(UIBezierPath(roundedRect: barRect, cornerRadius: barWidth / 3))
        }
        
        barLayer.path = path.cgPath
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
        appNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        appNameLabel.text = "Translator"
        appNameLabel.textAlignment = .center
        appNameLabel.font = UIFont(name: "KonkhmerSleokchher-Regular", size: 32)
        
        view.addSubview(appNameLabel)
        
        NSLayoutConstraint.activate([
            appNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            appNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            appNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            
        ])
    }
    
    private func setupLanguageSwitchUI() {
        setupFontSize(with: 16, for: translateFromLabel)
        translateFromLabel.translatesAutoresizingMaskIntoConstraints = false
        languageStackView.addArrangedSubview(translateFromLabel)
        
        let switchLanguageButton = UIButton()
        switchLanguageButton.addTarget(self, action: #selector(switchLanguageButtonTapped), for: .touchUpInside)
        switchLanguageButton.translatesAutoresizingMaskIntoConstraints = false
        switchLanguageButton.setImage(UIImage(systemName: "arrow.left.arrow.right"), for: .normal)
        switchLanguageButton.tintColor = .label
        
        languageStackView.addArrangedSubview(switchLanguageButton)
        
        setupFontSize(with: 16, for: translateToLabel)
        translateToLabel.translatesAutoresizingMaskIntoConstraints = false
        languageStackView.addArrangedSubview(translateToLabel)
        
        languageStackView.translatesAutoresizingMaskIntoConstraints = false
        languageStackView.axis = .horizontal
        languageStackView.distribution = .equalSpacing
        
        view.addSubview(languageStackView)
        
        NSLayoutConstraint.activate([
            switchLanguageButton.heightAnchor.constraint(equalToConstant: 22),
            switchLanguageButton.widthAnchor.constraint(equalToConstant: 22),
            
            translateFromLabel.widthAnchor.constraint(equalToConstant: 135),
            
            translateToLabel.widthAnchor.constraint(equalToConstant: 135),
            
            languageStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            languageStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            languageStackView.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 12),
            languageStackView.heightAnchor.constraint(equalToConstant: 61)
        ])
        
        updateLanguageUI()
    }
    
    private func updateLanguageUI() {
        translateFromLabel.text = state.fromText
        translateToLabel.text = state.toText
    }
    
    private func setupFontSize(with size: Int, for label: UILabel) {
        label.font = UIFont(name: "KonkhmerSleokchher-Regular", size: CGFloat(size))
        label.textAlignment = .center
    }
    
    private func setupPetTypeView() {
        petTypeView.backgroundColor = .white
        petTypeView.layer.cornerRadius = 16
        petTypeView.layer.shadowColor = UIColor.black.cgColor
        petTypeView.layer.shadowOpacity = 0.2
        petTypeView.layer.shadowOffset = CGSize(width: 0, height: 4)
        petTypeView.layer.shadowRadius = 8
        petTypeView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(petTypeView)
        
        let catView = UIView()
        applyViewStyle(for: catView, with: "catImage")
        catView.backgroundColor = UIColor(red: 209/255, green: 231/255, blue: 252/255, alpha: 1.0)
        
        let dogView = UIView()
        applyViewStyle(for: dogView, with: "dogImage")
        dogView.backgroundColor = UIColor(red: 236/255, green: 251/255, blue: 199/255, alpha: 1.0)
        
        let petStackView = UIStackView()
        petStackView.axis = .vertical
        petStackView.spacing = 12
        petStackView.distribution = .fillEqually
        petStackView.translatesAutoresizingMaskIntoConstraints = false
        
        petStackView.addArrangedSubview(catView)
        petStackView.addArrangedSubview(dogView)
        
        petTypeView.addSubview(petStackView)
        
        NSLayoutConstraint.activate([
            petTypeView.leadingAnchor.constraint(equalTo: microphoneButtonView.trailingAnchor, constant: 35),
            petTypeView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -35),
            petTypeView.topAnchor.constraint(equalTo: languageStackView.bottomAnchor, constant: 58),
            petTypeView.heightAnchor.constraint(equalToConstant: 178),
            
            petStackView.leadingAnchor.constraint(equalTo: petTypeView.leadingAnchor, constant: 18),
            petStackView.trailingAnchor.constraint(equalTo: petTypeView.trailingAnchor, constant: -18),
            petStackView.topAnchor.constraint(equalTo: petTypeView.topAnchor, constant: 12),
            petStackView.bottomAnchor.constraint(equalTo: petTypeView.bottomAnchor, constant: -12)
        ])
    }
    
    private func applyViewStyle(for view: UIView, with image: String) {
        view.layer.cornerRadius = 8
        view.isUserInteractionEnabled = true
        view.alpha = 0.5
        
        let petImageView = UIImageView(image: UIImage(named: image))
        petImageView.contentMode = .scaleAspectFit
        petImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(petImageView)
        
        NSLayoutConstraint.activate([
            petImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            petImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            petImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            petImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(petTypeViewTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupSelectedPetImageView() {
        selectedPetImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(selectedPetImageView)
        
        NSLayoutConstraint.activate([
            selectedPetImageView.topAnchor.constraint(equalTo: microphoneButtonView.bottomAnchor, constant: 51),
            selectedPetImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            selectedPetImageView.heightAnchor.constraint(equalToConstant: 184),
            selectedPetImageView.widthAnchor.constraint(equalToConstant: 184)
        ])
    }
    
    private func setupTabBarView() {
        tabBarMenuView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBarMenuView)
        
        NSLayoutConstraint.activate([
            tabBarMenuView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            tabBarMenuView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        tabBarMenuView.clickerButton.addTarget(self, action: #selector(clickerButtonTapped), for: .touchUpInside)
        
        tabBarMenuView.setActiveButton(tabBarMenuView.translateButton)
    }

}

enum SwitchStateLanguage {
    case human
    case pet
    
    var fromText: String {
        switch self {
        case .human: return "HUMAN"
        case .pet: return "PET"
        }
    }
    
    var toText: String {
        switch self {
        case .human: return "PET"
        case .pet: return "HUMAN"
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    MainViewController()
}
