//
//  RSDRecorderConfiguration.swift
//  Research
//
//  Copyright © 2017-2018 Sage Bionetworks. All rights reserved.
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


/// `RSDRecorderConfiguration` is used to configure a recorder. For example, recording accelerometer data
/// or video.
public protocol RSDRecorderConfiguration : RSDAsyncActionConfiguration {
    
    /// An identifier marking the step at which to stop the action. If `nil`, then the action will be
    /// stopped when the task is stopped.
    var stopStepIdentifier: String? { get }
    
    /// Whether or not the recorder requires background audio. Default = `false`.
    ///
    /// If `true` then background audio can be used to keep the recorder running if the screen is locked
    /// because of the idle timer turning off the device screen.
    ///
    /// If the app uses background audio, then the developer will need to turn `ON` the "Background Modes"
    /// under the "Capabilities" tab of the Xcode project, and will need to select "Audio, AirPlay, and
    /// Picture in Picture".
    var requiresBackgroundAudio: Bool { get }
}

/// Extends `RSDRecorderConfiguration` for a recorder that might be restarted.
public protocol RSDRestartableRecorderConfiguration : RSDRecorderConfiguration {
    
    /// Should the file used in a previous run of a recording be deleted?
    var shouldDeletePrevious: Bool { get }
}

/// `RSDJSONRecorderConfigureation` is used to configure a recorder to record JSON samples.
/// - seealso: `RSDSampleRecorder`
public protocol RSDJSONRecorderConfiguration : RSDRecorderConfiguration {
    
    /// Should the logger use a dictionary as the root element?
    ///
    /// If `true` then the logger will open the file with the samples included in an array with the key
    /// of "items". If `false` then the file will use an array as the root elemenent and the samples will
    /// be added to that array. Default = `false`
    ///
    /// - example:
    ///
    /// If the log file uses a dictionary as the root element then
    /// ```
    ///    {
    ///    "startDate" : "2017-10-16T22:28:09.000-07:00",
    ///    "items"     : [
    ///                     {
    ///                     "uptime": 1234.56,
    ///                     "stepPath": "/Foo Task/sectionA/step1",
    ///                     "timestampDate": "2017-10-16T22:28:09.000-07:00",
    ///                     "timestamp": 0
    ///                     },
    ///                     // ... more samples ... //
    ///                 ]
    ///     }
    /// ```
    ///
    /// If the log file uses an array as the root element then
    /// ```
    ///    [
    ///     {
    ///     "uptime": 1234.56,
    ///     "stepPath": "/Foo Task/sectionA/step1",
    ///     "timestampDate": "2017-10-16T22:28:09.000-07:00",
    ///     "timestamp": 0
    ///     },
    ///     // ... more samples ... //
    ///     ]
    /// ```
    ///
    var usesRootDictionary: Bool { get }
}
