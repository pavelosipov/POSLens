//
//  POSEquality.h
//  POSLens
//
//  Created by Pavel Osipov on 18/07/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

NS_INLINE BOOL POSObjectsAreEqual(id<NSObject> _Nullable l, id<NSObject> _Nullable r) {
    return r == nil ? l == nil : [l isEqual:r];
}

NS_INLINE BOOL POSStringsAreEqual(NSString * _Nullable l, NSString * _Nullable r) {
    return r == nil ? l == nil : [l isEqualToString:r];
}

NS_INLINE BOOL POSArraysAreEqual(NSArray * _Nullable l, NSArray * _Nullable r) {
    return r == nil ? l == nil : [l isEqualToArray:r];
}

NS_INLINE BOOL POSDictionariesAreEqual(NSDictionary * _Nullable l, NSDictionary * _Nullable r) {
    return r == nil ? l == nil : [l isEqualToDictionary:r];
}

NS_INLINE BOOL POSOrderedSetsAreEqual(NSOrderedSet * _Nullable l, NSOrderedSet * _Nullable r) {
    return r == nil ? l == nil : [l isEqualToOrderedSet:r];
}

NS_ASSUME_NONNULL_END
