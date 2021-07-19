//
//  POSPersistentValueStore.m
//  POSLens
//
//  Created by Pavel Osipov on 07/02/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "POSPersistentValueStore.h"
#import <POSErrorHandling/POSErrorHandling.h>

NS_ASSUME_NONNULL_BEGIN

@implementation POSPersistentValueStore

#pragma mark - POSValueStore

- (BOOL)saveValue:(nullable POSLensValue<NSCoding> *)value error:(NSError **)error {
    @try {
        if (value == nil) {
            return [self removeData:error];
        }
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:NO];
        [archiver setOutputFormat:NSPropertyListBinaryFormat_v1_0];
        [archiver encodeRootObject:value];
        [archiver finishEncoding];
        return [self saveData:archiver.encodedData error:error];
    } @catch (NSException *exception) {
        POSAssignError(error, [NSError pos_systemErrorWithFormat:exception.reason]);
        return NO;
    }
}

- (nullable POSLensValue<NSCoding> *)loadValue:(NSError **)error {
    NSData *data = [self loadData:error];
    if (!data) {
        return nil;
    }
    NSError *unarchiveError = nil;
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:&unarchiveError];
    [unarchiver setRequiresSecureCoding:NO];
    POSLensValue<NSCoding> *value = [unarchiver decodeTopLevelObjectAndReturnError:&unarchiveError];
    [unarchiver finishDecoding];
    if (!value) {
        POSAssignError(error, [NSError pos_systemErrorWithReason:unarchiveError]);
        return nil;
    }
    if (![value conformsToProtocol:@protocol(POSLensPolicy)]) {
        POSAssignError(error, [NSError pos_systemErrorWithFormat:@"Value doesn't conform to POSLensPolicy"]);
        return nil;
    }
    if (![value conformsToProtocol:@protocol(NSCopying)]) {
        POSAssignError(error, [NSError pos_systemErrorWithFormat:@"Value doesn't conform to NSCopying"]);
        return nil;
    }
    return value;
}

#pragma mark - Public

- (BOOL)saveData:(NSData *)data error:(NSError **)error {
    return YES;
}

- (nullable NSData *)loadData:(NSError **)error {
    return nil;
}

- (BOOL)removeData:(NSError **)error {
    return YES;
}

@end

NS_ASSUME_NONNULL_END
