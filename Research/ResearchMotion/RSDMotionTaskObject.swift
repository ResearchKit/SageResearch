//
//  RSDMotionTaskObject.swift
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
import Research

extension RSDTaskType {
    public static let motionTask: RSDTaskType = "motionTask"
}

/// This background task is a work around for a running task that uses the motion sensors with the screen locked.
/// If using GPS or a streaming audio file, using this object is not required to keep the task active in the
/// background.
open class RSDMotionTaskObject: AssessmentTaskObject, RSDBackgroundTask {
    open override class func defaultType() -> RSDTaskType {
        .motionTask
    }
    
    /// By default, a motion task that runs in the background should *not* continue if the task is interupted
    /// by a phone call.
    open var shouldEndOnInterrupt: Bool = true
    
    /// By default, if a motion task is intended to run in the background, then it will return a pointer to
    /// an instance of `RSDMotionAudioSessionController`.
    open var audioSessionController: RSDAudioSessionController? {
        if _audioSessionController == nil {
            _audioSessionController = RSDMotionAudioSessionController()
        }
        return _audioSessionController
    }
    private var _audioSessionController: RSDAudioSessionController?
}
