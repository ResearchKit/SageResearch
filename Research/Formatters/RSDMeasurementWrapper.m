//
//  RSDMeasurementWrapper.m
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

#import "include/RSDMeasurementWrapper.h"

@implementation RSDMeasurementWrapper

+ (NSMeasurement * _Nullable)measurementFromString:(NSString *)string withFormatter:(id <RSDMeasurementFormatter>)formatter {
    
    // Use regex pattern matching to find decimal numbers in the string
    // and assume that the other part of the string is a unit.
    // Note: This will only work for languages that define numbers using 0-9
    // digits. syoung 01/03/2018
    NSString *decimalSeparator = formatter.numberFormatter.decimalSeparator ? : @".";
    NSString *decimalPattern = [decimalSeparator isEqualToString:@"."] ? @"\\." : decimalSeparator;
    NSString *pattern = [NSString stringWithFormat:@"\\d*%@?\\d+", decimalPattern];
    NSString *separator = formatter.numberFormatter.groupingSeparator;
    if (separator.length > 0) {
        NSString *groupingPattern = [separator isEqualToString:@" "] ? @"\\s" : separator;
        NSString *patternWithGrouping = [NSString stringWithFormat:@"[0-9]{1,3}(%@[0-9]{3})*(%@[0-9]+)?", groupingPattern, decimalPattern];
        pattern = [NSString stringWithFormat:@"(%@)?(%@)", pattern, patternWithGrouping];
    }
    
    NSRegularExpression *numRegEx = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    NSString *unitPattern = [NSString stringWithFormat:@"[^%@\\s\\,]+", pattern];
    NSRegularExpression *unitRegEx = [[NSRegularExpression alloc] initWithPattern:unitPattern options:0 error:nil];
    if (!numRegEx || !unitRegEx) {
        NSAssert(false, @"Failed to create the regex patterns.");
        return nil;
    }
    
    NSArray<NSTextCheckingResult *> *numMatches = [numRegEx matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    NSArray<NSTextCheckingResult *> *unitMatches = [unitRegEx matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    __block NSMeasurement *measurement = nil;
    [numMatches enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *unit = unitMatches.count > idx ? [string substringWithRange:unitMatches[idx].range] : nil;
        NSString *numberString = [string substringWithRange:obj.range];
        NSNumber *number = [formatter.numberFormatter numberFromString:numberString];
        if (number != nil) {
            NSMeasurement *part = [formatter measurementForNumber:number unit:unit];
            measurement = [measurement measurementByAddingMeasurement:part] ? : part;
        }
    }];
    
    return measurement;
}

@end
