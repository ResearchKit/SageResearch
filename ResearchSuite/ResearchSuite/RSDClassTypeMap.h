//
//  RSDClassTypeMap.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A protocol used to create an object instance from a dictionary representable or encode an object using a dictionary.
 */
@protocol RSDDictionaryRepresentable <NSObject>

- (instancetype)initWithDictionaryRepresentation:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryRepresentation;

@end

typedef NS_ENUM( NSInteger, RSDClassTypeMapError) {
    RSDClassTypeMapErrorInvalidKey = 1,
    RSDClassTypeMapErrorNotFound,
    RSDClassTypeMapErrorNotDictionaryRepresentable
};

@interface RSDClassTypeMap : NSObject

+ (instancetype)sharedMap NS_REFINED_FOR_SWIFT;
+ (void)setSharedMap:(RSDClassTypeMap *)sharedMap NS_REFINED_FOR_SWIFT;

/**
 The key in a dictionary that can be used to get the class type to instantiate for a given object. By default, this property equals "classType". The string key in the class type field is mapped using `classForClassType:` to return the `Class` mapped to this key.
 
 For example:
     {   "classType" : "instructionStep",
         "title" : "Hello, World!" }
 */
@property (nonatomic) NSString * classTypeKey;

/**
 Date formatter to use when converting a date to/from a string in a json dictionary.
 */
@property (nonatomic) NSDateFormatter * dateOnlyFormatter;

/**
 Date formatter to use when converting a time to/from a string in a json dictionary.
 */
@property (nonatomic) NSDateFormatter * timeOnlyFormatter;

/**
 Date formatter to use when converting a date and time to/from a string in a json dictionary.
 */
@property (nonatomic) NSDateFormatter * timestampFormatter;

/**
 The class that maps to a given key.
 
 @param classKey   The string representing the key into the class mapping.
 
 @returns           The class (if found).
 */
- (Class _Nullable)classForClassKey:(NSString *)classKey NS_SWIFT_NAME(class(for:));

/**
 Merge the given dictionary of key/class mappings into the existing dictionary. This will override the current class map if there is a conflict.
 
 @param dictionary  The dictionary to merge into the class mapping.
 */
- (void)mergeWithDictionary: (NSDictionary <NSString *, Class> *)dictionary NS_SWIFT_NAME(merge(with:));

/**
 Instantiate an object from the given dictionary. This will return `nil` if the dictionary does not include a value for the `classTypeKey`.
 
 @param dictionary  The dictionary to use to instantiate the object.
 @param error       The error returned when attempting to create an object from this dictionary.
 
 @return            The object returned (if any).
 */
- (id _Nullable)objectWithDictionaryRepresentation:(NSDictionary *)dictionary error:(NSError ** _Nullable)error NS_SWIFT_NAME(object(with:));

/**
 Instantiate an object from the given dictionary. This will check for a `classType` within the dictionary and if not found, will default to the default class type.
 
 @param dictionary   The dictionary to use to instantiate the object.
 @param classType    The default class to use if there isn't a `classType` key in the dictionary.
 @param error        The error returned when attempting to create an object from this dictionary.
 
 @return            The object returned (if any).
 */
- (id _Nullable)objectWithDictionaryRepresentation:(NSDictionary *)dictionary defaultClassType:(Class)classType error:(NSError ** _Nullable)error NS_SWIFT_NAME(object(with:defaultType:));

/**
 Instantiate an object from the given dictionary. This will check for a `classType` within the dictionary and if not found, will default to the default class type.
 
 @param dictionary   The dictionary to use to instantiate the object.
 @param classKey     The default class type key to use if there isn't a `classType` key in the dictionary.
 @param error        The error returned when attempting to create an object from this dictionary.
 
 @return            The object returned (if any).
 */
- (id _Nullable)objectWithDictionaryRepresentation:(NSDictionary *)dictionary defaultClassKey:(NSString *)classKey error:(NSError ** _Nullable)error NS_SWIFT_NAME(object(with:defaultKey:));

@end

NS_ASSUME_NONNULL_END
