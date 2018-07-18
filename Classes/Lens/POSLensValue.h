//
//  POSLensValue.h
//  POSLens
//
//  Created by Pavel Osipov on 06/02/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///
/// The lens is functional programming concept for modifying immutable objects. In particular,
/// POSLensPolicy is called like that because it allows to focus on a specific part of an object
/// structure, and consequently to act on that part, like retrieving it or modifying it causing
/// a modification of the whole graph of objects.
///
/// See more at https://goo.gl/NFmePx
///
@protocol POSLensPolicy <NSObject>

///
/// @brief   Extracts a value from the object's property.
/// @param   key KVC field for NSObject instance or a keyed subscript for NSDictionary.
/// @returns Actual value or nil if there is neither property with specified key or the owner of the value is nil.
///
- (nullable id)pos_valueForKey:(NSString *)key;

///
/// @brief   The method modifies value in two steps. Firstly it clones all of its direct
///          and indirect parents. Secondly it sets a new value to the fresh copy of its owner.
///          The nil argument means that the actual value should be removed.
///
/// @param   value New value of the object.
/// @param   key   KVC field for NSObject instance or a keyed subscript for NSDictionary.
///
/// @returns Updated value or nil if there is neither property with specified key or the owner of the value is nil.
///
- (instancetype)pos_setValue:(nullable id)value forKey:(NSString *)key;

@end

#pragma mark -

/// A contract for the immutable objects.
typedef NSObject<POSLensPolicy, NSCopying> POSLensValue;

/// A contract for the persistable immutable objects.
typedef NSObject<POSLensPolicy, NSCopying, NSCoding> POSLensPersistableValue;

#pragma mark -

@interface NSObject (POSLens) <POSLensPolicy>
@end

#pragma mark -

@interface NSDictionary (POSLens) <POSLensPolicy>
@end

NS_ASSUME_NONNULL_END
