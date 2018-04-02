[![Version](http://img.shields.io/cocoapods/v/POSLens.svg)](http://cocoapods.org/?q=POSLens)

## What is POSLens?

POSLens is an Objective-C library for storing and updating [persistent data structures](https://en.wikipedia.org/wiki/Persistent_data_structure) using [functional lenses](https://broomburgo.github.io/fun-ios/post/lenses-and-prisms-in-swift-a-pragmatic-approach/).

POSLens plays the same role in the application as general-purpose databases. At the same time, it is a preferable choice when the data structure is relatively small and using massive persistence frameworks looks like an overkill. The next sections explain when and how to use lenses in iOS projects.

## Use-Cases for Lens

The two primary responsibilities of the library are the following.

1. **Data Synchronization**

   All popular iOS databases can work in a multithreaded environment. That is a critical feature because there are many cases when the application logic needs to read and update objects on several threads simultaneously. In a system which operates on a data in different threads, we have to account for race conditions. When the objects' graph is large, we keep it in a database. It hides from the client tons of dirty work about read-write synchronization between multiple threads. But how can we deal with race conditions upon in-memory objects? Immutable data structures is an answer to that question, and POSLens is a way to update them.

1. **Data Persistence**

   The library serializes and deserializes data structure into different kinds of stores and makes this in ACID compliant manner. Unlike databases, POSLens loads the whole objects' graph in memory, and that is why the library can not be used in situations when the data requires a lot of RAM a priory. Good cases when POSLens shines are the persistent management of the app settings and remote configurations. POSLens provides the unified interface for the most frequently used iOS data stores out-of-box:

   - Keychain
   - Files
   - NSUserDefaults
   - In-Memory

   If they are suitable for your data then most likely POSLens is an appropriate tool to manage it.

## The Structure of the Library
![payload](https://raw.github.com/pavelosipov/POSLens/master/.schemes/poslens.png)

The structure of the library is pretty simple.

   - **`POSLens`** provides read-only access to managing object and emits notifications about object updates. 
   - **`POSMutableLens`** adds additional methods to POSLens class for mutating managing object.
   - **`POSValueStore`** instances implement storage-specific logic for object persistence.
   - **`POSLensValue`** is an object managing by the lens. It should conform to at least NSCopying protocol because POSMutableLens updates it using "copy on write" idiom. NSCoding protocol implementation is also required in a case when POSValueStore needs to persist the object.

The library completely separates data accessors from data persisters. Only the root lens has a reference to a storage service which concrete implementation is hidden behind POSLensStore protocol. That makes it possible to extend the library with application-specific storages.

## Working with Lens

### Creating Lens

Let's declare data model and services for some application which needs to deal with authentication data and launch protection settings.

```objc
// Authenticator.h

@interface AccountCredentials : NSObject <NSCopying, NSCoding>

@property (nonatomic, readonly) NSString *email;
@property (nonatomic, readonly) NSString *password;

- (instancetype)initWithEmail:(NSString *)email password:(NSString *)password;

@end

@interface Authenticator : NSObject

@property (nonatomic, readonly) POSLens<AccountCredentials *> *credentials;

- (instancetype)initWithCredentials:(POSMutableLens<AccountCredentials *> *)credentials;

@end
```
```objc
// LaunchProtector.h

@interface AccountProtectionsSettings : NSObject <NSCopying, NSCoding>

@property (nonatomic, readonly) BOOL enabled;
@property (nonatomic, readonly, nullable) NSString *passcode;

- (instancetype)initWithEnabled:(BOOL)enabled passcode:(nullable NSString *)passcode;

@end

@interface LaunchProtector : NSObject

@property (nonatomic, readonly) POSLens<AccountProtectionsSettings *> *settings;

- (instancetype)initWithSettings:(POSMutableLens<AccountProtectionsSettings *> *)settings;

@end
```
```objc
// App.m

@interface AccountInfo : NSObject <NSCopying, NSCoding>

@property (nonatomic, readonly) AccountCredentials *credentials;
@property (nonatomic, readonly, nullable) AccountProtectionsSettings *protectionSettings;

- (instancetype)initWithCredentials:(AccountCredentials *)credentials
                 protectionSettings:(nullable AccountProtectionsSettings *)protectionSettings;
@end

@interface TheApp : NSObject
@property (nonatomic, readonly) POSMutableLens<AccountInfo *> *accountInfo;
@property (nonatomic, readonly) Authenticator *authenticator;
@property (nonatomic, readonly) LaunchProtector *launchProtector;
@end

@implementation TheApp
// ...
- (void)bootstrap {
    _accountInfo = [POSMutableLens
                    lensWithDefaultValue:nil
                    keychainService:@"my.app"
                    valueKey:@"accountInfo"
                    error:nil];                    
    _authenticator = [[POSAuthenticator alloc]
                      initWithAccountCredentials:_accountInfo[@"credentials"]];
    _launchProtector = [[POSLaunchProtector alloc]
                        initWithSettings:_accountInfo[@"protectionSettings"]];
}
// ...
@end
```
The root lens has been created using keychain-based initializer. The whole objects' graph will be loaded from and saved to the secure store after each modification. There is more generic lens initializer where the persistent data store is provided explicitly. It can be used to create the lens with custom stores or built-in stores with more advanced options.

```objc
id<POSValueStore> store = [[POSKeychainValueStore alloc]
                           initWithValueKey:@"accountInfo"
                           service:@"my.app"
                           accessGroup:@"my.app.access_group"];
_accountInfo = [POSMutableLens lensWithDefaultValue:nil store:store error:nil];
```
Note, that the app bind its services only to the specific part of the application state. Unlike Swift lenses [introduced by Brandon Williams](https://www.youtube.com/watch?v=ofjehH9f-CU) and described by Elviro Rocca's in his [great long-read post](https://broomburgo.github.io/fun-ios/post/lenses-and-prisms-in-swift-a-pragmatic-approach/), `POSLens` class mentions only the type of the underlying object but not the type of the object's owner. By that way, `POSLens` clients are decoupled from the whole data structure, and so they can be reused in entirely different contexts. In the code above Authenticator has been wired with `AccountCredentials` and `LaunchProtector` with `ProtectionsSettings`. Each service knows only about its state and nothing about the rest of the application stuff.

### Reading Value

A managing object can be accessed using the `value` property.

```objc
AccountInfo *accountInfoValue = _accountInfo.value;
```

Only the root lens keeps a strong reference to the underlying object. Lenses to its parts resolve their values lazily on demand.

![payload](https://raw.github.com/pavelosipov/POSLens/master/.schemes/lens_01.png)

`POSLens` extracts the actual value using a string key in such parent data structures as NSDictionary and NSObject.


   - NSDictionary has a built-in concept of key, and no black magic is required to use it for objects lookup.
   - Properties of NSObject-based instances are queued by the key-value coding mechanism.

`POSLens` unifies interface to access objects with the same key path in NSDictionary-based, NSObject-based and hybrid object hierarchies.

```objc
_accountInfo = [POSMutableLens lensWithValue:@{
    @"credentials": @{
        @"email": @"smith@gmail.com",
        @"password": @"123"
    },
    @"protectionSettings": @{
        @"enabled": @YES,
        @"passcode": @"123"
    }
}];
_authenticator = [[POSAuthenticator alloc]
                  initWithAccountCredentials:_accountInfo[@"credentials"]];
_launchProtector = [[POSLaunchProtector alloc]
                    initWithSettings:_accountInfo[@"protectionSettings"]];
```

A lens for the "enabled" property of `ProtectionsSettings` instance has an identical key path for both `AccountInfo` implementations. Here is how `POSLens` object can be obtained using the subscript-based API.

```objc
POSLens<NSNumber *> *enabled = _accountInfo[@"protectionSettings"][@"enabled"];
```

Dynamic objects lookup opens the possibility to create lenses for optional objects. For example, if an instance of `ProtectionsSettings` is absent in the `AccountInfo` object, the lens for it or even for its properties still can be created. Moreover, these lenses will emit update notifications and resolve actual values when their underlying objects become available.

```objc
POSMutableLens<AccountInfo *> *accountInfo = [POSMutableLens lensWithValue:
    [[AccountInfo alloc]
     initWithCredentials:[[AccountCredentials alloc]
                          initWithEmail:@"smith@gmail.com"
                          password:@"123"]
     protectionSettings:nil]
];
POSLens<NSNumber *> *enabled = _accountInfo[@"protectionSettings"][@"enabled"];
[enabled.valueUpdates subscribeNext:^(NSNumber * _Nullable x) {
    // Process new enabled value.
}];
[accountInfo[@"protectionSettings"]
 updateValue:[[AccountProtectionsSettings alloc] initWithEnabled:YES passcode:@"123"]
 error:nil];
```

POSLens supports default values for optional objects. There is a specialized factory method, which allows to specify them.

```objc
AccountProtectionsSettings *defaultSettings = [[AccountProtectionsSettings alloc]
                                               initWithEnabled:NO
                                               passcode:nil];
POSLens<AccountProtectionsSettings *> *settings = [_accountInfo
                                                   lensForKey:@"protectionSettings"
                                                   defaultValue:defaultSettings];
```

When the client code provides a default value for the same object on different levels of lens hierarchy, then more high-level instance has more priority. Default values are not the part of the object's graph, and the lens doesn't save them in the store. It's up to the application to specify new defaults for the same optional objects in the next version.

### Updating Value

The most straightforward way to update managing object is to use an update method.

```objc
POSMutableLens<NSNumber *> *enabled = _accountInfo[@"protectionSettings"][@"enabled"];
[enabled updateValue:@NO error:nil];
```

When update logic consists of multiple steps or depends on the current state of the managing object, then a block-based update method is more suitable. The trivial examples of these cases are concurrent property incrementation and modifying some property depending on the value of another one. POSLens class uses multiple-read/single-write lock for controlling access to the managing object, so all update blocks are executed serially. In other words, only one client can mutate objects' state at the same time.

```objc
typedef POSAccountProtectionsSettings Settings;
POSMutableLens<Settings *> *settings = _accountInfo[@"protectionSettings"];
[settings updateValueWithBlock:^Settings *(Settings *actual, NSError **error) {
    // Neither thread can update passcode value while this block is executing.
    if (actual.passcode.length > 0) {
        // Enabling protection only if passcode is valid...
        return [[Settings alloc] initWithEnabled:YES passcode:actual.passcode];
    } else {
        // Return an error otherwise...
        *error = [NSError
                  errorWithDomain:@"my.app.error"
                  code:0
                  userInfo:@{NSLocalizedDescriptionKey: @"Passcode is invalid."}];
        return nil;
    }
} error:nil]; // <- Error may be received here.
```

`POSLens` never mutates actual instances of managing objects. Client code may touch extracted objects without any locks. Lens modifies underlying value using "copy on write" idiom according to the following recursive steps:

   1. Resolving the actual instance of the managing object. 
   1. Creating a copy of the resolved value. 
   1. Mutating the copy of the resolved value.
   1. Asking parent lens to update object's owner with a new value of the managing object

![payload](https://raw.github.com/pavelosipov/POSLens/master/.schemes/lens_04.png)

By that way, each modification creates new instances of the modifying object and all its direct and indirect parents. That is why lens compatible objects should conform at least to NSCopying protocol. NSDictionary supports NSCopying functionality out-of-box, but more fine-grained NSObject-based state classes should implement cloning explicitly.

The diagram below illustrates how the new objects’ graph looks like after B2 instance update. Note, that previous version of B2, B and R are still accessible and preserve their outdated but valid state.

![payload](https://raw.github.com/pavelosipov/POSLens/master/.schemes/lens_02.png)

`POSLens` guarantees that each update will modify and persist the whole data structure in the underlying storage in a consistent state or keep data structure in the original state if something went wrong on the way. For enabling the persisting feature and using `POSLens` objects in conjunction with such supported data stores as the keychain, files, and NSUserDefaults, NSCoding protocol should be implemented by a managing object as well.

### Updating Optional Value

Updating optional value may be tricky in a situation where the owner of that value is also optional. The previous section states that the lens clones the parent object when a new version of the managing object becomes available. If the parent object doesn't exist, then the only one way for the lens to update its children is to use a parent's default value. In that case, the default value promotes to real one, and it will be persisted as part of objects' graph by the end of updating procedure. If some direct or indirect parent has neither real value or default value, then the update method will be finished with an error.

### Receiving Notifications about Value Updates

`POSLens` class contains `valueUpdates` signal, which emits actual instances of the managing object. Client code receives such notifications on subscription and for each update of managing object or some of its parts. The diagram below illustrates which lenses will emit new actual instances in case of B2 object update.

![payload](https://raw.github.com/pavelosipov/POSLens/master/.schemes/lens_03.png)

### Extensibility

POSLens library is extendable with custom data stores. They should conform to `POSValueStore` protocol. Custom stores can save and load objects' graph in any way they want. All built-in stores persist their values using `NSKeyedArchive`, so the `POSLensValue` should conform to `NSCoding` protocol. If a custom store also relies on NSCoding compliance of managing objects, then it may derive from `POSPersistentValueStore` class which implements the most of work serializing and deserializing objects.