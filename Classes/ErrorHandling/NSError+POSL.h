//
//  NSError+POSL.h
//  POSLens
//
//  Created by Pavel Osipov on 31/01/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString * const kPOSLErrorDomain;

/// All possible error codes with kPOSSErrorDomain.
typedef NS_ENUM(NSInteger, POSLErrorCode) {
    POSLErrorCodeSystem = 10,
    POSLErrorCodeUpdate,
    POSLErrorCodeInternal
};

@interface NSError (POSL)

/// General error for any I/O problems in store backends.
+ (instancetype)posl_systemErrorWithInfo:(nullable NSDictionary *)info;

/// General error for any I/O problems in store backends.
+ (instancetype)posl_systemErrorWithFormat:(nullable NSString *)format, ...;

/// File access error.
+ (instancetype)posl_fileErrorWithPath:(NSString *)filePath reason:(nullable NSError *)reason;

/// Update error.
+ (instancetype)posl_updateErrorWithFormat:(nullable NSString *)format, ...;

/// Unexpected error probably issued by corrupted data.
+ (instancetype)posl_internalErrorWithFormat:(NSString *)format, ...;

@end

NS_INLINE void POSLAssignError(NSError **targetError, NSError *sourceError) {
    if (targetError) {
        *targetError = sourceError;
    }
}

NS_ASSUME_NONNULL_END
