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
/// applied to the entire study which may effect the presentation of a given module.
open class RSDStudyConfiguration {
    
    /// Singleton for the study configuration for a given app.
    public static var shared: RSDStudyConfiguration = RSDStudyConfiguration()
    
    /// Should each run of the app display full instructions or can the instructions be abbreviated for
    /// subsequent runs.
    ///
    /// Setting this flag to `true` will result in modules that use this flag showing the full instruction
    /// sequence for every run. This can be used both to test the instruction flow as well as for a case
    /// where a study uses the same mobile device for multiple participants.
    ///
    /// Setting this flag to `false` will result in modules that use this flag showing an abbreviated set of
    /// instructions for subsequent runs so that complicated and/or lengthy instructions can be limited to
    /// only being displayed sometimes (first run, on demand, etc.) rather than every time the *same* user
    /// runs the module.
    ///
    public var alwaysShowFullInstructions : Bool = true
    
}
