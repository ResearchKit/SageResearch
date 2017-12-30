//
//  RSDLengthFormatter.h
//  ResearchSuite
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// `RSDLengthFormatter` is a custom subclass of the `NSLengthFormatter` that can convert a `NSMeasurement`
/// object to a localized string.
///
/// The default converters are overriden to check for a `NSMeasurement` and return the converted string
/// if available. If the units are imperial for the current locale, this is for measuring the height
/// of a person, *and* the value is below the `heightLowerThreshold`, then the measurement
/// will be returned in inches rather than in feet and inches.
///
/// - note: While this SDK is written in Swift where permissibile, formatters are written in Obj-c to allow
/// overriding `-getObjectValue:forString:errorDescription:`. Apple documentation does not include how to
/// set the value of the pointer for a Swift 4 implementation of the function. syoung 12/30/2017
///
@interface RSDLengthFormatter : NSLengthFormatter

/// Is this formatter used to describe a child's height? The default behavior for `NSLengthFormatter`
/// when the locale uses imperial units (not metric) is to show for a person's height in ft/in even
/// if it is for an infant or child. Whereas, typically a US height for infants and children is shown
/// in inches only. This property, if set to `true` will return a child's height in inches unless
/// the locale is metric, in which case it is ignored.
///
/// - note: Setting this value to `true` will also set `isForPersonHeightUse` to `true`.
///
@property (nonatomic, getter=isForChildHeightUse) BOOL forChildHeightUse;

/// The base unit to use for converting a `NSNumber` to a string. The default value will depend upon
/// whether or not this is used for measuring a person's height, and whether or not the `numberFormatter`
/// locale uses the metric system. If this is a height formatter then the default metric unit is
/// centimeters and the default imperial unit (US English) is inches. Otherwise, the default metric
/// unit is meters and the default imperial unit is feet.
///
/// This is used by the `-stringForObjectValue:` method to convert the input object to a localized string
/// for the case where the object value is a `NSNumber`. If the input object is a `NSMeasurement` then
/// this value is ignored.
@property (nonatomic) NSUnitLength *toStringUnit;

/// The base unit to use for converting a string to an `NSMeasurement`. The default value will depend upon
/// whether or not this is used for measuring a person's height, and whether or not the `numberFormatter`
/// locale uses the metric system. If this is a height formatter then the default metric unit is
/// centimeters and the default imperial unit (US English) is inches. Otherwise, the default metric
/// unit is meters and the default imperial unit is feet.
///
/// This is used by the `-getObjectValue:forString:errorDescription:` method to convert the input string
/// to a `NSMeasurement` if the units cannot be parsed from the input string.
@property (nonatomic) NSUnitLength *fromStringUnit;

@end

NS_ASSUME_NONNULL_END
