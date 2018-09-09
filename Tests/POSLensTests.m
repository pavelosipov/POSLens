//
//  POSLensTests.m
//  POSLens
//
//  Created by Pavel Osipov on 26/10/2015.
//  Copyright © 2015 Pavel Osipov. All rights reserved.
//

#import "POSPersonSettings.h"
#import "POSPersonSettingsStore.h"
#import <POSLens/POSLens.h>
#import <POSLens/POSEphemeralValueStore.h>
#import <POSErrorHandling/POSErrorHandling.h>
#import <XCTest/XCTest.h>

@interface POSLensTests : XCTestCase
@end

@implementation POSLensTests

- (void)testObjectLensPolicyConformance {
    POSPersonSettings *settingsV1 = [[POSPersonSettings alloc] initWithName:@"Pavel" age:10 privacySettings:nil];
    XCTAssertEqualObjects([settingsV1 pos_valueForKey:@"name"], @"Pavel");
    XCTAssertEqualObjects([settingsV1 pos_valueForKey:@"age"], @10);
    POSPersonSettings *settingsV2 = [settingsV1 pos_setValue:@"Andrey" forKey:@"name"];
    XCTAssertTrue(settingsV1 != settingsV2);
    XCTAssertEqualObjects(settingsV2.name, @"Andrey");
    XCTAssertTrue(settingsV2.age == 10);
    POSPersonSettings *settingsV3 = [settingsV1 pos_setValue:@20 forKey:@"age"];
    XCTAssertTrue(settingsV1 != settingsV3);
    XCTAssertEqualObjects(settingsV3.name, @"Pavel");
    XCTAssertTrue(settingsV3.age == 20);
}

- (void)testDictionaryLensPolicyConformance {
    NSDictionary *settingsV1 = @{@"name": @"Pavel", @"age": @10};
    XCTAssertEqualObjects([settingsV1 pos_valueForKey:@"name"], @"Pavel");
    XCTAssertEqualObjects([settingsV1 pos_valueForKey:@"age"], @10);
    NSDictionary *settingsV2 = [settingsV1 pos_setValue:@"Andrey" forKey:@"name"];
    XCTAssertTrue(settingsV1 != settingsV2);
    XCTAssertEqualObjects(settingsV2[@"name"], @"Andrey");
    XCTAssertEqualObjects(settingsV2[@"age"], @10);
    NSDictionary *settingsV3 = [settingsV1 pos_setValue:@20 forKey:@"age"];
    XCTAssertTrue(settingsV1 != settingsV3);
    XCTAssertEqualObjects(settingsV3[@"name"], @"Pavel");
    XCTAssertEqualObjects(settingsV3[@"age"], @20);
}

- (void)testObjectPropertyUpdate {
    POSMutableLens<POSPersonSettings *> *settings =
    [POSMutableLens lensWithValue:
     [[POSPersonSettings alloc]
      initWithName:@"Pavel"
      age:10
      privacySettings:
      [[POSPersonPrivacySettings alloc]
       initWithEmail:@"pavel@mail.ru"
       password:@"123"]]];
    POSPersonSettings *personSettingsV1 = settings.value;
    POSMutableLens<NSString *> *nameSettings = settings[@"name"];
    BOOL updated = [nameSettings updateValue:@"Andrey" error:nil];
    XCTAssertTrue(updated);
    POSPersonSettings *personSettingsV2 = settings.value;
    XCTAssertTrue(personSettingsV1 != personSettingsV2);
    XCTAssertEqualObjects(personSettingsV1.name, @"Pavel");
    XCTAssertEqualObjects(personSettingsV2.name, @"Andrey");
    XCTAssertTrue(personSettingsV1.age == personSettingsV2.age);
    XCTAssertTrue(personSettingsV1.privacySettings == personSettingsV2.privacySettings);
}

- (void)testObjectRecursivePropertyUpdate {
    POSMutableLens<POSPersonSettings *> *settings =
    [POSMutableLens lensWithValue:
     [[POSPersonSettings alloc]
      initWithName:@"Pavel"
      age:10
      privacySettings:
      [[POSPersonPrivacySettings alloc]
       initWithEmail:@"pavel@mail.ru"
       password:@"123"]]];
    POSPersonSettings *personSettingsV1 = settings.value;
    POSMutableLens<NSString *> *emailSettings = [settings lensForKeyPath:@keypath(settings.value, privacySettings.email)];
    XCTAssertEqualObjects(emailSettings.value, @"pavel@mail.ru");
    BOOL updated = [emailSettings updateValue:@"andrey@mail.ru" error:nil];
    XCTAssertTrue(updated);
    POSPersonSettings *personSettingsV2 = settings.value;
    XCTAssertTrue(personSettingsV1 != personSettingsV2);
    XCTAssertTrue(personSettingsV1.privacySettings != personSettingsV2.privacySettings);
    XCTAssertEqualObjects(personSettingsV1.name, @"Pavel");
    XCTAssertEqualObjects(personSettingsV2.name, @"Pavel");
    XCTAssertTrue(personSettingsV1.age == 10);
    XCTAssertTrue(personSettingsV2.age == 10);
    XCTAssertEqualObjects(personSettingsV1.privacySettings.password, @"123");
    XCTAssertEqualObjects(personSettingsV2.privacySettings.password, @"123");
    XCTAssertEqualObjects(personSettingsV1.privacySettings.email, @"pavel@mail.ru");
    XCTAssertEqualObjects(personSettingsV2.privacySettings.email, @"andrey@mail.ru");
}

- (void)testObjectPropertyUpdateAtKeyPath {
    POSMutableLens<POSPersonSettings *> *settings =
    [POSMutableLens lensWithValue:
     [[POSPersonSettings alloc]
      initWithName:@"Pavel"
      age:10
      privacySettings:
      [[POSPersonPrivacySettings alloc]
       initWithEmail:@"pavel@mail.ru"
       password:@"123"]]];
    POSPersonSettings *personSettingsV1 = settings.value;
    BOOL updated = [settings updateValue:@"andrey@mail.ru"
                               atKeyPath:@keypath(settings.value, privacySettings.email)
                                   error:nil];
    XCTAssertTrue(updated);
    POSPersonSettings *personSettingsV2 = settings.value;
    XCTAssertTrue(personSettingsV1 != personSettingsV2);
    XCTAssertTrue(personSettingsV1.privacySettings != personSettingsV2.privacySettings);
    XCTAssertEqualObjects(personSettingsV1.name, @"Pavel");
    XCTAssertEqualObjects(personSettingsV2.name, @"Pavel");
    XCTAssertTrue(personSettingsV1.age == 10);
    XCTAssertTrue(personSettingsV2.age == 10);
    XCTAssertEqualObjects(personSettingsV1.privacySettings.password, @"123");
    XCTAssertEqualObjects(personSettingsV2.privacySettings.password, @"123");
    XCTAssertEqualObjects(personSettingsV1.privacySettings.email, @"pavel@mail.ru");
    XCTAssertEqualObjects(personSettingsV2.privacySettings.email, @"andrey@mail.ru");
}

- (void)testDictionaryPropertyUpdate {
    POSMutableLens<NSDictionary *> *settings =
    [POSMutableLens lensWithValue:
     @{@"name": @"Pavel",
       @"age": @10,
       @"privacySettings":[[POSPersonPrivacySettings alloc]
                           initWithEmail:@"pavel@mail.ru"
                           password:@"123"]}];
    NSDictionary *personSettingsV1 = settings.value;
    POSMutableLens<NSString *> *emailSettings = settings[@"privacySettings"][@"email"];
    XCTAssertEqualObjects(emailSettings.value, @"pavel@mail.ru");
    BOOL updated = [emailSettings updateValue:@"andrey@mail.ru" error:nil];
    XCTAssertTrue(updated);
    NSDictionary *personSettingsV2 = settings.value;
    XCTAssertTrue(personSettingsV1 != personSettingsV2);
    XCTAssertTrue(personSettingsV1[@"privacySettings"] != personSettingsV2[@"privacySettings"]);
    XCTAssertEqualObjects(personSettingsV1[@"name"], @"Pavel");
    XCTAssertEqualObjects(personSettingsV2[@"name"], @"Pavel");
    XCTAssertEqualObjects(personSettingsV1[@"age"], @10);
    XCTAssertEqualObjects(personSettingsV2[@"age"], @10);
    XCTAssertEqualObjects([personSettingsV1[@"privacySettings"] password], @"123");
    XCTAssertEqualObjects([personSettingsV2[@"privacySettings"] password], @"123");
    XCTAssertEqualObjects([personSettingsV1[@"privacySettings"] email], @"pavel@mail.ru");
    XCTAssertEqualObjects([personSettingsV2[@"privacySettings"] email], @"andrey@mail.ru");
}

- (void)testLensValueRemoving {
    POSMutableLens<NSDictionary *> *settings =
    [POSMutableLens lensWithValue:
     @{@"name": @"Pavel",
       @"age": @10,
       @"privacySettings":[[POSPersonPrivacySettings alloc]
                           initWithEmail:@"pavel@mail.ru"
                           password:@"123"]}];
    NSDictionary *personSettingsV1 = settings.value;
    POSMutableLens<POSPersonPrivacySettings *> *privacySettings = settings[@"privacySettings"];
    BOOL removed = [privacySettings removeValue:nil];
    XCTAssertTrue(removed);
    NSDictionary *personSettingsV2 = settings.value;
    XCTAssertNotNil(personSettingsV1[@"privacySettings"]);
    XCTAssertNil(personSettingsV2[@"privacySettings"]);
}

- (void)testFileValueStore {
    CFUUIDRef UUID = CFUUIDCreate(NULL);
    NSString *filename = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, UUID);
    CFRelease(UUID);
    NSString *sourcePath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    POSPersonSettings *personSettings =
    [[POSPersonSettings alloc]
     initWithName:@"Pavel"
     age:10
     privacySettings:
     [[POSPersonPrivacySettings alloc]
      initWithEmail:@"pavel@mail.ru"
      password:@"123"]];
    NSMutableData *personDataV1 = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc ] initForWritingWithMutableData:personDataV1];
    [archiver setOutputFormat:NSPropertyListBinaryFormat_v1_0];
    [archiver encodeRootObject:personSettings];
    [archiver finishEncoding];
    BOOL written = [personDataV1 writeToFile:sourcePath atomically:YES];
    XCTAssertTrue(written);
    POSMutableLens<POSPersonSettings *> *settings = [POSMutableLens
                                                     lensWithDefaultValue:nil
                                                     filePath:sourcePath
                                                     error:nil];
    XCTAssertNotNil(settings);
    POSPersonSettings *personSettingsV1 = settings.value;
    XCTAssertEqualObjects(personSettingsV1.name, @"Pavel");
    XCTAssertTrue(personSettingsV1.age == 10);
    XCTAssertEqualObjects(personSettingsV1.privacySettings.email, @"pavel@mail.ru");
    XCTAssertEqualObjects(personSettingsV1.privacySettings.password, @"123");
    POSMutableLens<NSString *> *emailSettings = settings[@"privacySettings"][@"email"];
    BOOL updated = [emailSettings updateValue:@"andrey@mail.ru" error:nil];
    XCTAssertTrue(updated);
    NSData *dataV1 = [NSData dataWithContentsOfFile:sourcePath];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:dataV1];
    POSPersonSettings *personSettingsV2 = [unarchiver decodeObject];
    XCTAssertEqualObjects(personSettingsV2.privacySettings.email, @"andrey@mail.ru");
    BOOL removed = [settings removeValue:nil];
    XCTAssertTrue(removed);
    XCTAssertFalse([NSFileManager.defaultManager fileExistsAtPath:sourcePath]);
}

- (void)testValueStoreFailurePropagation {
    id<POSValueStore> store = [[POSPersonSettingsStore alloc]
                               initWithSettings:
                               [[POSPersonSettings alloc]
                                initWithName:@"Pavel"
                                age:10
                                privacySettings:
                                [[POSPersonPrivacySettings alloc]
                                 initWithEmail:@"pavel@mail.ru"
                                 password:@"123"]]];
    POSMutableLens<POSPersonSettings *> *settings = [POSMutableLens
                                                     lensWithDefaultValue:nil
                                                     store:store
                                                     error:nil];
    POSMutableLens<NSString *> *emailSettings = settings[@"privacySettings"][@"email"];
    POSPersonSettings *settingsValue = settings.value;
    XCTAssertEqualObjects(emailSettings.value, @"pavel@mail.ru");
    NSError *error;
    BOOL updated = [emailSettings updateValue:@"andrey@mail.ru" error:&error];
    XCTAssertFalse(updated);
    XCTAssertTrue(settingsValue == settings.value);
    XCTAssertEqualObjects(error.domain, kPOSErrorDomain);
    XCTAssertEqualObjects(emailSettings.value, @"pavel@mail.ru");
    BOOL removed = [settings removeValue:&error];
    XCTAssertFalse(removed);
    XCTAssertTrue(settingsValue == settings.value);
    XCTAssertEqualObjects(error.domain, kPOSErrorDomain);
    XCTAssertEqualObjects(emailSettings.value, @"pavel@mail.ru");
}

- (void)testExistingLensValueUpdateNotifications {
    POSMutableLens<NSDictionary *> *settings =
    [POSMutableLens lensWithValue:
     @{@"pavel@mail.ru": @{@"name": @"Pavel",
                           @"age": @10,
                           @"privacySettings":[[POSPersonPrivacySettings alloc]
                                               initWithEmail:@"pavel@mail.ru"
                                               password:@"123"]},
       @"andrey@mail.ru": @{@"name": @"Andrey",
                            @"age": @20,
                            @"privacySettings":[[POSPersonPrivacySettings alloc]
                                                initWithEmail:@"andrey@mail.ru"
                                                password:@"321"]}
       }];
    NSMutableDictionary *updateNotesCounters = [NSMutableDictionary new];
    __auto_type incrementUpdateCounter = ^void(NSString *name) {
        NSNumber *counter = updateNotesCounters[name];
        updateNotesCounters[name] = @(counter.integerValue + 1);
    };
    [settings.valueUpdates subscribeNext:^(id _) {
        incrementUpdateCounter(@"root");
    }];
    
    POSMutableLens<NSDictionary *> *andreySettings = settings[@"andrey@mail.ru"];
    [andreySettings.valueUpdates subscribeNext:^(id _) {
        incrementUpdateCounter(@"andreySettings");
    }];
    POSMutableLens<POSPersonPrivacySettings *> *andreyPrivacySettings = andreySettings[@"privacySettings"];
    [andreyPrivacySettings.valueUpdates subscribeNext:^(id _) {
        incrementUpdateCounter(@"andreyPrivacySettings");
    }];
    POSLens<NSString *> *andreyPasswordSettings = andreySettings[@"password"];
    [andreyPasswordSettings.valueUpdates subscribeNext:^(id _) {
        incrementUpdateCounter(@"andreyPasswordSettings");
    }];
    POSMutableLens<NSString *> *andreyEmailSettings = andreyPrivacySettings[@"email"];
    __block NSString *expectedAndreyEmail = @"andrey@mail.ru";
    [andreyEmailSettings.valueUpdates subscribeNext:^(NSString * _Nullable actualEmail) {
        XCTAssertEqualObjects(expectedAndreyEmail, actualEmail);
        incrementUpdateCounter(@"andreyEmailSettings");
    }];
    
    POSLens<NSDictionary *> *pavelSettings = settings[@"pavel@mail.ru"];
    [pavelSettings.valueUpdates subscribeNext:^(id _) {
        incrementUpdateCounter(@"pavelSettings");
    }];
    POSLens<POSPersonPrivacySettings *> *pavelPrivacySettings = pavelSettings[@"privacySettings"];
    [pavelPrivacySettings.valueUpdates subscribeNext:^(id _) {
        incrementUpdateCounter(@"pavelPrivacySettings");
    }];
    POSLens<NSString *> *pavelEmailSettings = pavelPrivacySettings[@"email"];
    [pavelEmailSettings.valueUpdates subscribeNext:^(NSString * _Nullable actualEmail) {
        incrementUpdateCounter(@"pavelEmailSettings");
    }];

    expectedAndreyEmail = @"andrey@list.ru";
    [andreyEmailSettings updateValue:@"andrey@list.ru" error:nil];
    expectedAndreyEmail = @"andrey@bk.ru";
    [andreyEmailSettings updateValue:@"andrey@bk.ru" error:nil];
    [andreyEmailSettings updateValue:@"andrey@bk.ru" error:nil];
    
    XCTAssertEqualObjects(updateNotesCounters[@"root"], @3);
    XCTAssertEqualObjects(updateNotesCounters[@"andreySettings"], @3);
    XCTAssertEqualObjects(updateNotesCounters[@"andreyPrivacySettings"], @3);
    XCTAssertEqualObjects(updateNotesCounters[@"andreyEmailSettings"], @3);
    XCTAssertEqualObjects(updateNotesCounters[@"andreyPasswordSettings"], @1);
    XCTAssertEqualObjects(updateNotesCounters[@"pavelSettings"], @1);
    XCTAssertEqualObjects(updateNotesCounters[@"pavelPrivacySettings"], @1);
    XCTAssertEqualObjects(updateNotesCounters[@"pavelEmailSettings"], @1);
}

- (void)testLensValueAdditionNotification {
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    POSMutableLens<NSDictionary *> *settings =
    [POSMutableLens lensWithValue:
     @{@"pavel@mail.ru": @{@"name": @"Pavel",
                           @"age": @10,
                           @"privacySettings":[[POSPersonPrivacySettings alloc]
                                               initWithEmail:@"pavel@mail.ru"
                                               password:@"123"]}
       }];
    POSMutableLens<NSString *> *andreyEmailSettings = settings[@"andrey@mail.ru"][@"privacySettings"][@"email"];
    [andreyEmailSettings.valueUpdates subscribeNext:^(NSString *email) {
        if ([email isEqualToString:@"andrey@mail.ru"]) {
            [expectation fulfill];
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [settings updateValueWithBlock:^NSDictionary * _Nullable(NSDictionary *accounts, NSError **error) {
            NSMutableDictionary *updatedAccounts = [accounts mutableCopy];
            updatedAccounts[@"andrey@mail.ru"] = @{@"name": @"Andrey",
                                                   @"age": @20,
                                                   @"privacySettings":[[POSPersonPrivacySettings alloc]
                                                                       initWithEmail:@"andrey@mail.ru"
                                                                       password:@"321"]};
            return [updatedAccounts copy];
        } error:nil];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testLensValueRemovalNotification {
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    POSMutableLens<NSDictionary *> *settings =
    [POSMutableLens lensWithValue:
     @{@"pavel@mail.ru": @{@"name": @"Pavel",
                           @"age": @10,
                           @"privacySettings":[[POSPersonPrivacySettings alloc]
                                               initWithEmail:@"pavel@mail.ru"
                                               password:@"123"]},
       @"andrey@mail.ru": @{@"name": @"Andrey",
                            @"age": @20,
                            @"privacySettings":[[POSPersonPrivacySettings alloc]
                                                initWithEmail:@"andrey@mail.ru"
                                                password:@"321"]}
       }];
    POSLens<NSString *> *andreyEmailSettings = settings[@"andrey@mail.ru"][@"privacySettings"][@"email"];
    [andreyEmailSettings.valueUpdates subscribeNext:^(NSString *email) {
        if (email == nil) {
            [expectation fulfill];
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [settings updateValueWithBlock:^NSDictionary * _Nullable(NSDictionary *accounts, NSError **error) {
            NSMutableDictionary *updatedAccounts = [accounts mutableCopy];
            updatedAccounts[@"andrey@mail.ru"] = nil;
            return [updatedAccounts copy];
        } error:nil];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testUpdateLensValueWithoutParentFailure {
    POSMutableLens<NSDictionary *> *settings = [POSMutableLens
                                                lensWithValue:@{@"pavel@mail.ru": @{@"name": @"Pavel", @"age": @10}}];
    POSMutableLens<NSString *> *emailSetting = settings[@"pavel@mail.ru"][@"privacySettings"][@"email"];
    XCTAssertNil(emailSetting.value);
    NSError *error;
    BOOL updated = [emailSetting updateValue:@"pavel@mail.ru" error:&error];
    XCTAssertFalse(updated);
    XCTAssertNotNil(error);
    XCTAssertTrue(error.pos_category == kPOSInternalErrorCategory);
}

- (void)testUpdateLensValueSuccessWithNilParentWithDefaultValue {
    POSMutableLens<NSDictionary *> *settings = [POSMutableLens
                                                lensWithDefaultValue:@{}
                                                store:[[POSEphemeralValueStore alloc] initWithValue:nil]
                                                error:nil];
    POSMutableLens<POSPersonPrivacySettings *> *privacySettings =
    [settings lensForKey:@"privacySettings"
            defaultValue:[[POSPersonPrivacySettings alloc] initWithEmail:nil password:@"123"]];
    POSMutableLens<NSString *> *emailSetting = [privacySettings lensForKey:@"email" defaultValue:@"pavel@example.com"];
    POSLens<NSString *> *passwordSettingWithoutDefaultValue = privacySettings[@"password"];
    POSLens<NSString *> *passwordSettingWithDefaultValue = [privacySettings lensForKey:@"password" defaultValue:@"321"];
    XCTAssertNil(settings.value[@"privacySettings"]);
    XCTAssertNil(privacySettings.value.email);
    XCTAssertEqualObjects(privacySettings.value.password, @"123");
    XCTAssertEqualObjects(emailSetting.value, @"pavel@example.com");
    XCTAssertEqualObjects(passwordSettingWithoutDefaultValue.value, @"123");
    XCTAssertEqualObjects(passwordSettingWithDefaultValue.value, @"123"); // Parent's defaults have more priority.
    NSError *error;
    BOOL updated = [emailSetting updateValue:@"pavel@mail.ru" error:&error];
    XCTAssertTrue(updated);
    XCTAssertEqualObjects(emailSetting.value, @"pavel@mail.ru");
    XCTAssertEqualObjects(privacySettings.value.password, @"123");
    XCTAssertEqualObjects(privacySettings.value.email, @"pavel@mail.ru");
    XCTAssertEqualObjects(((POSPersonPrivacySettings *)settings.value[@"privacySettings"]).email, @"pavel@mail.ru");
}

- (void)testResetLensValue {
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    id<POSValueStore> settingsStore = [[POSEphemeralValueStore alloc] initWithValue:
        @{@"pavel":
              @{@"name": @"Pavel",
                @"age": @10,
                @"privacySettings":[[POSPersonPrivacySettings alloc] initWithEmail:@"pavel@mail.ru" password:@"123"]}}];
    POSMutableLens<NSDictionary *> *settings = [POSMutableLens
                                                lensWithDefaultValue:@{}
                                                store:settingsStore
                                                error:nil];
    POSLens<NSString *> *emailLens = settings[@"pavel"][@"privacySettings"][@"email"];
    XCTAssertEqualObjects(emailLens.value, @"pavel@mail.ru");
    [emailLens.valueUpdates subscribeNext:^(NSString *email) {
        if ([email isEqualToString:@"pavel@bk.ru"]) {
            [expectation fulfill];
        }
    }];
    NSDictionary *newValue =
        @{@"pavel":
              @{@"name": @"Pavel Osipov",
                @"age": @20,
                @"privacySettings":[[POSPersonPrivacySettings alloc] initWithEmail:@"pavel@bk.ru" password:@"321"]}};
    [settingsStore saveValue:newValue error:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [settings resetValue:nil];
    });
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
