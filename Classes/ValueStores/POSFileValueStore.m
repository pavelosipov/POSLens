//
//  POSFileValueStore.m
//  POSLens
//
//  Created by Pavel Osipov on 13/10/2015.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSFileValueStore.h"
#import "NSError+POSLens.h"

NS_ASSUME_NONNULL_BEGIN

@interface POSFileValueStore ()
@property (nonatomic, readonly) NSString *filePath;
@end

@implementation POSFileValueStore

- (instancetype)initWithFilePath:(NSString *)filePath {
    POS_CHECK(filePath);
    if (self = [super init]) {
        _filePath = [filePath copy];
    }
    return self;
}

#pragma mark - POSPersistentValueStore

- (BOOL)saveData:(NSData *)data error:(NSError **)error {
    POS_CHECK(data);
    NSError *cocoaError = nil;
    if (![data writeToFile:_filePath options:NSDataWritingAtomic error:&cocoaError]) {
        POSAssignError(error, [NSError pos_fileErrorWithPath:_filePath reason:cocoaError]);
        return NO;
    }
    return YES;
}

- (nullable NSData *)loadData:(NSError **)error {
    if (![[NSFileManager defaultManager] fileExistsAtPath:_filePath]) {
        return nil;
    }
    NSError *cocoaError = nil;
    NSData *data = [NSData dataWithContentsOfFile:_filePath options:NSDataReadingMappedIfSafe error:&cocoaError];
    if (cocoaError) {
        POSAssignError(error, [NSError pos_fileErrorWithPath:_filePath reason:cocoaError]);
        return nil;
    }
    return data;
}

- (BOOL)removeData:(NSError **)error {
    NSError *cocoaError = nil;
    if (![[NSFileManager defaultManager] removeItemAtPath:_filePath error:&cocoaError]) {
        POSAssignError(error, [NSError pos_fileErrorWithPath:_filePath reason:cocoaError]);
        return NO;
    }
    return YES;
}

@end

NS_ASSUME_NONNULL_END
