//
//  POSLens.m
//  POSLens
//
//  Created by Pavel Osipov on 06/02/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "POSLens.h"

#import "POSEphemeralValueStore.h"
#import "POSFileValueStore.h"
#import "POSKeychainValueStore.h"
#import "POSUserDefaultsValueStore.h"

#import "NSError+POSLens.h"

NS_ASSUME_NONNULL_BEGIN

@interface POSPropertyLens : POSMutableLens

@property (nonatomic, readonly) POSMutableLens<POSLensValue *> *parent;
@property (nonatomic, readonly) NSString *key;

- (instancetype)initWithParent:(POSMutableLens<POSLensValue *> *)parent
                  defaultValue:(nullable POSLensValue *)defaultValue
                           key:(NSString *)key NS_DESIGNATED_INITIALIZER;

@end

#pragma mark -

@interface POSLens ()
@property (nonatomic, readonly) NSString *keyPath;
@property (nonatomic, readonly, nullable) POSLensValue *defaultValue;
@end

@interface POSMutableLens ()
@property (nonatomic, readonly) RACSignal<POSLensValue *> *recursiveValueUpdates;
@end

//
// Implementation for all interface methods of  provided by subclasses of POSLens and POSMutableLens.
// These classes exist because there is no template protocol concept in Objective-C language.
// POSLens library doesn't create direct instances of these classes.
//
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation POSLens
@dynamic keyPath;
@dynamic value;
@dynamic valueUpdates;

- (instancetype)init {
    return [self initWithDefaultValue:nil];
}

- (instancetype)initWithDefaultValue:(nullable POSLensValue *)defaultValue {
    if (self = [super init]) {
        _defaultValue = defaultValue;
    }
    return self;
}

- (instancetype)objectForKeyedSubscript:(NSString *)key {
    return [self lensForKey:key defaultValue:nil];
}

- (instancetype)lensForKey:(NSString *)key {
    return [self lensForKey:key defaultValue:nil];
}

@end

@implementation POSMutableLens
@dynamic recursiveValueUpdates;

- (POSMutableLens *)lensForKey:(NSString *)key defaultValue:(nullable POSLensValue *)defaultValue {
    POS_CHECK(key);
    return [[POSPropertyLens alloc] initWithParent:self defaultValue:defaultValue key:key];
}

- (instancetype)lensForKeyPath:(NSString *)keyPath {
    POS_CHECK(keyPath);
    POSMutableLens *lens = self;
    NSArray<NSString *> *keys = [keyPath componentsSeparatedByString:@"."];
    for (NSInteger i = 0, n = keys.count; i < n; ++i) {
        lens = [[POSPropertyLens alloc] initWithParent:lens defaultValue:nil key:keys[i]];
    }
    return lens;
}

- (BOOL)updateValue:(nullable id)value error:(NSError **)error {
    return [self updateValueWithBlock:^id _Nullable(id  _Nullable currentValue, NSError **error) {
        return value;
    } error:error];
}

- (BOOL)updateValue:(nullable POSLensValue *)value atKey:(NSString *)key error:(NSError **)error {
    return [[self lensForKey:key] updateValue:value error:error];
}

- (BOOL)updateValue:(nullable POSLensValue *)value atKeyPath:(NSString *)keyPath error:(NSError **)error {
    return [[self lensForKeyPath:keyPath] updateValue:value error:error];
}

- (BOOL)updateValueAtKey:(NSString *)key
               withBlock:(POSLensValue * _Nullable (^)(POSLensValue * _Nullable, NSError **))block
                   error:(NSError **)error {
    return [[self lensForKey:key] updateValueWithBlock:block error:error];
}

- (BOOL)updateValueAtKeyPath:(NSString *)key
                   withBlock:(POSLensValue * _Nullable (^)(POSLensValue * _Nullable, NSError **))block
                       error:(NSError **)error {
    return [[self lensForKeyPath:key] updateValueWithBlock:block error:error];
}

- (BOOL)removeValue:(NSError **)error {
    return [self updateValueWithBlock:^id _Nullable(id  _Nullable currentValue, NSError **error) {
        return nil;
    } error:error];
}

@end

#pragma clang diagnostic pop

#pragma mark -

@implementation POSPropertyLens

- (instancetype)initWithParent:(POSMutableLens<POSLensValue *> *)parent
                  defaultValue:(nullable POSLensValue *)defaultValue
                           key:(NSString *)key {
    POS_CHECK(parent);
    POS_CHECK(key);
    if (self = [super initWithDefaultValue:defaultValue]) {
        _parent = parent;
        _key = [key copy];
    }
    return self;
}

#pragma mark - POSLens

- (nullable id)value {
    id value = [_parent.value pos_valueForKey:_key];
    return value ?: self.defaultValue;
}

- (RACSignal *)valueUpdates {
    return [self.recursiveValueUpdates distinctUntilChanged];
}

- (RACSignal<POSLensValue *> *)recursiveValueUpdates {
    NSString *key = _key;
    POSLensValue *defaultValue = self.defaultValue;
    return [_parent.recursiveValueUpdates map:^id _Nullable(POSLensValue * _Nullable parentValue) {
        id value = [parentValue pos_valueForKey:key];
        return value ?: defaultValue;
    }];
}

- (NSString *)keyPath {
    return [_parent.keyPath stringByAppendingString:[NSString stringWithFormat:@".%@", _key]];
}

#pragma mark - POSMutableLens

- (BOOL)resetValue:(NSError **)error {
    return [_parent resetValue:error];
}

- (BOOL)updateValueWithBlock:(POSLensValue * _Nullable(^)(POSLensValue * _Nullable, NSError **error))updateBlock
                       error:(NSError **)error {
    POS_CHECK(updateBlock);
    @weakify(self);
    return [_parent updateValueWithBlock:^POSLensValue * _Nullable(POSLensValue * _Nullable parentValue, NSError **error) {
        @strongify(self); // self is never nil because of synchronous nature of updateBlock.
        id currentValue = [parentValue pos_valueForKey:self->_key];
        id updatedValue = updateBlock(currentValue, error);
        if (*error != nil) {
            return parentValue;
        }
        if (updatedValue == currentValue || [updatedValue isEqual:currentValue]) {
            return parentValue;
        } else if (parentValue != nil) {
            return [parentValue pos_setValue:updatedValue forKey:self->_key];
        } else if (parentValue == nil && self.parent.defaultValue != nil) {
            return [self.parent.defaultValue pos_setValue:updatedValue forKey:self->_key];
        }
        POSAssignError(error, [NSError pos_lensErrorWithFormat:
                               @"Parent of property %@ has neither value or default value.", self.keyPath]);
        return parentValue;
    } error:error];
}

@end

#pragma mark -

@interface POSRootLens : POSMutableLens
@property (nonatomic, readonly) dispatch_queue_t syncQueue;
@property (nonatomic, readonly) id<POSValueStore> store;
@property (nonatomic, nullable) POSLensValue *currentValue;
@property (nonatomic, readonly) RACSubject<POSLensValue *> *valueUpdatesSubject;
@end

@implementation POSRootLens

- (instancetype)initWithDefaultValue:(nullable POSLensValue *)defaultValue
                        currentValue:(nullable POSLensValue *)currentValue
                               store:(id<POSValueStore>)store {
    POS_CHECK(store);
    if (self = [super initWithDefaultValue:defaultValue]) {
        _syncQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _store = store;
        _currentValue = currentValue;
        _valueUpdatesSubject = [RACSubject subject];
    }
    return self;
}

#pragma mark - POSLens

- (nullable id)value {
    __block POSLensValue *value = nil;
    dispatch_sync(_syncQueue, ^{
        value = self->_currentValue ?: self.defaultValue;
    });
    return value;
}

- (RACSignal *)valueUpdates {
    return [self.recursiveValueUpdates distinctUntilChanged];
}

- (RACSignal<POSLensValue *> *)recursiveValueUpdates {
    return [[_valueUpdatesSubject
        takeUntil:self.rac_willDeallocSignal]
        startWith:_currentValue];
}

- (NSString *)keyPath {
    return @"root";
}

#pragma mark - POSMutableLens

- (BOOL)resetValue:(NSError **)error {
    __auto_type updateBlock = ^POSLensValue * _Nullable(POSLensValue * _Nullable value, BOOL *flush, NSError **error) {
        *flush = NO;
        return [self->_store loadValue:error];
    };
    return [self updateCurrentValueWithBlock:updateBlock error:error];
}

- (BOOL)updateValueWithBlock:(POSLensValue *  _Nullable (^)(POSLensValue * _Nullable, NSError **error))block
                       error:(NSError **)error {
    __auto_type updateBlock = ^POSLensValue * _Nullable(POSLensValue * _Nullable value, BOOL *flush, NSError **error) {
        return block(value, error);
    };
    return [self updateCurrentValueWithBlock:updateBlock error:error];
}

- (BOOL)updateCurrentValueWithBlock:(POSLensValue *  _Nullable (^)(POSLensValue * _Nullable, BOOL *flush, NSError **error))updateBlock
                              error:(NSError **)error {
    POS_CHECK(updateBlock);
    __block BOOL flush = YES;
    __block BOOL updated = NO;
    __block NSError *updateError = nil;
    __block POSLensValue *updatedValue = _currentValue;
    dispatch_barrier_sync(_syncQueue, ^{
        updatedValue = updateBlock(updatedValue, &flush, &updateError);
        if (updateError == nil && updatedValue != self->_currentValue && ![updatedValue isEqual:self->_currentValue]) {
            updated = flush ? [self->_store saveValue:updatedValue error:&updateError] : YES;
        }
        if (updated) {
            self.currentValue = updatedValue;
        }
    });
    POSAssignError(error, updateError);
    if (updated) {
        [_valueUpdatesSubject sendNext:updatedValue];
    }
    return updateError == nil;
}

@end

#pragma mark -

@implementation POSLens (Factory)

+ (instancetype)lensWithValue:(nullable POSLensValue *)value {
    return [self
            lensWithDefaultValue:nil
            store:[[POSEphemeralValueStore alloc] initWithValue:value]
            error:nil];
}

+ (nullable instancetype)lensWithDefaultValue:(nullable POSLensValue *)value
                                        store:(id<POSValueStore>)store
                                        error:(NSError **)error {
    NSError *loadError;
    POSLensValue *currentValue = [store loadValue:&loadError];
    if (loadError != nil) {
        POSAssignError(error, loadError);
        return nil;
    }
    return [[POSRootLens alloc] initWithDefaultValue:value currentValue:currentValue store:store];
}

+ (nullable instancetype)lensWithDefaultValue:(nullable POSLensValue *)value
                                     filePath:(NSString *)filePath
                                        error:(NSError **)error {
    return [self
            lensWithDefaultValue:value
            store:[[POSFileValueStore alloc] initWithFilePath:filePath]
            error:error];
}

+ (nullable instancetype)lensWithDefaultValue:(nullable POSLensValue *)value
                              keychainService:(NSString *)service
                                     valueKey:(NSString *)valueKey
                                        error:(NSError **)error {
    return [self
            lensWithDefaultValue:value
            store:[[POSKeychainValueStore alloc] initWithValueKey:valueKey service:service accessGroup:nil]
            error:error];
}

+ (nullable instancetype)lensWithDefaultValue:(nullable POSLensValue *)value
                                 userDefaults:(NSUserDefaults *)userDefaults
                                     valueKey:(NSString *)valueKey
                                        error:(NSError **)error {
    return [self
            lensWithDefaultValue:value
            store:[[POSUserDefaultsValueStore alloc] initWithUserDefaults:userDefaults valueKey:valueKey]
            error:error];
}

@end

NS_ASSUME_NONNULL_END
