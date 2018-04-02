//
//  POSPersonSettings.h
//  POSLensTests
//
//  Created by Pavel Osipov on 08/02/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface POSPersonPrivacySettings : NSObject <NSCopying, NSCoding>

@property (nonatomic, readonly, nullable) NSString *email;
@property (nonatomic, readonly, nullable) NSString *password;

- (instancetype)initWithEmail:(nullable NSString *)email
                     password:(nullable NSString *)password;

@end

#pragma mark -

@interface POSPersonSettings : NSObject <NSCopying, NSCoding>

@property (nonatomic, readonly, nullable) NSString *name;
@property (nonatomic, readonly) NSInteger age;
@property (nonatomic, readonly, nullable) POSPersonPrivacySettings *privacySettings;

- (instancetype)initWithName:(nullable NSString *)name
                         age:(NSInteger)age
             privacySettings:(nullable POSPersonPrivacySettings *)privacySettings;

@end

NS_ASSUME_NONNULL_END
