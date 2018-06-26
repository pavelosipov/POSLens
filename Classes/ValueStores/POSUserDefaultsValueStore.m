//
//  POSUserDefaultsValueStore.m
//  POSLens
//
//  Created by Pavel Osipov on 23/09/2015.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSUserDefaultsValueStore.h"
#import <POSErrorHandling/POSErrorHandling.h>

NS_ASSUME_NONNULL_BEGIN

@interface POSUserDefaultsValueStore ()
@property (nonatomic, readonly) NSUserDefaults *store;
@property (nonatomic, readonly) NSString *valueKey;
@end

@implementation POSUserDefaultsValueStore

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
                            valueKey:(NSString *)valueKey {
    POS_CHECK(userDefaults);
    POS_CHECK(valueKey);
    if (self = [super init]) {
        _store = userDefaults;
        _valueKey = [valueKey copy];
    }
    return self;
}

#pragma mark - POSPersistentValueStore

- (BOOL)saveData:(NSData *)data error:(NSError **)error {
    POS_CHECK(data);
    [_store setObject:data forKey:_valueKey];
    if (![_store synchronize]) {
        POSAssignError(error, [NSError pos_systemErrorWithFormat:@"Failed to synchronize NSUserDefaults."]);
        return NO;
    }
    return YES;
}

- (nullable NSData *)loadData:(NSError **)error {
    id data = [_store objectForKey:_valueKey];
    if (!data) {
        return nil;
    }
    if (![data isKindOfClass:NSData.class]) {
        POSAssignError(error, [NSError pos_internalErrorWithFormat:
                               @"Unexpected object at key '%@' in NSUserDefaults: %@", _valueKey, data]);
        return nil;
    }
    return data;
}

- (BOOL)removeData:(NSError **)error {
    [_store removeObjectForKey:_valueKey];
    [_store synchronize];
    return YES;
}

@end

NS_ASSUME_NONNULL_END
