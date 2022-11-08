//
//  RSDBackgroundTask.swift
//  Research
//

import Foundation
import MobilePassiveData

/// An active task is a task that has timing considerations, runs in the background, and/or includes
/// speech-to-text as a part of the task flow where the `AVAudioSession` may need to be active.
public protocol RSDActiveTask : RSDTask {
    
    /// Should the task end early if the task is interrupted by a phone call?
    var shouldEndOnInterrupt: Bool { get }
    
    /// The audio session settings (if any) required by this task to run properly.
    var audioSessionSettings: AudioSessionSettings? { get }
}

