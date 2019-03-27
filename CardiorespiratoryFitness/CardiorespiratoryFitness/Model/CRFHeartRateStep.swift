//
//  CRFHeartRateStep.swift
//  CardiorespiratoryFitness
//
//  Copyright © 2018-2019 Sage Bionetworks. All rights reserved.
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

import UIKit

/// Custom subclass of the active step that can decode configuration details specific to the heart rate
/// recorder used by this step view controller.
open class CRFHeartRateStep : RSDActiveUIStepObject, RSDRestartableRecorderConfiguration {

    private enum CodingKeys : String, CodingKey {
        case cameraSettings, isResting, shouldDeletePrevious
    }
    
    /// The camera settings.
    public var cameraSettings : CRFCameraSettings = CRFCameraSettings()
    
    /// Is this the resting heart rate?
    public var isResting: Bool = true
    
    /// Should the file used in a previous run of a recording be deleted?
    /// Default = `true`.
    public private(set) var shouldDeletePrevious: Bool = true
    
    /// This recorder requires permission to use the camera.
    public var permissionTypes: [RSDPermissionType] {
        return [RSDStandardPermissionType.camera]
    }
    
    /// The start and stop identifers are for this step.
    public var startStepIdentifier: String? {
        return self.identifier
    }
    
    /// The start and stop identifers are for this step.
    public var stopStepIdentifier: String? {
        return self.identifier
    }
    
    /// Override the copy into method.
    override open func copyInto(_ copy: RSDUIStepObject) {
        super.copyInto(copy)
        guard let subclassCopy = copy as? CRFHeartRateStep else {
            assertionFailure("Failed to copy into a class of expected type.")
            return
        }
        subclassCopy.isResting = self.isResting
        subclassCopy.shouldDeletePrevious = self.shouldDeletePrevious
        subclassCopy.cameraSettings = self.cameraSettings
    }
    
    /// Override to decode the configuration if there is one.
    override open func decode(from decoder: Decoder, for deviceType: RSDDeviceType?) throws {
        try super.decode(from: decoder, for: deviceType)
        if deviceType == nil {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.cameraSettings = try container.decodeIfPresent(CRFCameraSettings.self, forKey: .cameraSettings) ?? self.cameraSettings
            self.isResting = try container.decodeIfPresent(Bool.self, forKey: .isResting) ?? self.isResting
            self.shouldDeletePrevious = try container.decodeIfPresent(Bool.self, forKey: .shouldDeletePrevious) ?? self.shouldDeletePrevious
            
            // set up default values
            if self.shouldHideActions == nil {
                self.shouldHideActions = [.navigation(.goBackward), .navigation(.goForward)]
            }
            if self.duration == 0 {
                self.duration = 20  // default is 20 seconds
            }
            if self.commands.rawValue == 0 {
                self.commands = [.vibrate, .continueOnFinish, .shouldDisableIdleTimer]
            }
            self.requiresBackgroundAudio = true
        }
    }
    
    /// This step has multiple results so use a collection result to store them.
    override open func instantiateStepResult() -> RSDResult {
        return RSDCollectionResultObject(identifier: self.identifier)
    }
}
