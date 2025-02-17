//
//  TranslatorConnector.swift
//  PetTranslator
//
//  Created by a.drobot on 16.02.2025.
//

class TranslatorConnector {
    func getRandomAnimalResponse() -> String {
        let responses = [
            "What are you doing, human?",
            "I’m hungry, feed me!",
            "Mrrrrr.....",
            "Guf Guf"
        ]
        return responses.randomElement() ?? "..."
    }
}
