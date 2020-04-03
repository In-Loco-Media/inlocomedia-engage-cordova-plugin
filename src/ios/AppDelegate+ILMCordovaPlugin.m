#import "AppDelegate+ILMCordovaPlugin.h"
#import "ILMCordovaPlugin.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

@import FirebaseMessaging;
@import FirebaseCore;

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
}

- (BOOL)application:(UIApplication *)application customDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self application:application customDidFinishLaunchingWithOptions:launchOptions];

    if ([FIRApp defaultApp] == nil) {
        [FIRApp configure];
    }    

    [FIRMessaging messaging].delegate = self;
    
    [self registerForNotifications:application];
    
    [ILMInLoco initSdk];
    
    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if ([ILMPushMessage isInLocoMessage:remoteNotificationPayload]) {
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

    NSDictionary *userInfo = response.notification.request.content.userInfo;
    
    if ([ILMPushMessage isInLocoMessage:userInfo]) {
        ILMPushMessage *message = [[ILMPushMessage alloc] initWithDictionary:userInfo];
        [ILMInLocoPush didReceiveNotificationResponse:message completionBlock:^{
            completionHandler();
        }];
      
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


- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)deviceToken 
{    
    if (deviceToken) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            ILMFirebaseProvider *firebaseProvider = [[ILMFirebaseProvider alloc] initWithToken:deviceToken];
            [ILMInLocoPush setPushProvider:firebaseProvider];
        });
    }
}

- (void)handleNotificationClick:(ILMPushMessage *)message
{
    NSString *urlString = message.actions.firstObject;
    NSURL *url = [NSURL URLWithString:urlString];
    UIApplication *application = [UIApplication sharedApplication];
    
    if ([application canOpenURL:url]) {
       [application openURL:url options:@{} completionHandler:nil];
    }
}

@end