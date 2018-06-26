//
//  POSPersonSettingsStore.m
//  POSLensTests
//
//  Created by Pavel Osipov on 08/02/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "POSPersonSettingsStore.h"
#import <POSErrorHandling/POSErrorHandling.h>

NS_ASSUME_NONNULL_BEGIN

@interface POSPersonSettingsStore ()
@property (nonatomic, readonly, nullable) POSPersonSettings *settings;
@end

@implementation POSPersonSettingsStore

- (instancetype)initWithSettings:(nullable POSPersonSettings *)settings {
    if (self = [super init]) {
        _settings = settings;
    }
    return self;
}

#pragma mark POSPersistentSettingsStore

- (BOOL)saveData:(NSData *)data error:(NSError **)error {
    POSAssignError(error, [NSError pos_internalErrorWithFormat:@"Test error."]);
    return NO;
}

- (nullable NSData *)loadData:(NSError **)error {
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc ] initForWritingWithMutableData:data];
    [archiver setOutputFormat:NSPropertyListBinaryFormat_v1_0];
    [archiver encodeRootObject:_settings];
    [archiver finishEncoding];
    return data;
}

- (BOOL)removeData:(NSError **)error {
    POS_CHECK_EX(NO, @"Remove error.");
}

@end

NS_ASSUME_NONNULL_END
