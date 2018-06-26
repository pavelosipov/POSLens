//
//  NSError+POSS.m
//  POSLens
//
//  Created by Pavel Osipov on 31/01/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "NSError+POSLens.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSError (POSLens)

+ (instancetype)pos_lensErrorWithFormat:(nullable NSString *)format, ... {
    NSDictionary *info = nil;
    if (format) {
        va_list args;
        va_start(args, format);
        NSString *description = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        info = @{kPOSTrackableDescriptionKey: description};
    }
    return [self pos_errorWithCategory:kPOSInternalErrorCategory userInfo:info];
}

+ (instancetype)pos_fileErrorWithPath:(NSString *)filePath reason:(nullable NSError *)reason {
    BOOL isDirectory = NO;
    NSMutableDictionary *info = [NSMutableDictionary new];
    info[NSUnderlyingErrorKey] = reason;
    info[@"file_exists"] = @([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory]);
    info[@"is_directory"] = @(isDirectory);
    info[@"attributes"] = [[NSFileManager defaultManager] attributesOfFileSystemForPath:filePath error:nil];
    return [self pos_errorWithCategory:kPOSSystemErrorCategory userInfo:info];
}

@end

NS_ASSUME_NONNULL_END
