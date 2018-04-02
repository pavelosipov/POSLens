//
//  NSException+POSL.h
//  POSLens
//
//  Created by Pavel Osipov on 30/01/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSException (POSL)

/// Creates exception with specified description.
+ (instancetype)posl_exceptionWithFormat:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END

#define POSL_CHECK_EX(condition, description, ...) \
do { \
    NSAssert((condition), description, ##__VA_ARGS__); \
    if (!(condition)) { \
        @throw [NSException posl_exceptionWithFormat:description, ##__VA_ARGS__]; \
    } \
} while (0)

#define POSL_CHECK(condition) \
        POSL_CHECK_EX(condition, ([NSString stringWithFormat:@"'%s' is false.", #condition]))
