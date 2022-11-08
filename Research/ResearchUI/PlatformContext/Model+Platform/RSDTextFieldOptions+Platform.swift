//
//  RSDTextFieldOptions+Platform.swift
//  ResearchPlatformContext
//

import Research

#if os(iOS) || os(tvOS)
import UIKit

@available(*,deprecated, message: "Will be deleted in a future version.")
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

@available(*,deprecated, message: "Will be deleted in a future version.")
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

@available(*,deprecated, message: "Will be deleted in a future version.")
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

@available(*,deprecated, message: "Will be deleted in a future version.")
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
