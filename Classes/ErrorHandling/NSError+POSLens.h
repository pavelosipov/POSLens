//
//  NSError+POSL.h
//  POSLens
//
//  Created by Pavel Osipov on 31/01/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import <POSErrorHandling/POSErrorHandling.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (POSLens)

/// File access error.
+ (instancetype)pos_fileErrorWithPath:(NSString *)filePath reason:(nullable NSError *)reason;

/// Update error.
+ (instancetype)pos_lensErrorWithFormat:(nullable NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
