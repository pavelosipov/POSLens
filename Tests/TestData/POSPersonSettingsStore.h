//
//  POSPersonStore.h
//  POSLensTests
//
//  Created by Pavel Osipov on 08/02/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "POSPersistentValueStore.h"

NS_ASSUME_NONNULL_BEGIN

@class POSPersonSettings;

@interface POSPersonSettingsStore : POSPersistentValueStore

- (instancetype)initWithSettings:(nullable POSPersonSettings *)settings;

@end

NS_ASSUME_NONNULL_END
