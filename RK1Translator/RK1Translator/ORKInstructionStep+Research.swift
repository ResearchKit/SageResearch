//
//  ORKInstructionStep+Research.swift
//  RK1Translator
//
//  Copyright © 2018 Sage Bionetworks. All rights reserved.
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

extension ORKStep {
    
    public func validate() throws {
        try RSDExceptionHandler.try {
            self.validateParameters()
        }
    }
}

/// `ORKInstructionStep` implements the `RSDThemedUIStep` protocol by returning
/// `self` as the `RSDImageThemeElement`. This implementation also supports
/// implementing the `RSDFetchableImageThemeElement` protocol by returning
/// either the `iconImage` (above) or the `image` (below) for this step.
extension ORKInstructionStep : RSDThemedUIStep, RSDFetchableImageThemeElement {

    public func copy(with identifier: String) -> Self {
        return copy(withIdentifier: identifier)
    }

    public var detail: String? {
        return detailText
    }
    
    public var stepType: RSDStepType {
        return (self is ORKCompletionStep) ? .completion : .instruction
    }
    
    public func instantiateStepResult() -> RSDResult {
        return RSDResultObject(identifier: identifier, type: .base)
    }

    public func action(for actionType: RSDUIActionType, on step: RSDStep) -> RSDUIAction? {
        return nil
    }
    
    public func shouldHideAction(for actionType: RSDUIActionType, on step: RSDStep) -> Bool? {
        return nil
    }
    
    public var viewTheme: RSDViewThemeElement? {
        return nil
    }
    
    public var colorTheme: RSDColorThemeElement? {
        return nil
    }
    
    public var imageTheme: RSDImageThemeElement? {
        return self
    }
    
    public func fetchImage(for size: CGSize, callback: @escaping ((String?, UIImage?) -> Void)) {
        DispatchQueue.main.async {
            callback(self.identifier, self.iconImage ?? self.image)
        }
    }
    
    public var placementType: RSDImagePlacementType? {
        return (self.iconImage != nil) ? .iconBefore : (self.image != nil) ? .iconAfter : nil
    }
    
    public var size: CGSize {
        return self.image?.size ?? self.iconImage?.size ?? .zero
    }
    
    public var bundle: Bundle? {
        return nil
    }
    
    public var imageIdentifier: String {
        return self.identifier
    }
}
