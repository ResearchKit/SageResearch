//
//  RSDUISoundPlayer.swift
//  ResearchSuiteUI
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

public struct RSDSound {
    public let url: URL?
    
    public init(name: String) {
        self.url = URL(string: "/System/Library/Audio/UISounds/\(name).caf")
    }
    
    public init(url: URL) {
        self.url = url
    }
    
    public static let alarm = RSDSound(name: "alarm")
    public static let short_low_high = RSDSound(name: "short_low_high")
    public static let short_double_high = RSDSound(name: "short_double_high")
    public static let short_double_low = RSDSound(name: "alarm")
    public static let photoShutter = RSDSound(name: "photoShutter")
}

public protocol RSDSoundPlayer {
    func playSound(_ sound: RSDSound)
}

public class RSDAudioSoundPlayer : NSObject, RSDSoundPlayer {

    public static var shared: RSDSoundPlayer = RSDAudioSoundPlayer()

    public func playSound(_ sound: RSDSound) {
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
