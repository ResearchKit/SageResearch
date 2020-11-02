//
//  RSDVoiceBox.swift
//  ResearchUI
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

import AVFoundation
import UIKit

/// A completion handler for the voice box.
public typealias RSDVoiceBoxCompletionHandler = (_ text: String, _ finished: Bool) -> Void

/// `RSDVoiceBox` is used by `RSDStepViewController` to "speak" text strings.
public protocol RSDVoiceBox {
    
    /// Is the voice box currently speaking?
    var isSpeaking: Bool { get }
    
    /// Command the voice box to speak the given text.
    /// - parameters:
    ///     - text: The text to speak.
    ///     - completion: The completion handler to call after the text has finished.
    func speak(text: String, completion: RSDVoiceBoxCompletionHandler?)
    
    /// Command the voice box to stop speaking.
    func stopTalking()
}

/// `RSDSpeechSynthesizer` is a concrete implementation of the `RSDVoiceBox` protocol that uses the
/// `AVSpeechSynthesizer` to synthesize text to sound.
open class RSDSpeechSynthesizer : NSObject, RSDVoiceBox, AVSpeechSynthesizerDelegate {

    /// A singleton instance of the voice box.
    public static var shared: RSDVoiceBox = RSDSpeechSynthesizer()
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    private var _completionHandlers: [String: RSDVoiceBoxCompletionHandler] = [:]
    
    public override init() {
        super.init()
        self.speechSynthesizer.delegate = self
    }
    
    deinit {
        speechSynthesizer.stopSpeaking(at: .immediate)
        speechSynthesizer.delegate = nil
    }
    
    /// Is the voice box currently speaking? The default implementation will return `true` if the
    /// `AVSpeechSynthesizer` is speaking.
    open var isSpeaking: Bool {
        return speechSynthesizer.isSpeaking
    }

    /// Command the voice box to speak the given text. The default implementation will create an
    /// `AVSpeechUtterance` and call the speech synthesizer with the utterance.
    ///
    /// - parameters:
    ///     - text: The text to speak.
    ///     - completion: The completion handler to call after the text has finished.
    open func speak(text: String, completion: RSDVoiceBoxCompletionHandler?) {
        if speechSynthesizer.isSpeaking {
            stopTalking()
        }
        
        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: text)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        _completionHandlers[text] = completion
        
        speechSynthesizer.speak(utterance)
    }

    /// Command the voice box to stop speaking.
    open func stopTalking() {
        speechSynthesizer.stopSpeaking(at: .word)
    }
    
    // MARK: AVSpeechSynthesizerDelegate
    
    /// Called when the text is synthesizer is finished.
    open func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        guard let handler = _completionHandlers[utterance.speechString] else { return }
        _completionHandlers[utterance.speechString] = nil
        handler(utterance.speechString, true)
    }
    
    /// Called when the text is synthesizer is cancelled.
    open func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        guard let handler = _completionHandlers[utterance.speechString] else { return }
        _completionHandlers[utterance.speechString] = nil
        handler(utterance.speechString, false)
    }
}
