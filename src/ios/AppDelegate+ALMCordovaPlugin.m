#import "AppDelegate+ALMCordovaPlugin.h"
#import "ILMCordovaPlugin.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "Firebase.h"

@import InLocoSDK;

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@import UserNotifications;
#endif


// Implement UNUserNotificationCenterDelegate to receive display notification via APNS for devices
// running iOS 10 and above. Implement FIRMessagingDelegate to receive data message via FCM for
// devices running iOS 10 and above.
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface AppDelegate () <UNUserNotificationCenterDelegate, FIRMessagingDelegate>
@end
#endif

// Copied from Apple's header in case it is missing in some cases (e.g. pre-Xcode 8 builds).
#ifndef NSFoundationVersionNumber_iOS_9_x_Max
#define NSFoundationVersionNumber_iOS_9_x_Max 1299
#endif

@implementation AppDelegate (ILMCordovaPlugin)

static NSData *lastPush;
static NSString *fcmToken;
static NSString *apnsToken;
NSString *const kGCMMessageIDKey = @"gcm.message_id";

//Method swizzling
+ (void)load
{
    Method original =  class_getInstanceMethod(self, @selector(application:didFinishLaunchingWithOptions:));
    Method custom =    class_getInstanceMethod(self, @selector(application:customDidFinishLaunchingWithOptions:));
    method_exchangeImplementations(original, custom);

    Method originalNotification =  class_getInstanceMethod(self, @selector(userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:));
    Method customNotification =    class_getInstanceMethod(self, @selector(userNotificationCenter:customDidReceiveNotificationResponse:withCompletionHandler:));
    method_exchangeImplementations(originalNotification, customNotification);

    Method originalRegistrationToken =  class_getInstanceMethod(self, @selector(messaging:didReceiveRegistrationToken:));
    Method customRegistrationToken =    class_getInstanceMethod(self, @selector(messaging:customDidReceiveRegistrationToken:));
    method_exchangeImplementations(originalRegistrationToken, customRegistrationToken);

    NSLog(@"ILMCordovaPlugin: loaded swizzles");
}

- (BOOL)application:(UIApplication *)application customDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self application:application customDidFinishLaunchingWithOptions:launchOptions];
    
    NSLog(@"ILMCordovaPlugin: DidFinishLaunchingWithOptions");

    if([FIRApp defaultApp] == nil) {
        NSLog(@"ILMCordovaPlugin: FIRApp configure");
        [FIRApp configure];
    }    


    [FIRMessaging messaging].delegate = self;
    
    [self registerForNotifications:application];

    //[ILMInLoco init];

    NSLog(@"ILMCordovaPlugin: will init SDK");
    [ILMCordovaPlugin initSdk];
    

    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if ([ILMPushMessage isInLocoMessage:remoteNotificationPayload]) {
        NSLog(@"ILMCordovaPlugin: in loco notif payload");
        ILMPushMessage *message = [[ILMPushMessage alloc] initWithDictionary:remoteNotificationPayload];
        [ILMInLocoPush appDidFinishLaunchingWithMessage:message];
        [self handleNotificationClick:message];
    }

    return YES;
}



- (void)userNotificationCenter:(UNUserNotificationCenter *)center
customDidReceiveNotificationResponse:(UNNotificationResponse *)response
#if defined(__IPHONE_11_0) // Removes warnings on Xcode 9
    withCompletionHandler:(void(^)(void))completionHandler
#else
    withCompletionHandler:(void(^)())completionHandler
#endif
{
    [self userNotificationCenter:center customDidReceiveNotificationResponse:response withCompletionHandler:completionHandler];

    NSLog(@"ILMCordovaPlugin: did receive notification");
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    
    if ([ILMPushMessage isInLocoMessage:userInfo]) {
        ILMPushMessage *message = [[ILMPushMessage alloc] initWithDictionary:userInfo];
        [ILMInLocoPush didReceiveNotificationResponse:message completionBlock:^{
            completionHandler();
        }];
      
      NSLog(@"ILMCordovaPlugin: the notification comes from in loco");
      //Handle custom events for iOS 10 and 11 (i.e., opening a specific part of the App)
      //Custom actions can be accessed through the message.actions property
      [self handleNotificationClick:message];
    } else {
        // The remote message is from another service. Handle it here.
        completionHandler();
    }
}


- (void)registerForNotifications:(UIApplication *)application
{
    NSLog(@"ILMCordovaPlugin: register notifications");
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
#pragma clang diagnostic pop
    } else {
        // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        UNAuthorizationOptions authOptions =
        UNAuthorizationOptionAlert
        | UNAuthorizationOptionSound
        | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
        }];
#endif
    }
    
    [application registerForRemoteNotifications];
}


- (void)messaging:(FIRMessaging *)messaging customDidReceiveRegistrationToken:(NSString *)deviceToken 
{
    [self messaging:messaging customDidReceiveRegistrationToken:deviceToken];
    
    if (deviceToken) {
        ILMFirebaseProvider *firebaseProvider = [[ILMFirebaseProvider alloc] initWithToken:deviceToken];
        [ILMInLocoPush setPushProvider:firebaseProvider];
        NSLog(@"ILMCordovaPlugin: finished setting push provider with received token");
    } else {
        NSLog(@"ILMCordovaPlugin: setPushProvider - empty token");
    }
}

- (void)handleNotificationClick:(ILMPushMessage *)message
{
    NSLog(@"ILMCordovaPlugin: handle notification click");
    NSString *urlString = message.actions.firstObject;
    NSURL *url = [NSURL URLWithString:urlString];
    UIApplication *application = [UIApplication sharedApplication];
    
    if ([application canOpenURL:url]) {
       [application openURL:url options:@{} completionHandler:nil];
    }
}

// // [START message_handling]
// // Receive displayed notifications for iOS 10 devices.

// // Note on the pragma: When compiling with iOS 10 SDK, include methods that
// //                     handle notifications using notification center.
// #if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0

// // Handle incoming notification messages while app is in the foreground.
// - (void)userNotificationCenter:(UNUserNotificationCenter *)center
//        willPresentNotification:(UNNotification *)notification
//          withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
//     // Print message ID.
//     NSDictionary *userInfo = notification.request.content.userInfo;
//     if (userInfo[kGCMMessageIDKey]) {
//         NSLog(@"Message ID 1: %@", userInfo[kGCMMessageIDKey]);
//     }
    
//     // Print full message.
//     NSLog(@"%@", userInfo);
    
//     NSError *error;
//     NSDictionary *userInfoMutable = [userInfo mutableCopy];
//     NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfoMutable
//                                                        options:0
//                                                          error:&error];
//     [ILMCordovaPlugin.plugin notifyOfMessage:jsonData];
    
//     // Change this to your preferred presentation option
//     completionHandler(UNNotificationPresentationOptionNone);
// }

// // Handle notification messages after display notification is tapped by the user.
// - (void)userNotificationCenter:(UNUserNotificationCenter *)center
// didReceiveNotificationResponse:(UNNotificationResponse *)response
//          withCompletionHandler:(void (^)(void))completionHandler {
//     NSDictionary *userInfo = response.notification.request.content.userInfo;
//     if (userInfo[kGCMMessageIDKey]) {
//         NSLog(@"Message ID 2: %@", userInfo[kGCMMessageIDKey]);
//     }
    
//     // Print full message.
//     NSLog(@"aaa%@", userInfo);
    
//     NSError *error;
//     NSDictionary *userInfoMutable = [userInfo mutableCopy];
    
//     NSLog(@"New method with push callback: %@", userInfo);
    
//     [userInfoMutable setValue:@(YES) forKey:@"wasTapped"];
//     NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfoMutable options:0 error:&error];
//     NSLog(@"APP WAS CLOSED DURING PUSH RECEPTION Saved data: %@", jsonData);
//     lastPush = jsonData;
    
//     completionHandler();
// }
// #endif

// // [START receive_message in background iOS < 10]

// // Include the iOS < 10 methods for handling notifications for when running on iOS < 10.
// // As in, even if you compile with iOS 10 SDK, when running on iOS 9 the only way to get
// // notifications is the didReceiveRemoteNotification.

// #pragma clang diagnostic push
// #pragma clang diagnostic ignored "-Wdeprecated-implementations"
// - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
// {
//     // Short-circuit when actually running iOS 10+, let notification centre methods handle the notification.
//     if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_9_x_Max) {
//         return;
//     }
    
//     NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    
//     NSError *error;
//     NSDictionary *userInfoMutable = [userInfo mutableCopy];
    
//     if (application.applicationState != UIApplicationStateActive) {
//         NSLog(@"New method with push callback: %@", userInfo);
        
//         [userInfoMutable setValue:@(YES) forKey:@"wasTapped"];
//         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfoMutable options:0 error:&error];
//         NSLog(@"APP WAS CLOSED DURING PUSH RECEPTION Saved data: %@", jsonData);
//         lastPush = jsonData;
//     }
// }
// #pragma clang diagnostic pop
// // [END receive_message in background] iOS < 10]





// - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceTokenData {
// #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
//     NSString *deviceToken = [self hexadecimalStringFromData:deviceTokenData];
// #else
//     NSString *deviceToken = [[[[deviceTokenData description]
//         stringByReplacingOccurrencesOfString:@"<"withString:@""]
//         stringByReplacingOccurrencesOfString:@">" withString:@""]
//         stringByReplacingOccurrencesOfString: @" " withString: @""];
// #endif
//     apnsToken = deviceToken;
//     [ILMCordovaPlugin setInitialAPNSToken:deviceToken];
//     NSLog(@"Device APNS Token: %@", deviceToken);
// }

// // [START receive_message iOS < 10]
// - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
// fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
// {
//     // Short-circuit when actually running iOS 10+, let notification centre methods handle the notification.
//     if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_9_x_Max) {
//         return;
//     }
    
//     // If you are receiving a notification message while your app is in the background,
//     // this callback will not be fired till the user taps on the notification launching the application.
//     // TODO: Handle data of notification
    
//     // Print message ID.
//     NSLog(@"Message ID: %@", userInfo[@"gcm.message_id"]);
    
//     // Pring full message.
//     NSLog(@"%@", userInfo);
//     NSError *error;
    
//     NSDictionary *userInfoMutable = [userInfo mutableCopy];
    
//     // Has user tapped the notificaiton?
//     // UIApplicationStateActive   - app is currently active
//     // UIApplicationStateInactive - app is transitioning from background to
//     //                              foreground (user taps notification)
    
//     if (application.applicationState == UIApplicationStateActive
//         || application.applicationState == UIApplicationStateInactive) {
//         [userInfoMutable setValue:@(NO) forKey:@"wasTapped"];
//         NSLog(@"app active");
//         NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfoMutable
//                                                            options:0
//                                                              error:&error];
//         [ILMCordovaPlugin.plugin notifyOfMessage:jsonData];
        
//         // app is in background
//     }
    
//     completionHandler(UIBackgroundFetchResultNoData);
// }
// // [END receive_message iOS < 10]
// // [END message_handling]

// - (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)deviceToken {
//     NSLog(@"Device FCM Token: %@", deviceToken);
//     // Notify about received token.
//     NSDictionary *dataDict = [NSDictionary dictionaryWithObject:deviceToken forKey:@"token"];
//     [[NSNotificationCenter defaultCenter] postNotificationName:@"FCMToken" object:nil userInfo:dataDict];
//     fcmToken = deviceToken;
    
//     [ILMCordovaPlugin setInitialFCMToken:deviceToken];

//     NSLog(@"ILMCordovaPlugin: received token, will set push provider on in loco SDK");
//     [ILMCordovaPlugin.plugin notifyFCMTokenRefresh:deviceToken];

//     [self connectToFcm];
// }

// // [START connect_to_fcm]
// - (void)connectToFcm
// {
//     // Won't connect since there is no token
//     if (!fcmToken) {
//         return;
//     }
//     // Disconnect previous FCM connection if it exists.
//     [[FIRMessaging messaging] setShouldEstablishDirectChannel:NO];
    
//     [[FIRMessaging messaging] setShouldEstablishDirectChannel:YES];
    
//     [[FIRMessaging messaging] subscribeToTopic:@"ios"];
//     [[FIRMessaging messaging] subscribeToTopic:@"all"];
// }
// // [END connect_to_fcm]

// - (void)applicationDidBecomeActive:(UIApplication *)application
// {
//     NSLog(@"app become active");
//     [ILMCordovaPlugin.plugin appEnterForeground];
//     [self connectToFcm];
// }

// // [START disconnect_from_fcm]
// - (void)applicationDidEnterBackground:(UIApplication *)application
// {
//     NSLog(@"app entered background");
//     [[FIRMessaging messaging] setShouldEstablishDirectChannel:NO];
//     [ILMCordovaPlugin.plugin appEnterBackground];
//     NSLog(@"Disconnected from FCM");
// }
// // [END disconnect_from_fcm]

// +(NSData*)getLastPush
// {
//     NSData* returnValue = lastPush;
//     lastPush = nil;
//     return returnValue;
// }

// - (NSString *)hexadecimalStringFromData:(NSData *)data
// {
//     NSUInteger dataLength = data.length;
//     if (dataLength == 0) {
//         return nil;
//     }

//     const unsigned char *dataBuffer = data.bytes;
//     NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
//     for (int i = 0; i < dataLength; ++i) {
//         [hexString appendFormat:@"%02x", dataBuffer[i]];
//     }
//     return [hexString copy];
// }


@end