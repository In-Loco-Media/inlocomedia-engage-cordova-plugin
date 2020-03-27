
#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>
#import <UIKit/UIKit.h>

@interface ILMCordovaPlugin : CDVPlugin

- (void)initWithOptions:(CDVInvokedUrlCommand *)command;
// - (void)hasGivenPrivacyConsent:(CDVInvokedUrlCommand *)command;
// - (void)givePrivacyConsent:(CDVInvokedUrlCommand *)command;
// - (void)isWaitingUserPrivacyConsent:(CDVInvokedUrlCommand *)command;

+ (ILMCordovaPlugin *) plugin;
+ (void)setInitialAPNSToken:(NSString*) token;
+ (void)setInitialFCMToken:(NSString*) token;
- (void)notifyFCMTokenRefresh:(NSString*) token;
- (void)ready:(CDVInvokedUrlCommand*)command;
- (void)hasPermission:(CDVInvokedUrlCommand*)command;
- (void)getToken:(CDVInvokedUrlCommand*)command;
- (void)getAPNSToken:(CDVInvokedUrlCommand*)command;
- (void)clearAllNotifications:(CDVInvokedUrlCommand *)command;
- (void)subscribeToTopic:(CDVInvokedUrlCommand*)command;
- (void)unsubscribeFromTopic:(CDVInvokedUrlCommand*)command;
- (void)registerNotification:(CDVInvokedUrlCommand*)command;
- (void)notifyOfMessage:(NSData*) payload;
- (void)appEnterBackground;
- (void)appEnterForeground;
+ (void)initSdk;

@end