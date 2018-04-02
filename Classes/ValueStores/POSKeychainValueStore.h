//
//  POSKeychainValueStore.h
//  POSLens
//
//  Created by Pavel Osipov on 23/10/2015.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSPersistentValueStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface POSKeychainValueStore : POSPersistentValueStore

///
/// The convenience initializer.
/// @param valueKey `kSecAttrAccount` argument in keychain query which represents value's account name.
/// @param service  `kSecAttrService` argument in keychain query which represents the service associated with value.
///
- (instancetype)initWithValueKey:(NSString *)valueKey
                         service:(NSString *)service;

///
/// The designated initializer.
/// @param valueKey    `kSecAttrAccount` argument in keychain query which represents value's account name.
/// @param service     `kSecAttrService` argument in keychain query which represents the service associated with value.
/// @param accessGroup `kSecAttrAccessGroup` argument in keychain query which represents the access group a value is in.
///
- (instancetype)initWithValueKey:(NSString *)valueKey
                         service:(NSString *)service
                     accessGroup:(nullable NSString *)accessGroup;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
