//
//  RSDMeasurementWrapper.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Protocol defining the methods called by the `RSDMeasurementWrapper` to convert the number and string
/// to a unit.
@protocol RSDMeasurementFormatter <NSObject>

/// Default `NSNumberFormatter` for this measurement formatter.
- (NSNumberFormatter *)numberFormatter;

/// Convert the number (with an optional unit string) into a measurement.
/// @param  number      The number to convert.
/// @param  unitString  A string representation of the unit. Optional.
/// @returns            The measurement from this number and unit.
- (NSMeasurement * _Nullable)measurementForNumber:(NSNumber *)number unit:(NSString * _Nullable)unitString;

@end

/// `RSDMeasurementWrapper` is a convenience wrapper for allowing shared parsing code for both
/// a length and mass formatter.
@interface RSDMeasurementWrapper : NSObject

/// Use regex pattern matching to find decimal numbers in the string, and assume that the other part
/// of the string is a unit.
///
/// Note: This will only work for languages that define numbers using 0-9 digits. syoung 01/03/2018
///
/// @param  string      The string to parse into a number and unit.
/// @param  formatter   The formatter to use to actually convert the parsed number into an `NSMeasurement`.
/// @return             The measurement (if any) parsed from the string.
///
+ (NSMeasurement * _Nullable)measurementFromString:(NSString *)string withFormatter:(id <RSDMeasurementFormatter>)formatter;

@end

NS_ASSUME_NONNULL_END
