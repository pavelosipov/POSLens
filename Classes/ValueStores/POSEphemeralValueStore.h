//
//  POSEphemeralValueStore.h
//  POSLens
//
//  Created by Pavel Osipov on 26/10/2015.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSValueStore.h"

NS_ASSUME_NONNULL_BEGIN

/// In-memory value store.
@interface POSEphemeralValueStore : NSObject <POSValueStore>

- (instancetype)initWithValue:(nullable POSLensValue *)value;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
