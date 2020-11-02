//
//  RSDFractionFormatter.m
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

#import "include/RSDFractionFormatter.h"
#import <objc/runtime.h>

@implementation NSNumber (RSDFraction)

- (RSDFraction)fractionalValue {
    
    RSDFraction fraction;
    
    if ([self isEqual: [NSDecimalNumber notANumber]]) {
        fraction.numerator = 0;
        fraction.denominator = 0;
        return fraction;
    } else if (self.doubleValue == INFINITY) {
        fraction.numerator = 1;
        fraction.denominator = 0;
        return fraction;
    } else if (self.doubleValue == -1 * INFINITY) {
        fraction.numerator = -1;
        fraction.denominator = 0;
        return fraction;
    }
    
    double accuracy = 0.00001;
    double x = self.doubleValue;
    double n = floor(x);
    x -= n;

    if (x < accuracy) {
        fraction.numerator = (NSInteger)n;
        fraction.denominator = 1;
        return fraction;
    } else if ((1 - accuracy) < x) {
        fraction.numerator = (NSInteger)(n + 1);
        fraction.denominator = 1;
        return fraction;
    }
    
    double lower_n = 0;
    double lower_d = 1;
    double upper_n = 1;
    double upper_d = 1;
    int loopCount = 0;
    
    while (loopCount++ < 1000) {
        double middle_n = lower_n + upper_n;
        double middle_d = lower_d + upper_d;
        if (middle_d * (x + accuracy) < middle_n) {
            upper_n = middle_n;
            upper_d = middle_d;
        } else if (middle_n < (x - accuracy) * middle_d) {
            lower_n = middle_n;
            lower_d = middle_d;
        } else {
            fraction.numerator = (NSInteger)(n * middle_d + middle_n);
            fraction.denominator = (NSInteger)middle_d;
            return fraction;
        }
    }
    
    fraction.numerator = 1;
    fraction.denominator = 0;
    return fraction;
}

@end

@implementation RSDFractionFormatter

- (NSNumber *)numberFromString:(NSString *)string {
    
    // If the number can be converted then return it.
    NSNumber *num = [self.numberFormatter numberFromString:string];
    if (num != nil) {
        return num;
    }

    // Otherwise, only valid if it is split 
    NSArray <NSString *> *split = [string componentsSeparatedByString:self.fractionSeparator];
    if (split.count == 2) {
        NSNumber *numerator = [self.numberFormatter numberFromString:split[0]];
        NSNumber *denominator = [self.numberFormatter numberFromString:split[1]];
        if ((numerator == nil) || ([denominator integerValue] == 0)) {
            return nil;
        }
        NSNumber *num = @([numerator doubleValue] / [denominator doubleValue]);
        if (self.numberFormatter.generatesDecimalNumbers) {
            return [NSDecimalNumber decimalNumberWithDecimal:[num decimalValue]];
        } else {
            return num;
        }
    } else {
        return nil;
    }
}

- (NSString *)stringFromNumber:(NSNumber *)number {
    RSDFraction fraction = [number fractionalValue];
    if (fraction.denominator == 0) {
        return nil;
    } else if (fraction.denominator == 1) {
        return [self.numberFormatter stringFromNumber:@(fraction.numerator)];
    } else {
        NSString *nn = [self.numberFormatter stringFromNumber:@(fraction.numerator)];
        NSString *dd = [self.numberFormatter stringFromNumber:@(fraction.denominator)];
        return [NSString stringWithFormat:@"%@%@%@", nn, self.fractionSeparator, dd];
    }
}

- (NSString *)stringForObjectValue:(id)obj {
    if ([obj isKindOfClass:[NSNumber class]]) {
        return [self stringFromNumber:(NSNumber *)obj];
    } else {
        return [super stringForObjectValue:obj];
    }
}

- (BOOL)getObjectValue:(out id  _Nullable __autoreleasing *)obj forString:(NSString *)string errorDescription:(out NSString *__autoreleasing  _Nullable *)error {
    
    // A zero-length string cannot be converted.
    if ((string.length == 0) || (obj == nil)) {
        if (error) {
            *error = @"Not a number";
        }
        return false;
    }

    // The formatter for converting to a number calls through to this formatter
    // so check to see that we aren't in a wacky loop.
    NSNumber *num = [self numberFromString:string];
    if (num != nil) {
        *obj = num;
        return true;
    } else {
        return false;
    }
}

#pragma mark - properties

- (NSString *)fractionSeparator {
    return _fractionSeparator ? : @"/";
}

- (NSNumberFormatter *)numberFormatter {
    if (_numberFormatter == nil) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        _numberFormatter.generatesDecimalNumbers = YES;
        _numberFormatter.alwaysShowsDecimalSeparator = NO;
        _numberFormatter.usesGroupingSeparator = NO;
    }
    return _numberFormatter;
}

#pragma mark - copy

- (id)copyWithZone:(NSZone *)zone {
    RSDFractionFormatter *copy = [[RSDFractionFormatter alloc] init];
    copy->_numberFormatter = _numberFormatter;
    copy->_fractionSeparator = _fractionSeparator;
    return copy;
}

@end
