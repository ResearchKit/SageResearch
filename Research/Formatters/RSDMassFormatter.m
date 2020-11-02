//
//  RSDMassFormatter.m
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

#import "include/RSDMassFormatter.h"
#import "include/NSUnit+RSDUnitConversion.h"
#import "include/RSDMeasurementWrapper.h"

@interface RSDMassFormatter () <RSDMeasurementFormatter>
@end

@implementation RSDMassFormatter

- (void)setForInfantMassUse:(BOOL)forInfantMassUse {
    _forInfantMassUse = forInfantMassUse;
    if (forInfantMassUse) {
        self.forPersonMassUse = true;
    }
}

- (NSUnitMass *)toStringUnit {
    return _toStringUnit ? : [self defaultUnit];
}

- (NSUnitMass *)fromStringUnit {
    return _fromStringUnit ? : [self defaultUnit];
}

- (NSUnitMass *)defaultUnit {
    return NSUnitMass.kilograms;
}

- (NSLocale *)locale {
    return self.numberFormatter.locale ?: NSLocale.currentLocale;
}

- (BOOL)usesMetricSystem {
    return [[self locale] usesMetricSystem];
}

- (NSString *)stringForObjectValue:(id)obj {
    if (obj == nil) { return nil; }
    
    // convert the object to a measurement.
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
    
    if (self.isForInfantMassUse && !self.usesMetricSystem) {
        // For an infant, use a joined string that converts to lb and oz.
        double pounds = floor([measurement measurementByConvertingToUnit:NSUnitMass.poundsMass].doubleValue);
        double ounces = [measurement measurementByConvertingToUnit:NSUnitMass.ounces].doubleValue - (pounds * 16.0);
        ounces = round(1000 * ounces) / 1000;
        NSString * poundString = [self stringFromValue:pounds unit:NSMassFormatterUnitPound];
        NSString * ouncesString = [self stringFromValue:ounces unit:NSMassFormatterUnitOunce];
        NSString * joinedString = [NSString localizedStringWithFormat:@"%@, %@", poundString, ouncesString];
        return joinedString;
        
    } else {
        // Convert the value to a number and use the default impplementation from the parent class.
        NSNumber *convertedValue = @([measurement measurementByConvertingToUnit:NSUnitMass.kilograms].doubleValue);
        return [super stringForObjectValue:convertedValue];
    }
}

- (BOOL)getObjectValue:(out id  _Nullable __autoreleasing *)obj forString:(NSString *)string errorDescription:(out NSString *__autoreleasing  _Nullable *)error {
    
    // A zero-Mass string cannot be converted.
    if (string.length == 0) { return false; }
    
    // syoung 12/29/2017 As of this writing, any input value will return nil. If this formatter
    // implements conversion at some future point, defer to that as being more likely to have a
    // localized value than this version (which is only tested against US English).
    id superObj;
    if ([super getObjectValue:&superObj forString:string errorDescription:nil]) {
        if ([superObj isKindOfClass:[NSNumber class]]) {
            NSNumber *num = (NSNumber *)superObj;
            NSMeasurement *measurement = [[NSMeasurement alloc] initWithDoubleValue:num.doubleValue unit:NSUnitMass.kilograms];
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
    NSUnitMass *unit = [self unitForString:unitString] ? : self.fromStringUnit;
    double measurementValue = [number doubleValue];
    return [[NSMeasurement alloc] initWithDoubleValue:measurementValue unit:unit];
}

- (NSUnitMass *)unitForString:(NSString *)string {
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return [NSUnitMass unitMassFromSymbol: trimmedString] ? : [self unitForLocalizedString: trimmedString];
}

- (NSUnitMass * _Nullable)unitForLocalizedString:(NSString*)string {
    
    NSDictionary * unitConvertions = @{
                                       @(NSMassFormatterUnitGram) : NSUnitMass.grams,
                                       @(NSMassFormatterUnitKilogram) : NSUnitMass.kilograms,
                                       @(NSMassFormatterUnitOunce) : NSUnitMass.ounces,
                                       @(NSMassFormatterUnitPound) : NSUnitMass.poundsMass,
                                       @(NSMassFormatterUnitStone) : NSUnitMass.stones};
    
    RSDMassFormatter *formatter = [self copy];
    formatter.unitStyle = NSFormattingUnitStyleLong;
    
    for (NSNumber *key in unitConvertions.allKeys) {
        NSMassFormatterUnit formatterUnit = key.integerValue;
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
        _forInfantMassUse = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(isForInfantMassUse))];
        _toStringUnit = [aDecoder decodeObjectOfClass:[NSUnitMass class] forKey:NSStringFromSelector(@selector(toStringUnit))];
        _fromStringUnit = [aDecoder decodeObjectOfClass:[NSUnitMass class] forKey:NSStringFromSelector(@selector(fromStringUnit))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeBool:_forInfantMassUse forKey:NSStringFromSelector(@selector(isForInfantMassUse))];
    [aCoder encodeObject:_toStringUnit forKey:NSStringFromSelector(@selector(toStringUnit))];
    [aCoder encodeObject:_fromStringUnit forKey:NSStringFromSelector(@selector(fromStringUnit))];
}

- (id)copyWithZone:(NSZone *)zone {
    RSDMassFormatter *copy = [super copyWithZone:zone];
    copy.forInfantMassUse = self.isForInfantMassUse;
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
        RSDMassFormatter *castObject = (RSDMassFormatter *)other;
        return [other isKindOfClass:[self class]] &&
        self.isForInfantMassUse == castObject.isForInfantMassUse &&
        self.toStringUnit == castObject.toStringUnit &&
        self.fromStringUnit == castObject.fromStringUnit;
    }
}

- (NSUInteger)hash {
    return [super hash] ^ self.isForInfantMassUse ^ self.toStringUnit.hash ^ self.fromStringUnit.hash;
}

@end

