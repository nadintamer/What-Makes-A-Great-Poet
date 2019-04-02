import Foundation
import AppKit

public class PoemSpeaker: NSObject, NSSpeechSynthesizerDelegate {
    
    public func play(poem: Poem) {
        let speechSynthesizer = NSSpeechSynthesizer(voice: NSSpeechSynthesizer.VoiceName.init(rawValue: "com.apple.speech.synthesis.voice.Alex"))!
        
        speechSynthesizer.delegate = self
        
        if (poem.poet == "Emily Dickinson") {
            speechSynthesizer.setVoice(NSSpeechSynthesizer.VoiceName.init(rawValue: "com.apple.speech.synthesis.voice.Victoria"))
        }

        for line in poem.lines {
            poem.lineSpoken = false
            speechSynthesizer.startSpeaking(line)
            print(line)
            speechSynthesizer.pauseSpeaking(at: .sentenceBoundary)
    
            while (speechSynthesizer.isSpeaking) {
                
            }
            poem.lineSpoken = true
        }
    }
}
