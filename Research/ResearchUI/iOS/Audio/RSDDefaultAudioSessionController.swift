//
//  RSDDefaultAudioSessionController.swift
//  Research
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
import Research

/// The default audio session controller for iOS applications that use background audio.
public final class RSDDefaultAudioSessionController : NSObject, RSDAudioSessionController {
    
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
    }
    
    /// Stop the audio session.
    public func stopAudioSession() {
        do {
            audioSession = nil
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch let err {
            debugPrint("Failed to stop AV session. \(err)")
        }
    }
    
}
