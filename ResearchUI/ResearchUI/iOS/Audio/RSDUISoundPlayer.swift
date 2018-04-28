//
//  RSDUISoundPlayer.swift
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

import Foundation
import AudioToolbox

/// `RSDSound` contains sound file URLs.
public struct RSDSound {
    
    /// The name of the sound.
    public let name: String
    
    /// The url for the sound (if any).
    public let url: URL?
    
    /// Initializer for initializing system library UISounds.
    /// - parameter name: The name of the sound. This is also the name of the .caf file for that sound in the library.
    public init(name: String) {
        self.name = name
        self.url = URL(string: "/System/Library/Audio/UISounds/\(name).caf")
    }
    
    /// Initializer for creating a sound with a custom URL.
    /// - parameter url: The url with the path to the sound file.
    public init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
    }
    
    /// The alarm sound.
    public static let alarm = RSDSound(name: "alarm")
    
    /// A short low-high beep sound.
    public static let short_low_high = RSDSound(name: "short_low_high")
    
    /// A short double-high beep sound.
    public static let short_double_high = RSDSound(name: "short_double_high")
    
    /// A short double-low beep sound.
    public static let short_double_low = RSDSound(name: "short_double_low")
    
    /// The "photo shutter" sound played when taking a picture.
    public static let photoShutter = RSDSound(name: "photoShutter")
    
    /// A key tap sound.
    public static let tock = RSDSound(name: "Tock")
    
    /// A key tap sound.
    public static let tink = RSDSound(name: "Tink")
    
    /// The lock screen sound.
    public static let lock = RSDSound(name: "lock")
}

/// `RSDSoundPlayer` is a protocol for playing sounds intended to give the user UI feedback during
/// the running of a task.
public protocol RSDSoundPlayer {
    
    /// Play the given sound.
    /// - parameter sound: The system sound to play.
    func playSound(_ sound: RSDSound)
}

/// `RSDAudioSoundPlayer` is a concrete implementation of the `RSDSoundPlayer` protocol that can be used
/// to play system sounds using `AudioServicesCreateSystemSoundID()`.
open class RSDAudioSoundPlayer : NSObject, RSDSoundPlayer {

    /// A singleton instance of the audio sound player.
    public static var shared: RSDSoundPlayer = RSDAudioSoundPlayer()

    /// Play the given sound.
    /// - parameter sound: The system sound to play.
    open func playSound(_ sound: RSDSound) {
        guard let url = sound.url else { return }
        var soundId: SystemSoundID = 0
        let status = AudioServicesCreateSystemSoundID(url as CFURL, &soundId)
        guard status == kAudioServicesNoError else {
            debugPrint("Failed to create the ping sound for \(url)")
            return
        }
        AudioServicesAddSystemSoundCompletion(soundId, nil, nil, { (soundId, clientData) -> Void in
            AudioServicesDisposeSystemSoundID(soundId)
        }, nil)
        AudioServicesPlaySystemSound(soundId)
    }
}
