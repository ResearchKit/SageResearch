//
//  RSDColorPlacement.swift
//  Research
//

import Foundation
import JsonModel

/// An enum for part of the view to which a given color style should be applied.
public enum RSDColorPlacement : String, Codable, CaseIterable, StringEnumSet {
    
    /// The color applies to the header.
    case header
    
    /// The color applies to the body of the view.
    case body
    
    /// The color applies to the footer of the view.
    case footer
}

extension RSDColorPlacement : DocumentableStringEnum {
}
