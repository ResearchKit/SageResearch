//
//  RSDTextFieldOptions+Platform.swift
//  ResearchPlatformContext
//
//  Copyright © 2017-2019 Sage Bionetworks. All rights reserved.
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

import Research

#if os(iOS) || os(tvOS)
import UIKit

extension RSDTextAutocapitalizationType {

    /// Return the `UITextAutocapitalizationType` that maps to this enum.
    public func textAutocapitalizationType() -> UITextAutocapitalizationType {
        guard let idx = self.rawIntValue(),
            let type = UITextAutocapitalizationType(rawValue: Int(idx))
            else {
                return .none
        }
        return type
    }
}

extension RSDTextAutocorrectionType {

    /// Return the `UITextAutocorrectionType` that maps to this enum.
    public func textAutocorrectionType() -> UITextAutocorrectionType {
        guard let idx = self.rawIntValue(),
            let type = UITextAutocorrectionType(rawValue: Int(idx))
            else {
                return .default
        }
        return type
    }
}

extension RSDTextSpellCheckingType {
    
    /// Return the `UITextSpellCheckingType` that maps to this enum.
    public func textSpellCheckingType() -> UITextSpellCheckingType {
        guard let idx = self.rawIntValue(),
            let type = UITextSpellCheckingType(rawValue: Int(idx))
            else {
                return .default
        }
        return type
    }
}

extension RSDKeyboardType {

    /// Return the `UIKeyboardType` that maps to this enum.
    public func keyboardType() -> UIKeyboardType {
        guard let idx = self.rawIntValue(),
            let type = UIKeyboardType(rawValue: Int(idx))
            else {
                return .default
        }
        return type
    }
}

#endif
