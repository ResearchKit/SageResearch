//
//  RSDMotionAudioSessionController.swift
//  ResearchMotion
//
//  Copyright © 2019 Sage Bionetworks. All rights reserved.
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

import Foundation
import AVFoundation

/// The audio session controller to use when recording motion sensor data in the background with the phone
/// screen locked.
///
/// - note: Using this audio session controller includes playing an audio file in the background in order to
/// keep the app responsive to step transitions and voice commands. Without the audio playing in the background
/// or the use of GPS, the app will stop responding to timing events.
public final class RSDMotionAudioSessionController : NSObject, RSDAudioSessionController {
    
    public override init() {
        super.init()
        
        // Load the audio file.
        do {
            let bundle = Bundle(for: RSDMotionAudioSessionController.self)
            let url = bundle.url(forResource: "Silence", withExtension: "wav")!
            self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            self.audioPlayer.numberOfLoops = -1
            self.audioPlayer.prepareToPlay()
        } catch let error {
            debugPrint("Failed to open audio file. \(error)")
        }
    }
    
    /// The audio session is a shared pointer to the current audio session (if running). This is used to
    /// allow background audio. Background audio is required in order for an active step to play sound
    /// such as voice commands to a participant who make not be looking at their screen.
    ///
    /// For example, a "Walk and Balance" task that measures gait and balance by having the participant
    /// walk back and forth followed by having them turn in a circle would require turning on background
    /// audio in order to play spoken instructions even if the screen is locked before putting the phone
    /// in the participant's pocket.
    ///
    /// - note: The application settings will need to include setting capabilities appropriate for
    /// background audio if this feature is used.
    ///
    public private(set) var audioSession: AVAudioSession?
    
    /// The audio player that plays the background sound used to keep the motion sensors active. This is a
    /// work-around to allow the task to continue running in the background without requiring GPS by instead
    /// playing an audio file of silence.
    ///
    /// - note: As of this writing, speech-to-text using the `AVSpeechSynthesizer` will *not* run in the
    /// background after 5 seconds and turning on background audio using `AVAudioSession` is not enough to
    /// keep any timers running. syoung 05/21/2019
    ///
    public private(set) var audioPlayer: AVAudioPlayer!
    
    /// Start the background audio session if needed. This will look to see if `audioSession` is already started
    /// and if not, will start a new session.
    public func startAudioSessionIfNeeded() {
        guard audioSession == nil else { return }
        
        // Start the background audio session
        do {
            let session = AVAudioSession.sharedInstance()
            if #available(iOS 12.0, *) {
                try session.setCategory(.playback, mode: .voicePrompt, options: .interruptSpokenAudioAndMixWithOthers)
            } else {
                try session.setCategory(.playback, mode: .default, options: .mixWithOthers)
            }
            try session.setActive(true)
            audioSession = session
        }
        catch let err {
            debugPrint("Failed to start AV session. \(err)")
        }
        
        // Start the player
        self.audioPlayer?.play()
    }
    
    /// Stop the audio session and audio player.
    public func stopAudioSession() {
        
        // Stop the audio player
        if self.audioPlayer?.isPlaying ?? false {
            self.audioPlayer?.stop()
        }
        
        // Release the session
        if audioSession != nil {
            do {
                audioSession = nil
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            } catch let err {
                debugPrint("Failed to stop AV session. \(err)")
            }
        }
    }
}
