//
//  RSDRangeObject.swift
//  Research
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
import Formatters

/// `RSDDurationRangeObject` extends the properties of an `RSDInputField` for a `.duration` data type.
public struct RSDDurationRangeObject : RSDDurationRange, RSDRangeWithFormatter, Codable {
    
    private enum CodingKeys : String, CodingKey, CaseIterable {
        case minimumValue, maximumValue, stepInterval, unit, durationUnits
    }
    
    /// The minimum allowed duration.
    public let minimumDuration: Measurement<UnitDuration>
    
    /// The maximum allowed duration. When the value of this property is `nil`, there is no maximum.
    public let maximumDuration: Measurement<UnitDuration>?
    
    /// A step interval to be used for a slider or picker in the smallest units represented.
    public let stepInterval: Int?
    
    /// The duration units that should be included in the formatter and picker used for setting up a
    /// `.duration` data type.
    public let durationUnits: Set<UnitDuration>
    
    /// `Formatter` that is appropriate to the data type. For a duration, the formatter is a
    /// `DateComponentsFormatter`.
    public var formatter: Formatter?
    
    /// Default initializer for a `Decimal` range. This is used to initialize the range for a `Decimal` type.
    ///
    /// - parameters:
    ///     - durationUnits: The units that should be included in the formatter and picker. If `nil` then the
    ///                      the default will include all units.
    ///     - minimumDuration: The minimum allowed duration. If `nil` then the default will be `0`.
    ///     - maximumDuration: The maximum allowed duration.
    ///     - stepInterval: A step interval to be used for a slider or picker in the smallest units represented.
    public init(durationUnits: Set<UnitDuration>? = nil, minimumDuration: Measurement<UnitDuration>? = nil, maximumDuration: Measurement<UnitDuration>? = nil, stepInterval: Int? = nil) {
        
        // Get the defaults
        let baseUnit = durationUnits?.min() ?? minimumDuration?.unit ?? .seconds
        let units = durationUnits ?? baseUnit.defaultUnits(with: maximumDuration)
        let min = minimumDuration?.converted(to: baseUnit) ?? Measurement(value: 0, unit: baseUnit)

        // Set the units
        self.durationUnits = units
        self.minimumDuration = min
        self.maximumDuration = maximumDuration
        self.stepInterval = stepInterval
        self.formatter = UnitDuration.defaultFormatter(for: units, baseUnit: baseUnit)
    }
    
    /// Initialize from a `Decoder`.
    ///
    /// - example:
    ///
    /// ```
    ///     { "minimumValue" : 15,
    ///       "maximumValue" : 360,
    ///       "stepInterval" : 5,
    ///       "unit" : "min",
    ///       "durationUnits" : ["min", "hr"]
    ///    }
    /// ```
    ///
    /// - parameter decoder: The decoder to use to decode this instance.
    /// - throws: `DecodingError`
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let unitSymbols = try container.decodeIfPresent(Set<String>.self, forKey: .durationUnits)
        let durationUnits = unitSymbols?.rsd_flatMapSet { UnitDuration(fromSymbol: $0)}
        
        let baseUnitSymbol = try container.decodeIfPresent(String.self, forKey: .unit)
        let baseUnit = durationUnits?.min() ?? baseUnitSymbol?.unitDuration() ?? .seconds
 
        let minimumValue = try container.decodeIfPresent(Double.self, forKey: .minimumValue) ?? 0
        self.minimumDuration = Measurement(value: minimumValue, unit: baseUnit)
        self.maximumDuration = try {
            guard let maximum = try container.decodeIfPresent(Double.self, forKey: .maximumValue) else { return nil }
            return Measurement(value: maximum, unit: baseUnit)
        }()
        
        self.stepInterval = try container.decodeIfPresent(Int.self, forKey: .stepInterval)
        
        let units = durationUnits ?? baseUnit.defaultUnits()
        self.durationUnits = units
        self.formatter = UnitDuration.defaultFormatter(for: units, baseUnit: baseUnit)
    }
    
    /// Encode the object to the given encoder.
    /// - parameter encoder: The encoder to use to encode this instance.
    /// - throws: `EncodingError`
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.minimumDuration.value, forKey: .minimumValue)
        try container.encodeIfPresent(self.maximumDuration?.converted(to: baseUnit).value, forKey: .maximumValue)
        try container.encodeIfPresent(self.stepInterval, forKey: .stepInterval)
        try container.encode(self.baseUnit.symbol, forKey: .unit)
        try container.encode(self.durationUnits.map { $0.symbol }, forKey: .durationUnits)
    }
}

extension String {
    fileprivate func unitDuration() -> UnitDuration? {
        return UnitDuration(fromSymbol: self)
    }
}

extension Double {
    fileprivate func measurement(with unit: Unit) -> Measurement<Unit> {
        return Measurement(value: self, unit: unit)
    }
}

extension UnitDuration {
    
    /// Returns a date components formatter set up for displaying duration values.
    /// - parameter units: The units of the formatter.
    /// - returns: A date components formatter set up to display a duration.
    public static func defaultFormatter(for units: Set<UnitDuration>, baseUnit: UnitDuration? = nil) -> RSDDurationFormatter {
        // set the default formatter
        let formatter = RSDDurationFormatter()
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = NSCalendar.Unit(durationUnits: units)
        formatter.fromStringUnit = baseUnit ?? units.min()
        formatter.toStringUnit = baseUnit ?? units.max()
        return formatter
    }

    /// The calendar component that maps to this unit.
    public var calendarComponent: Calendar.Component {
        switch self {
        case .hours:
            return .hour
        case .minutes:
            return .minute
        default:
            return .second
        }
    }
}

extension UnitDuration : Comparable {
    
    /// The maximum value represented by this unit.
    public func maxTimeValue() -> Int {
        switch self {
        case .hours:
            return 24
        default:
            return 60
        }
    }
    
    /// Calculate the set of units that are a valid subset of the display units used in a
    /// picker for entering time intervals where `self` is the base unit.
    ///
    /// If the `max` duration is `nil`, then this function will return the units that
    /// are greater than or equal to `self`. Otherwise, the subset will only include those
    /// units that are less than the max interval. For example, if the maximum interval is
    /// 30 minutes, then the `.hour` unit is *not* included.
    ///
    /// - parameter max: The duration that defines the maximum valid interval.
    public func defaultUnits(with max: Measurement<UnitDuration>? = nil) -> Set<UnitDuration> {
        let subset = Set(UnitDuration.all.filter { $0 >= self })
        guard let maxValue = max
            else {
                return subset
        }
        if maxValue.hours > 1 {
            return subset
        }
        else if maxValue.minutes > 1 {
            return subset.intersection([.minutes, .seconds])
        }
        else {
            return subset.intersection([.seconds])
        }
    }
    
    /// Increment up to the next larger unit.
    public func increment() -> UnitDuration? {
        let sizeOrder = UnitDuration.all.sorted(by: <)
        guard let idx = sizeOrder.firstIndex(of: self), idx + 1 < sizeOrder.count else { return nil }
        return sizeOrder[idx + 1]
    }
    
    /// The set of all the units.
    public static var all: Set<UnitDuration> {
        return [.seconds, .minutes, .hours]
    }
    
    /// Compariable implementation.
    public static func <(lhs: UnitDuration, rhs: UnitDuration) -> Bool {
        guard let left = lhs.converter as? UnitConverterLinear,
            let right = rhs.converter as? UnitConverterLinear else { return false }
        return left.coefficient < right.coefficient
    }
}

extension Measurement where UnitType : UnitDuration {
    
    /// The hours component of the measurement.
    public var hours : Int {
        return self.component(of: .hours)
    }
    
    /// The minutes component of the measurement.
    public var minutes : Int {
        return self.component(of: .minutes)
    }
    
    /// The seconds component of the measurement.
    public var seconds : Int {
        return self.component(of: .seconds)
    }
    
    /// The duration represented by this measurement.
    public var timeInterval : TimeInterval {
        return self.valueConverted(to: .seconds)
    }
    
    /// The value of the measurement in the given units.
    /// - parameter unit: The unit of duration.
    /// - returns: The value of the converted measurement.
    public func valueConverted(to unit: UnitDuration) -> Double {
        return self.converted(to: unit as! UnitType).value
    }
    
    /// The whole number value of the component part represented by the given
    /// unit of duration.
    /// - parameter unit: The unit for which return the component.
    /// - returns: The whole number value for the given component.
    public func component(of unit: UnitDuration) -> Int {
        guard let biggerUnit = unit.increment()
            else {
                return Int(floor(self.valueConverted(to: unit)))
        }
        let biggerValue = floor(self.valueConverted(to: biggerUnit))
        let biggerMeasurement = Measurement<UnitDuration>(value: biggerValue, unit: biggerUnit)
        let diff = self.valueConverted(to: unit) - biggerMeasurement.valueConverted(to: unit)
        return Int(floor(diff))
    }
}

extension NSCalendar.Unit {
    
    /// Convenience initializer for converting from a `RSDDurationUnit` set to an `NSCalendar.Unit`
    public init(durationUnits: Set<UnitDuration>) {
        let calendarComponents = durationUnits.map { $0.calendarComponent }
        self.init(calendarComponents: Set(calendarComponents))
    }
    
    /// Convenience initializer for converting from a `Calendar.Component` set to an `NSCalendar.Unit`
    public init(calendarComponents: Set<Calendar.Component>) {
        self = calendarComponents.reduce(NSCalendar.Unit(rawValue: 0), { (input, component) -> NSCalendar.Unit in
            switch component {
            case .era:
                return input.union(.era)
            case .year:
                return input.union(.year)
            case .month:
                return input.union(.month)
            case .day:
                return input.union(.day)
            case .hour:
                return input.union(.hour)
            case .minute:
                return input.union(.minute)
            case .second:
                return input.union(.second)
            case .nanosecond:
                return input.union(.nanosecond)
            case .weekday:
                return input.union(.weekday)
            case .weekdayOrdinal:
                return input.union(.weekdayOrdinal)
            case .quarter:
                return input.union(.quarter)
            case .weekOfMonth:
                return input.union(.weekOfMonth)
            case .weekOfYear:
                return input.union(.weekOfYear)
            case .yearForWeekOfYear:
                return input.union(.yearForWeekOfYear)
            case .timeZone:
                return input.union(.timeZone)
            case .calendar:
                return input.union(.calendar)
            @unknown default:
                assertionFailure("Unknown enum type")
                return input
            }
        })
    }
}

// TODO: syoung 04/14/2020 Implement support for duration questions.
//extension RSDDurationRangeObject : DocumentableStruct {
//
//    static func codingKeys() -> [CodingKey] {
//        return CodingKeys.allCases
//    }
//
//    static func rangeExamples() -> [RSDDurationRangeObject] {
//        return [RSDDurationRangeObject()]
//    }
//
//    static func examples() -> [Encodable] {
//        return rangeExamples()
//    }
//}


