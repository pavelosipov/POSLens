//
//  POSUserDefaultsValueStore.h
//  POSLens
//
//  Created by Pavel Osipov on 23/09/2015.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSPersistentValueStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface POSUserDefaultsValueStore : POSPersistentValueStore

///
/// @brief The only designated initializer.
/// @param userDefaults UserDefaults instance.
/// @param valueKey The key for persisting value inside NSUserDefaults instance.
///
- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
                            valueKey:(NSString *)valueKey;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
