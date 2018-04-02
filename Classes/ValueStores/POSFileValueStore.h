//
//  POSFileLensStore.h
//  POSLens
//
//  Created by Pavel Osipov on 13/10/2015.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSPersistentValueStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface POSFileValueStore : POSPersistentValueStore

/// The designated initializer.
- (instancetype)initWithFilePath:(NSString *)filePath;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
