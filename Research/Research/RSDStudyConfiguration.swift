//
//  RSDStudyConfiguration.swift
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

/// The study configuration is intended as a shared singleton that contains any information that should be
/// applied to the entire study that may effect the presentation of a given module.
open class RSDStudyConfiguration {
    
    /// Singleton for the study configuration for a given app.
    public static var shared: RSDStudyConfiguration = RSDStudyConfiguration()
    
    /// How often should a given task be displayed to the user with the full instructions?
    /// (Default = `always`)
    ///
    /// Setting this flag to `always` will result in modules that use this flag showing the full instruction
    /// sequence for every run. This can be used both to test the instruction flow as well as where a study
    /// uses the same mobile device for multiple participants and needs to display the instructions every
    /// time.
    ///
    /// Setting this flag to another value will result in modules that use this flag showing an abbreviated
    /// set of instructions for subsequent runs so that complicated and/or lengthy instructions can be
    /// limited to only being displayed sometimes (first run, on demand, etc.) rather than every time the
    /// *same* user runs the module. For this case, the frequency with which the app shows the full
    /// instructions is determined by the frequency type. For example, if set to `monthly` then the user is
    /// shown the full instructions once per month.
    ///
    open var fullInstructionsFrequency : RSDFrequencyType = .always
    
    /// - seealso: `fullInstructionsFrequency`
    open var alwaysShowFullInstructions : Bool {
        return self.fullInstructionsFrequency == .always
    }
    
    /// Is this device tied to a single participant or is the device being used in a study where there is a
    /// single mobile device that is being used to run tasks for multiple participants, such as a device used
    /// as part of a Phase 1 or Preclinical trial? (Default = `true`)
    open var isParticipantDevice : Bool = true
    
    /// The default color palette to use for this app.
    open var colorPalette: RSDColorPalette = .wireframe {
        didSet {
            self.hasSetColorPallette = true
        }
    }
    
    /// Has the color palette been set for this app or is it set to the default?
    public private(set) var hasSetColorPallette: Bool = false
    
    /// The default font rules for this app.
    open var fontRules: RSDFontRules = RSDFontRules(version: 1)
    
    /// A flag for whether or not tasks that support "remind me later" should show that action. (Default = `false`)
    open var shouldShowRemindMe: Bool = false
}
