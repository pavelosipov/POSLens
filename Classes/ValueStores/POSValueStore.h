//
//  POSValueStore.h
//  POSLens
//
//  Created by Pavel Osipov on 07/02/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "POSLensValue.h"

NS_ASSUME_NONNULL_BEGIN

///
/// Represents service for atomic value updates in the underlying storage.
/// Atomicity means that modifications follow an “all or nothing” rule.
/// If something went wrong then old value left unchanged in the store.
///
@protocol POSValueStore <NSObject>

///
/// @brief      Synchronously saves specified value in the storage.
/// @discussion The store cleans underlying storage if the specified value is nil.
/// @return     YES if the store has persisted value successfully.
///
- (BOOL)saveValue:(nullable POSLensValue *)value error:(NSError **)error;

///
/// @brief      Loads value from the storage.
///
/// @discussion Nil as return value may mean that nobody persisted value yet.
///             You should check error out parameter to be sure, that no mistake
///             has occurred during value loading.
///
/// @return     POSLensValue instance if the store has loaded value successfully or nil
///             in case of empty storage or error.
///
- (nullable POSLensValue *)loadValue:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
