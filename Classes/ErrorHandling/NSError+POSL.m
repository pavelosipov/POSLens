//
//  NSError+POSS.m
//  POSLens
//
//  Created by Pavel Osipov on 31/01/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "NSError+POSL.h"

NS_ASSUME_NONNULL_BEGIN

// Pubic constants
NSString * const kPOSLErrorDomain = @"com.github.pavelosipov.POSLens";

// Private constants
static NSString * const kPOSLVersboseDescriptionErrorKey = @"VerboseDescription";

@implementation NSError (POSL)

+ (instancetype)posl_systemErrorWithInfo:(nullable NSDictionary *)info {
    return [[NSError alloc] initWithDomain:kPOSLErrorDomain code:POSLErrorCodeSystem userInfo:info];
}

+ (instancetype)posl_systemErrorWithFormat:(nullable NSString *)format, ... {
    NSDictionary *info = nil;
    if (format) {
        va_list args;
        va_start(args, format);
        NSString *description = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        info = @{kPOSLVersboseDescriptionErrorKey: description};
    }
    return [self posl_systemErrorWithInfo:info];
}

+ (instancetype)posl_updateErrorWithFormat:(nullable NSString *)format, ... {
    NSDictionary *info = nil;
    if (format) {
        va_list args;
        va_start(args, format);
        NSString *description = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        info = @{kPOSLVersboseDescriptionErrorKey: description};
    }
    return [[NSError alloc] initWithDomain:kPOSLErrorDomain code:POSLErrorCodeUpdate userInfo:info];
}

+ (instancetype)posl_internalErrorWithFormat:(NSString *)format, ... {
    NSDictionary *info = nil;
    if (format) {
        va_list args;
        va_start(args, format);
        NSString *description = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        info = @{kPOSLVersboseDescriptionErrorKey: description};
    }
    return [[NSError alloc] initWithDomain:kPOSLErrorDomain code:POSLErrorCodeInternal userInfo:info];
}

+ (instancetype)posl_fileErrorWithPath:(NSString *)filePath reason:(nullable NSError *)reason {
    BOOL isDirectory = NO;
    NSMutableDictionary *info = [NSMutableDictionary new];
    info[NSUnderlyingErrorKey] = reason;
    info[@"file_exists"] = @([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory]);
    info[@"is_directory"] = @(isDirectory);
    info[@"attributes"] = [[NSFileManager defaultManager] attributesOfFileSystemForPath:filePath error:nil];
    return [self posl_systemErrorWithInfo:info];
}

@end

NS_ASSUME_NONNULL_END
