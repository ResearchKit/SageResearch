//
//  RSDDecodableReplacement.swift
//  Research
//

import Foundation


/// A lightweight protocol for replacing the mutable properties on a class with values from a decoder.
public protocol RSDDecodableReplacement : AnyObject {
    
    /// Decode from the given decoder, replacing mutable properties on self with those from the decoder.
    func decode(from decoder: Decoder) throws
}
