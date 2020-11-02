//
//  RSDDurationFormatter.m
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

#import "include/RSDDurationFormatter.h"
#import "include/NSUnit+RSDUnitConversion.h"
#import "include/RSDMeasurementWrapper.h"

@interface RSDDurationFormatter () <RSDMeasurementFormatter>
@property (null_resettable, nonatomic) NSNumberFormatter *numberFormatter;
@end

@implementation RSDDurationFormatter

- (NSNumberFormatter *)numberFormatter {
    if (_numberFormatter == nil) {
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.locale = [self locale];
    }
    return _numberFormatter;
}

- (NSUnitDuration *)toStringUnit {
    return _toStringUnit ? : [self defaultUnit];
}

- (NSUnitDuration *)fromStringUnit {
    return _fromStringUnit ? : [self defaultUnit];
}

- (NSUnitDuration *)defaultUnit {
    return NSUnitDuration.seconds;
}

- (NSLocale *)locale {
    return self.calendar.locale ? : NSLocale.currentLocale;
}

- (NSNumber * _Nullable)numberFromString:(NSString *)string {
    id obj;
    if ([self getObjectValue:&obj forString:string errorDescription:nil]) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            return (NSNumber *)[obj copy];
        } else if ([obj isKindOfClass:[NSMeasurement class]]) {
            return @([[(NSMeasurement *)obj measurementByConvertingToUnit:self.fromStringUnit] doubleValue]);
        }
    }
    return nil;
}

/// Return the string (or nil) for the given number.
- (NSString * _Nullable)stringFromNumber:(NSNumber *)number {
    return [self stringForObjectValue: number];
}

- (NSString *)stringForObjectValue:(id)obj {
    if (obj == nil) { return nil; }
    
    if ([obj isKindOfClass:[NSDateComponents class]]) {
        return [super stringForObjectValue:obj];
    }
    
    // convert the object to a measurement
    NSMeasurement *measurement = nil;
    if ([obj isKindOfClass:[NSMeasurement class]]) {
        measurement = (NSMeasurement *)obj;
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        double num = [(NSNumber *)obj doubleValue];
        measurement = [[NSMeasurement alloc] initWithDoubleValue:num unit:self.toStringUnit];
    } else if ([obj isKindOfClass:[NSString class]]) {
        double num = [(NSString *)obj doubleValue];
        measurement = [[NSMeasurement alloc] initWithDoubleValue:num unit:self.toStringUnit];
    } else {
        return [super stringForObjectValue:obj];
    }
    
    NSTimeInterval ti = [[measurement measurementByConvertingToUnit: NSUnitDuration.seconds] doubleValue];
    return [self stringFromTimeInterval:ti];
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)ti {
    NSString * stringValue = [super stringFromTimeInterval:ti];
    
    // syoung 10/17/2019 There appears to be a change with iOS 13 that this formatter
    // no longer conforms to the documentation for US English to read "1:30" versus "01:30".
    // In considering the "proper" behavior for this formatter, the formatting should respect
    // the zero padding everywhere if the `zeroFormattingBehavior` includes padding.
    // However, older versions of the OS do *not* format with the 0 padding so check for this
    // and correct it so that our unit tests will work regardless of the target iOS version.
    BOOL isZeroPadded = ((self.zeroFormattingBehavior & NSDateComponentsFormatterZeroFormattingBehaviorPad) != 0);
    if (!isZeroPadded) {
        // Exit early if not positional style or zero padding.
        return stringValue;
    }
    
    // Check if the string needs to be zero padded.
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[1-3]:" options:0 error:nil];
    NSUInteger matches = [regex numberOfMatchesInString:stringValue
                                                options:(NSMatchingOptions)0
                                                  range:NSMakeRange(0, [stringValue length])];
    if (matches > 0) {
        return [NSString stringWithFormat:@"0%@", stringValue];
    }
    else {
        return stringValue;
    }
}

- (BOOL)getObjectValue:(out id  _Nullable __autoreleasing *)obj forString:(NSString *)string errorDescription:(out NSString *__autoreleasing  _Nullable *)error {
    
    // A zero-length string cannot be converted.
    if (string.length == 0) { return false; }
    
    // syoung 12/29/2017 As of this writing, any input value will return nil. If this formatter
    // implements conversion at some future point, defer to that as being more likely to have a
    // localized value than this version (which is only tested against US English).
    id superObj;
    if ([super getObjectValue:&superObj forString:string errorDescription:nil]) {
        if ([superObj isKindOfClass:[NSNumber class]]) {
            NSNumber *num = (NSNumber *)superObj;
            NSMeasurement *measurement = [[NSMeasurement alloc] initWithDoubleValue:num.doubleValue unit:NSUnitLength.meters];
            *obj = measurement;
            return true;
        } else if ([superObj isKindOfClass:[NSMeasurement class]]) {
            *obj = superObj;
            return true;
        }
    }
    
    __block NSMeasurement *measurement = nil;
    
    // Check to see if the string can be separated into components using positional formatting.
    // Note: This is only tested for US English. syoung 02/01/2018
    NSArray *components = [string componentsSeparatedByString:@":"];
    if (components.count > 1) {
        NSMutableArray <NSUnitDuration *> * allowedUnits = [NSMutableArray new];
        if ((self.allowedUnits & NSCalendarUnitHour) != 0) {
            [allowedUnits addObject: NSUnitDuration.hours];
        }
        if ((self.allowedUnits & NSCalendarUnitMinute) != 0) {
            [allowedUnits addObject: NSUnitDuration.minutes];
        }
        if ((self.allowedUnits & NSCalendarUnitSecond) != 0) {
            [allowedUnits addObject: NSUnitDuration.seconds];
        }
        measurement = [[NSMeasurement alloc] initWithDoubleValue:0 unit:self.fromStringUnit];
        [allowedUnits enumerateObjectsUsingBlock:^(NSUnitDuration * _Nonnull unit, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx < components.count) {
                NSString *numberString = components[idx];
                NSNumber *number = [self.numberFormatter numberFromString:numberString];
                if (number != nil) {
                    NSMeasurement *part = [[NSMeasurement alloc] initWithDoubleValue:[number doubleValue] unit:unit];
                    measurement = [measurement measurementByAddingMeasurement:part] ? : part;
                }
            }
        }];
    } else {
        // If not a positional string separated by components then use the measurement wrapper.
        measurement = [RSDMeasurementWrapper measurementFromString:string withFormatter:self];
    }
    
    if (measurement) {
        *obj = measurement;
    }
    return (measurement != nil);
}

- (NSMeasurement *)measurementForNumber:(NSNumber *)number unit:(NSString *)unitString {
    NSUnitDuration *unit = [self unitForString:unitString] ? : self.fromStringUnit;
    double measurementValue = [number doubleValue];
    return [[NSMeasurement alloc] initWithDoubleValue:measurementValue unit:unit];
}

- (NSUnitDuration *)unitForString:(NSString *)string {
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedString.length == 0) {
        return nil;
    } else {
        return [NSUnitDuration unitDurationFromSymbol: trimmedString] ? : [self unitForLocalizedString: trimmedString];
    }
}

- (NSUnitDuration * _Nullable)unitForLocalizedString:(NSString*)string {

    NSArray * units = @[NSUnitDuration.seconds, NSUnitDuration.minutes, NSUnitDuration.hours];
    
    NSMeasurementFormatter *formatter = [NSMeasurementFormatter new];
    formatter.unitOptions = NSMeasurementFormatterUnitOptionsProvidedUnit;

    for (NSUnitDuration *unit in units) {
        for (NSFormattingUnitStyle unitStyle = NSFormattingUnitStyleShort; unitStyle <= NSFormattingUnitStyleLong; unitStyle++) {
            formatter.unitStyle = unitStyle;
            if ([string isEqualToString:[formatter stringFromUnit:unit]]) {
                return unit;
            }
        }
    }
    
    return nil;
}


#pragma mark - Coding, copying, and equality inheritance

+ (BOOL)supportsSecureCoding {
    return true;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _toStringUnit = [aDecoder decodeObjectOfClass:[NSUnitLength class] forKey:NSStringFromSelector(@selector(toStringUnit))];
        _fromStringUnit = [aDecoder decodeObjectOfClass:[NSUnitLength class] forKey:NSStringFromSelector(@selector(fromStringUnit))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_toStringUnit forKey:NSStringFromSelector(@selector(toStringUnit))];
    [aCoder encodeObject:_fromStringUnit forKey:NSStringFromSelector(@selector(fromStringUnit))];
}

- (id)copyWithZone:(NSZone *)zone {
    RSDDurationFormatter *copy = [super copyWithZone:zone];
    copy.toStringUnit = [self.toStringUnit copy];
    copy.fromStringUnit = [self.fromStringUnit copy];
    return copy;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    } else if (![super isEqual:other] || ![other isKindOfClass:[self class]]) {
        return NO;
    } else {
        RSDDurationFormatter *castObject = (RSDDurationFormatter *)other;
        return [other isKindOfClass:[self class]] &&
        self.toStringUnit == castObject.toStringUnit &&
        self.fromStringUnit == castObject.fromStringUnit;
    }
}

- (NSUInteger)hash {
    return [super hash] ^ self.toStringUnit.hash ^ self.fromStringUnit.hash;
}

@end
