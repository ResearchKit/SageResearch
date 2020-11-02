//
//  RSDFractionFormatter.h
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

/// Fractions are are represented by `numerator / denominator`.
typedef struct {
    NSInteger numerator;
    NSInteger denominator;
} RSDFraction;

@interface NSNumber (RSDFraction)

/// @return  The fraction that represents this number.
- (RSDFraction)fractionalValue;

@end

/// `RSDFractionFormatter` is a custom subclass of the `NSFormatter` that can convert a number to a string
/// with a fractional format, or a fraction to a number -- for example, "3/4" would be converted to
/// `RSDFraction` with a double value of 0.75.
///
/// - note: While this SDK is written in Swift where permissibile, formatters are written in Obj-c to allow
/// overriding `-getObjectValue:forString:errorDescription:`. Apple documentation does not include how to
/// set the value of the pointer for a Swift 4 implementation of the function. syoung 12/30/2017
///
@interface RSDFractionFormatter : NSFormatter

@property (null_resettable, copy, nonatomic) NSNumberFormatter *numberFormatter;

@property (null_resettable, copy, nonatomic) NSString *fractionSeparator;

- (NSNumber * _Nullable)numberFromString:(NSString *)string;

- (NSString * _Nullable)stringFromNumber:(NSNumber *)number;
    
@end

NS_ASSUME_NONNULL_END
