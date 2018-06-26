//
//  POSEphemeralValueStore.m
//  POSLens
//
//  Created by Pavel Osipov on 26/10/2015.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSEphemeralValueStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface POSEphemeralValueStore ()
@property (nonatomic, nullable) POSLensValue *value;
@end

@implementation POSEphemeralValueStore

- (instancetype)initWithValue:(nullable POSLensValue *)value {
    if (self = [super init]) {
        _value = [value copy];
    }
    return self;
}

- (BOOL)saveValue:(nullable POSLensValue *)value error:(NSError **)error {
    self.value = [value copy];
    return YES;
}

- (nullable POSLensValue *)loadValue:(NSError **)error {
    return _value;
}

@end

NS_ASSUME_NONNULL_END
