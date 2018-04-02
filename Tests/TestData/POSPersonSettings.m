//
//  POSPersonSettings.m
//  POSLensTests
//
//  Created by Pavel Osipov on 08/02/2018.
//  Copyright © 2018 Pavel Osipov. All rights reserved.
//

#import "POSPersonSettings.h"

NS_ASSUME_NONNULL_BEGIN

@implementation POSPersonPrivacySettings

- (instancetype)initWithEmail:(nullable NSString *)email
                     password:(nullable NSString *)password {
    if (self = [super init]) {
        _email = email;
        _password = password;
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _email = [aDecoder decodeObjectForKey:@"email"];
        _password = [aDecoder decodeObjectForKey:@"password"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_email forKey:@"email"];
    [aCoder encodeObject:_password forKey:@"password"];
}

- (instancetype)copyWithZone:(nullable NSZone *)zone {
    return [[self.class alloc] initWithEmail:_email password:_password];
}

@end

#pragma mark -

@implementation POSPersonSettings

- (instancetype)initWithName:(nullable NSString *)name
                         age:(NSInteger)age
             privacySettings:(nullable POSPersonPrivacySettings *)privacySettings {
    if (self = [super init]) {
        _name = name;
        _age = age;
        _privacySettings = privacySettings;
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _age = [aDecoder decodeIntegerForKey:@"age"];
        _privacySettings = [aDecoder decodeObjectForKey:@"privacySettings"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeInteger:_age forKey:@"age"];
    [aCoder encodeObject:_privacySettings forKey:@"privacySettings"];
}

- (instancetype)copyWithZone:(nullable NSZone *)zone {
    return [[self.class alloc] initWithName:_name age:_age privacySettings:_privacySettings];
}

@end

NS_ASSUME_NONNULL_END
