//
//  POSLensValue.m
//  POSLens
//
//  Created by Pavel Osipov on 06/02/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "POSLensValue.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSObject (POSLens)

- (nullable id)pos_valueForKey:(NSString *)key {
    return [self valueForKeyPath:key];
}

- (instancetype)pos_setValue:(nullable id)value forKey:(NSString *)key {
    NSObject *selfCopy = [self copy];
    [selfCopy setValue:value forKeyPath:key];
    return selfCopy;
}

@end

#pragma mark -

@implementation NSDictionary (POSLens)

- (nullable id)pos_valueForKey:(NSString *)key {
    return self[key];
}

- (instancetype)pos_setValue:(nullable id)value forKey:(NSString *)key {
    NSMutableDictionary *selfCopy = [self mutableCopy];
    selfCopy[key] = value;
    return [selfCopy copy];
}

@end

NS_ASSUME_NONNULL_END
