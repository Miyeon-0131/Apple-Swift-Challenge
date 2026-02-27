import Foundation
import AVFoundation

final class SpeechAssistant {
    nonisolated(unsafe) static let shared = SpeechAssistant()
    private let synthesizer = AVSpeechSynthesizer()

    private init() {}

    func speak(_ text: String) {
        DispatchQueue.main.async {
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
            self.synthesizer.stopSpeaking(at: .immediate)
            self.synthesizer.speak(utterance)
        }
    }
}

extension SpeechAssistant: @unchecked Sendable {}
