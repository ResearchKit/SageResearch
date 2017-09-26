//
//  RSDClassTypeMap.m
//  ResearchSuite
//
//  Copyright © 2016-2017 Sage Bionetworks. All rights reserved.
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

#import "RSDClassTypeMap.h"

@interface RSDClassTypeMap ()

@property (nonatomic) NSMutableDictionary<NSString *, Class> *map;

@end

@implementation RSDClassTypeMap

static id _defaultInstance;

+ (instancetype)sharedMap {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultInstance = [[self alloc] init];
    });
    return _defaultInstance;
}

+ (void)setSharedMap:(RSDClassTypeMap *)sharedMap NS_REFINED_FOR_SWIFT {
    _defaultInstance = sharedMap;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Set the default value for the classType key into a dictionary
        _classTypeKey = @"classType";
        
        // Set the default formatter for a timestamp
        _timestampFormatter = [[NSDateFormatter alloc] init];
        [_timestampFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [_timestampFormatter setLocale:enUSPOSIXLocale];

        // Set the formatter for a date-only string representation
        _dateOnlyFormatter = [_timestampFormatter copy];
        [_dateOnlyFormatter setDateFormat:@"yyyy-MM-dd"];
        
        // Set the formatter for a time-only string representation
        _timeOnlyFormatter = [_timestampFormatter copy];
        [_timeOnlyFormatter setDateFormat:@"HH:mm:ss"];
    }
    return self;
}

- (Class)classForClassKey:(NSString *)classKey {
    return _map[classKey];
}

- (void)mergeWithDictionary: (NSDictionary <NSString *, Class> *)dictionary {
    [_map addEntriesFromDictionary: dictionary];
}

- (id)objectWithDictionaryRepresentation:(NSDictionary *)dictionary error:(NSError **)error {
    NSString *classTypeName = dictionary[self.classTypeKey];
    if (![classTypeName isKindOfClass:[NSString class]]) {
        if (error) {
            *error = [NSError errorWithDomain:@"RSDClassTypeMapError" code:RSDClassTypeMapErrorInvalidKey userInfo:nil];
        }
        return nil;
    }
    Class classType = [self classForClassKey:classTypeName];
    if (classType == nil) {
        if (error) {
            *error = [NSError errorWithDomain:@"RSDClassTypeMapError" code:RSDClassTypeMapErrorNotFound userInfo:nil];
        }
        return nil;
    }
    return [self _objectWithDictionaryRepresentation:dictionary classType:classType error:error];
}

- (id)_objectWithDictionaryRepresentation:(NSDictionary *)dictionary classType:(Class)classType error:(NSError **)error {
    id allocatedObject = [classType alloc];
    if (![allocatedObject respondsToSelector:@selector(initWithDictionaryRepresentation:)]) {
        if (error) {
            *error = [NSError errorWithDomain:@"RSDClassTypeMapError" code:RSDClassTypeMapErrorNotDictionaryRepresentable userInfo:nil];
        }
        return nil;
    }
    return [allocatedObject initWithDictionaryRepresentation:dictionary];
}

- (id)objectWithDictionaryRepresentation:(NSDictionary *)dictionary defaultClassType:(Class)classType error:(NSError **)error {
    id obj = [self objectWithDictionaryRepresentation:dictionary error:nil];
    if (obj) {
        return obj;
    }
    return [self _objectWithDictionaryRepresentation:dictionary classType:classType error:error];
}

- (id)objectWithDictionaryRepresentation:(NSDictionary *)dictionary defaultClassKey:(NSString *)classKey error:(NSError ** _Nullable)error {
    Class classType = [self classForClassKey:classKey];
    if (classType == nil) {
        if (error) {
            *error = [NSError errorWithDomain:@"RSDClassTypeMapError" code:RSDClassTypeMapErrorNotFound userInfo:nil];
        }
        return nil;
    }
    return [self objectWithDictionaryRepresentation:dictionary defaultClassType:classType error:error];
}

@end
