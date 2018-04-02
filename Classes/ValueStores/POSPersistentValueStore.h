//
//  POSPersistentValueStore.h
//  POSLens
//
//  Created by Pavel Osipov on 07/02/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "POSValueStore.h"

NS_ASSUME_NONNULL_BEGIN

///
/// Abstract POSValueStore protocol implementation.
/// It serializes and deserializes value and calls POSValueStore method with ready to use object instance.
///
@interface POSPersistentValueStore : NSObject <POSValueStore>

///
/// Abstract method for saving serialied value instance.
/// The method should be overrided in subclasses.
///
- (BOOL)saveData:(NSData *)data error:(NSError **)error;

///
/// Abstract method for loading serialied value instance.
/// The method should be overrided in subclasses.
/// The method checks that the loaded value conforms to POSLensValue contracts.
///
- (nullable NSData *)loadData:(NSError **)error;

///
/// Abstract method for removing value from underlying storage.
///
- (BOOL)removeData:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
