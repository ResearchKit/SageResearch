//
//  RSDUnitConverter.swift
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

/// `RSDUnitConverter` is a static struct for defined unit converters for converting between US English (imperial)
/// to metric units. This is used to allow for displaying a person's height or weight in imperial units, while
/// storing the value in standardized metric units.
public struct RSDUnitConverter {
    
    /// The converter to use for mass measurements.
    public static let poundAndOunces = USCustomaryUnitConverter<UnitMass>(largeUnit: .pounds, smallUnit: .ounces, baseUnit: .kilograms)
    
    /// The converter to use for length measurements.
    public static let feetAndInches = USCustomaryUnitConverter<UnitLength>(largeUnit: .feet, smallUnit: .inches, baseUnit: .centimeters)
    
    /// `USCustomaryUnitConverter` is generic struct for converting measurements from various units.
    ///
    /// - note: US Customary and Imperial units measurements are typically shown using a "larger"
    /// and "smaller" unit such as "ft, in" or "lb, oz". This converter will convert from a base
    /// unit (default will be metric) to two values, a larger and smaller unit, that are added
    /// together to represent a measurement. For example, "5 ft, 6 in".
    public struct USCustomaryUnitConverter<UnitType> where UnitType : Dimension {
        
        /// The larger imperial unit. For example, "lb" (UnitMass) or "ft" (UnitLength).
        public let largeUnit: UnitType
        
        /// The smaller imperial unit. For example, "oz" (UnitMass) or "in" (UnitLength).
        public let smallUnit: UnitType
        
        /// The base unit. Default will be the metric value typically used for person measurements
        /// such as height or weight.
        public var baseUnit: UnitType
        
        /// The number of smaller units in the larger unit. For example, "1 lb = 12 oz" (UnitMass) or
        /// "1 ft = 12 in" (UnitLength).
        public let smallToLargeConversion: Int
        
        /// Default initializer.
        /// - parameters:
        ///     - largeUnit: The larger imperial unit.
        ///     - smallUnit: The smaller imperial unit.
        ///     - baseUnit: The base unit.
        init(largeUnit: UnitType, smallUnit: UnitType, baseUnit: UnitType) {
            self.largeUnit = largeUnit
            self.smallUnit = smallUnit
            self.baseUnit = baseUnit
            self.smallToLargeConversion = Int(Measurement(value: 1, unit: largeUnit).converted(to: smallUnit).value)
        }
        
        /// Convert the input value to a `Measurement` of the same unit type. This will always return the
        /// measurement converted to the `baseUnit` and can be used to convert any value that is a Number
        /// or `Measurement`. If this is a Number, then it is assumed that the unit for the number is the
        /// `baseUnit`.
        /// - parameter value: The value to convert.
        /// - returns: A measurement in the appropriate unit or `nil` if unable to convert.
        public func measurement(from value: Any) -> Measurement<UnitType>? {
            if let ret = value as? Measurement<UnitType> {
                return ret.converted(to: baseUnit)
            } else if let num = (value as? NSNumber) ?? (value as? JsonNumber)?.jsonNumber() {
                return Measurement(value: num.doubleValue, unit: baseUnit)
            } else {
                return nil
            }
        }
        
        /// Convert the input US Customary unit values to a `Measurement` of the same unit type. This
        /// will convert the `largeValue` to a `Measurement` with a unit of `largeUnit` and the `smallValue`
        /// to a `Measurement` with a unit of `smallUnit`. The measurements will be summed and the total will
        /// be returned with a unit of  `baseUnit`.
        ///
        /// - parameters:
        ///     - largeValue: The larger value to convert.
        ///     - smallValue: The smaller value to convert.
        /// - returns: A measurement in the appropriate unit.
        public func measurement(fromLargeValue largeValue: Double, smallValue: Double) -> Measurement<UnitType> {
            let smallMeasurement = Measurement(value: smallValue, unit: smallUnit)
            let largeMeasurement = Measurement(value: largeValue, unit: largeUnit)
            return (smallMeasurement + largeMeasurement.converted(to: smallUnit)).converted(to: baseUnit)
        }
        
        /// Convert the input value to a tuple with the large and small measurement components used to
        /// represent the measurement using US Customary or Imperial units where the units are represented
        /// with a larger and smaller unit.
        ///
        /// - example:
        /// ```
        ///     // returns 1 foot, 8 inches
        ///     let feet_1_AndInches_8 = lengthConverter.toTupleValue(from: 20 * 2.54)
        /// ```
        ///
        /// - parameter value: The value to convert.
        /// - returns:
        ///     - largeValue: The larger component of the converted measurement.
        ///     - smallValue: The smaller component of the converted measurement.
        public func toTupleValue(from value: Any) -> (largeValue: Double, smallValue: Double)? {
            guard let measurement = measurement(from: value) else { return nil }
            let largeValue = floor(measurement.converted(to: largeUnit).value)
            let remainder = measurement.converted(to: smallUnit).value - Measurement(value: largeValue, unit: largeUnit).converted(to: smallUnit).value
            let smallValue = round(remainder * 1000) / 1000
            return (largeValue, smallValue)
        }
    }
}

