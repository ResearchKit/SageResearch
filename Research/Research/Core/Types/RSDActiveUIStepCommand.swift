//
//  RSDActiveUIStepCommand.swift
//  Research
//
//  Copyright © 2017 Sage Bionetworks. All rights reserved.
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
import JsonModel

/// `RSDActiveUIStepCommand` is an `OptionSet` for certain commonly used commands that are used at the
/// beginning and end of an active step.
///
/// - seealso: `RSDActiveUIStep`
///
public struct RSDActiveUIStepCommand : RSDStringLiteralOptionSet {
    
    /// The corresponding value of the raw type.
    ///
    /// A new instance initialized with `rawValue` will be equivalent to this
    /// instance.
    public let rawValue: Int
    
    /// Required initializer for a `RawRepresentable`.
    ///
    /// - parameter rawValue: The raw value for this command.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// Initializer for a command (or set of commands) that are represented by a string value.
    ///
    /// - parameters:
    ///     - unionSet: The set of commands included in this set.
    ///     - codingKey: The string representation.
    public init(_ unionSet: RSDActiveUIStepCommand, codingKey: String) {
        self.rawValue = unionSet.rawValue

        type(of: self).set(rawValue: unionSet.rawValue, forKey: codingKey)
    }
    
    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or if the data read
    /// is corrupted or otherwise invalid.
    ///
    /// - parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        // Register the commands included in the base struct to add them to the mapping
        let _ = RSDActiveUIStepCommand.allCodingKeys()
        
        // Then call the initializer with the string mappings
        try self.init(from: decoder, stringMapping: RSDActiveUIStepCommand.stringMapping)
    }
    
    /// A mapping of an option to a string value. This is used to allow `Codable` protocol
    /// conformance using human-readable strings rather than `Binary` flags.
    ///
    /// - seealso: The following is a list of the Codable keys defined in this framework.
    ///
    ///     `playSoundOnStart`
    ///     `playSoundOnFinish`
    ///     `playSound`
    ///     `vibrateOnStart`
    ///     `vibrateOnFinish`
    ///     `vibrate`
    ///     `startTimerAutomatically`
    ///     `continueOnFinish`
    ///     `transitionAutomatically`
    ///     `shouldDisableIdleTimer`
    ///     `speakWarningOnPause`
    ///
    public private(set) static var stringMapping: [String : Int] = [:]
    
    /// A convenience method for mapping a `rawValue` to a `String`.
    ///
    /// - parameters:
    ///     - rawValue: The raw value for this command.
    ///     - forKey: The string representation.
    public static func set(rawValue: RawValue, forKey: String) {
        stringMapping[forKey] = rawValue
    }

    /// Play a default sound when the step starts.
    public static let playSoundOnStart = RSDActiveUIStepCommand(1 << 0, codingKey: "playSoundOnStart")
    
    /// Play a default sound when the step finishes.
    public static let playSoundOnFinish = RSDActiveUIStepCommand(1 << 1, codingKey: "playSoundOnFinish")
    
    /// Play a default sound when the step starts and finishes.
    public static let playSound = RSDActiveUIStepCommand([.playSoundOnStart, .playSoundOnFinish], codingKey: "playSound")
    
    /// Vibrate when the step starts.
    public static let vibrateOnStart = RSDActiveUIStepCommand(1 << 2, codingKey: "vibrateOnStart")
    
    /// Vibrate when the step finishes.
    public static let vibrateOnFinish = RSDActiveUIStepCommand(1 << 3, codingKey: "vibrateOnFinish")
    
    /// Vibrate when the step starts and finishes.
    public static let vibrate = RSDActiveUIStepCommand([.vibrateOnStart, .vibrateOnFinish], codingKey: "vibrate")
    
    /// Start the count down timer automatically when the step start.
    public static let startTimerAutomatically = RSDActiveUIStepCommand(1 << 4, codingKey: "startTimerAutomatically")
    
    /// Transition automatically when the step finishes.
    public static let continueOnFinish = RSDActiveUIStepCommand(1 << 5, codingKey: "continueOnFinish")
    
    /// Start the count down timer automatically when the step starts and transition automatically when the step finishes.
    public static let transitionAutomatically = RSDActiveUIStepCommand([.startTimerAutomatically, .continueOnFinish], codingKey: "transitionAutomatically")
    
    /// Disable the idle timer if included.
    public static let shouldDisableIdleTimer = RSDActiveUIStepCommand(1 << 6, codingKey: "shouldDisableIdleTimer")
    
    /// Speak a warning when the pause button is tapped.
    public static let speakWarningOnPause = RSDActiveUIStepCommand(1 << 7, codingKey: "speakWarningOnPause")

    /// The default commands for a step.
    public static let defaultCommands: RSDActiveUIStepCommand = []
    
    static func allCodingKeys() -> [String] {
        // Register the commands included in the base struct to add them to the mapping
        let _: RSDActiveUIStepCommand = [.playSound,
                                         .vibrate,
                                         .transitionAutomatically,
                                         .shouldDisableIdleTimer,
                                         .speakWarningOnPause]
        return self.stringMapping.map{ $0.key }
    }
}

extension RSDActiveUIStepCommand : DocumentableStringOptionSet {
    public static func examples() -> [String] {
        allCodingKeys()
    }
}
