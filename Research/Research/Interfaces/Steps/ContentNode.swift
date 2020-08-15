//
//  ContentNode.swift
//  Research
//
//  Copyright © 2020 Sage Bionetworks. All rights reserved.
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

/**
 * This protocol is included here to support migration to Kotlin.
 *
 * - seealso: https://github.com/Sage-Bionetworks/AssessmentModel-KotlinNative
 */
public protocol ContentNode {
    
    /**
     * All content nodes have an identifier.
     */
    var identifier: String { get }

    /**
     * The primary text to display for the node in a localized string. The UI should display this using a larger font.
     */
    var title: String? { get }

    /**
     * A subtitle to display for the node in a localized string.
     */
    var subtitle: String? { get }

    /**
     * Detail text to display for the node in a localized string.
     */
    var detail: String? { get }

    /**
     *
     * Additional text to display for the node in a localized string at the bottom of the view.
     *
     * The footnote is intended to be displayed in a smaller font at the bottom of the screen. It is intended to be
     * used in order to include disclaimer, copyright, etc. that is important to display to the participant but should
     * not distract from the main purpose of the [Step] or [Assessment].
     */
    var footnote: String? { get }
}

public protocol ResultNode : ContentNode {
    func instantiateResult() -> RSDResult
}

public protocol FormStep : ResultNode, RSDUIStep {
    
    /// A list of the child result nodes. Typically, these will be a collection of `Question`
    /// objects but that is not required.
    var children: [ResultNode] { get }
}

public extension FormStep {
    
    /// A form step instantiates a step result.
    func instantiateResult() -> RSDResult {
        instantiateStepResult()
    }
    
    /// Check to see if the step result is a collection result and return that if valid.
    func instantiateCollectionResult() -> CollectionResult {
        guard let result = instantiateStepResult() as? CollectionResult else {
            debugPrint("WARNING!!! The instantiated step result does not conform to `CollectionResult`.")
            return RSDCollectionResultObject(identifier: self.identifier)
        }
        return result
    }
}
