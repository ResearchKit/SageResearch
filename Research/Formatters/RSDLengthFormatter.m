//
//  RSDLengthFormatter.m
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

#import "include/RSDLengthFormatter.h"
#import "include/NSUnit+RSDUnitConversion.h"
#import "include/RSDMeasurementWrapper.h"

static const NSString * RSDShortFeetUnitString = @"′";
static const NSString * RSDShortFeetUnitAlternativeString = @"'";

static const NSString * RSDShortInchUnitAlternativeString = @"\"";
static const NSString * RSDShortInchUnitString = @"″";

@interface RSDLengthFormatter () <RSDMeasurementFormatter>
@end

@implementation RSDLengthFormatter

- (void)setForChildHeightUse:(BOOL)forChildHeightUse {
    _forChildHeightUse = forChildHeightUse;
    if (forChildHeightUse) {
        self.forPersonHeightUse = true;
    }
}

- (NSUnitLength *)toStringUnit {
    return _toStringUnit ? : [self defaultUnit];
}

- (NSUnitLength *)fromStringUnit {
    return _fromStringUnit ? : [self defaultUnit];
}

- (NSUnitLength *)defaultUnit {
    if (self.isForPersonHeightUse) {
        return NSUnitLength.centimeters;
    } else {
        return NSUnitLength.meters;
    }
}

- (NSLocale *)locale {
    return self.numberFormatter.locale ? : NSLocale.currentLocale;
}

- (BOOL)usesMetricSystem {
    return [[self locale] usesMetricSystem];
}

- (NSString *)stringForObjectValue:(id)obj {
    if (obj == nil) { return nil; }
    
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
        return nil;
    }

    if (self.isForChildHeightUse && !self.usesMetricSystem) {
        // Create a temporary formatter with the same number formatter and unit style
        // then return the string in inches.
        NSLengthFormatter *formatter = [NSLengthFormatter new];
        formatter.unitStyle = self.unitStyle;
        formatter.numberFormatter = self.numberFormatter;
        double inches = [measurement measurementByConvertingToUnit:NSUnitLength.inches].doubleValue;
        return [formatter stringFromValue:inches unit: NSLengthFormatterUnitInch];
        
    } else {
        // Convert the value to a number and use the default impplementation from the parent class
        NSNumber *convertedValue = @([measurement measurementByConvertingToUnit:NSUnitLength.meters].doubleValue);
        return [super stringForObjectValue:convertedValue];
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
    
    NSMeasurement *measurement = [RSDMeasurementWrapper measurementFromString:string withFormatter:self];
    if (measurement) {
        *obj = measurement;
    }
    return (measurement != nil);
}

- (NSMeasurement *)measurementForNumber:(NSNumber *)number unit:(NSString *)unitString {
    NSUnitLength *unit = [self unitForString:unitString] ? : self.fromStringUnit;
    double measurementValue = [number doubleValue];
    return [[NSMeasurement alloc] initWithDoubleValue:measurementValue unit:unit];
}

- (NSUnitLength *)unitForString:(NSString *)string {
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimmedString.length == 0) {
        return nil;
    } else if ([trimmedString isEqualToString:(NSString *)RSDShortFeetUnitString] ||
               [trimmedString isEqualToString:(NSString *)RSDShortFeetUnitAlternativeString]) {
        return NSUnitLength.feet;
    } else if ([trimmedString isEqualToString:(NSString *)RSDShortInchUnitString] ||
               [trimmedString isEqualToString:(NSString *)RSDShortInchUnitAlternativeString]) {
        return NSUnitLength.inches;
    } else {
        return [NSUnitLength unitLengthFromSymbol: trimmedString] ? : [self unitForLocalizedString: trimmedString];
    }
}

- (NSUnitLength * _Nullable)unitForLocalizedString:(NSString*)string {
    
    NSDictionary * unitConvertions = @{
                                       @(NSLengthFormatterUnitInch) : NSUnitLength.inches,
                                       @(NSLengthFormatterUnitFoot) : NSUnitLength.feet,
                                       @(NSLengthFormatterUnitYard) : NSUnitLength.yards,
                                       @(NSLengthFormatterUnitMile) : NSUnitLength.miles,
                                       @(NSLengthFormatterUnitMeter) : NSUnitLength.meters,
                                       @(NSLengthFormatterUnitKilometer) : NSUnitLength.kilometers,
                                       @(NSLengthFormatterUnitCentimeter) : NSUnitLength.centimeters,
                                       @(NSLengthFormatterUnitMillimeter) : NSUnitLength.millimeters };
    
    RSDLengthFormatter *formatter = [self copy];
    formatter.unitStyle = NSFormattingUnitStyleLong;
    
    for (NSNumber *key in unitConvertions.allKeys) {
        NSLengthFormatterUnit formatterUnit = key.integerValue;
        if ([string isEqualToString:[formatter unitStringFromValue:1 unit:formatterUnit]] ||
            [string isEqualToString:[formatter unitStringFromValue:100 unit:formatterUnit]]) {
            return unitConvertions[key];
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
        _forChildHeightUse = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(isForChildHeightUse))];
        _toStringUnit = [aDecoder decodeObjectOfClass:[NSUnitLength class] forKey:NSStringFromSelector(@selector(toStringUnit))];
        _fromStringUnit = [aDecoder decodeObjectOfClass:[NSUnitLength class] forKey:NSStringFromSelector(@selector(fromStringUnit))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeBool:_forChildHeightUse forKey:NSStringFromSelector(@selector(isForChildHeightUse))];
    [aCoder encodeObject:_toStringUnit forKey:NSStringFromSelector(@selector(toStringUnit))];
    [aCoder encodeObject:_fromStringUnit forKey:NSStringFromSelector(@selector(fromStringUnit))];
}

- (id)copyWithZone:(NSZone *)zone {
    RSDLengthFormatter *copy = [super copyWithZone:zone];
    copy.forChildHeightUse = self.isForChildHeightUse;
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
        RSDLengthFormatter *castObject = (RSDLengthFormatter *)other;
        return [other isKindOfClass:[self class]] &&
            self.isForChildHeightUse == castObject.isForChildHeightUse &&
            self.toStringUnit == castObject.toStringUnit &&
            self.fromStringUnit == castObject.fromStringUnit;
    }
}

- (NSUInteger)hash {
    return [super hash] ^ self.isForChildHeightUse ^ self.toStringUnit.hash ^ self.fromStringUnit.hash;
}

@end
