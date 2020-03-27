
@import InLocoSDK;

#import "ILMCordovaPlugin.h"

#include <sys/types.h>
#include <sys/sysctl.h>

#import "AppDelegate+ALMCordovaPlugin.h"
#import <UserNotifications/UserNotifications.h>
#import "Firebase.h"

@interface ILMCordovaPlugin()

+ (void)setPushProvider:(NSString *)token;

@end

@implementation ILMCordovaPlugin

static BOOL notificatorReceptorReady = NO;
static BOOL appInForeground = YES;

static NSString *notificationCallback = @"InLocoEngage.onNotificationReceived";
static NSString *tokenRefreshCallback = @"InLocoEngage.onTokenRefreshReceived";
static NSString *apnsToken = nil;
static NSString *fcmToken = nil;
static ILMCordovaPlugin *pluginInstance;

- (void)initWithOptions:(CDVInvokedUrlCommand *)command
{
    NSDictionary *params = [[command arguments] objectAtIndex:0];
    NSString *appId = params[@"appId"];
    NSNumber *logsEnabled = params[@"logsEnabled"];
    NSNumber *requiresUserPrivacyConsent = params[@"requiresUserPrivacyConsent"];
    NSArray *developmentDevices = params[@"developmentDevices"];

    ILMOptions *options = [[ILMOptions alloc] init];
    [options setApplicationId:appId];
    [options setLogEnabled:logsEnabled ? [logsEnabled boolValue] : YES];
    [options setUserPrivacyConsentRequired:requiresUserPrivacyConsent ? [requiresUserPrivacyConsent boolValue] : NO];
    [options setDevelopmentDevices:developmentDevices];

    [self.commandDelegate runInBackground:^{
        [ILMInLoco initSdkWithOptions:options];
    }];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

+ (ILMCordovaPlugin *) plugin {
    return pluginInstance;
}

+ (void) setInitialAPNSToken:(NSString *)token
{
    NSLog(@"setInitialAPNSToken token: %@", token);
    apnsToken = token;
}

+ (void) setInitialFCMToken:(NSString *)token
{
    NSLog(@"setInitialFCMToken token: %@", token);
    NSLog(@"ILMCordovaPlugin: received token set inital fcm token");

    [ILMCordovaPlugin setPushProvider:token];

    fcmToken = token;
}

- (void) ready:(CDVInvokedUrlCommand *)command
{
    NSLog(@"Cordova view ready");
    pluginInstance = self;
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

+ (void) initSdk
{
    NSLog(@"ILMCordovaPlugin: INITSDK");
    ILMOptions *options = [[ILMOptions alloc] init];
    [options setApplicationId:@"c81ed294-10a4-437d-868e-67b34105b260"];
    [options setLogEnabled: YES];
    [options setUserPrivacyConsentRequired:NO];

    NSLog(@"ILMCordovaPlugin: called sdk init on background");
    [ILMInLoco initSdkWithOptions:options];
    NSLog(@"ILMCordovaPlugin: finished sdk init on background");

    [ILMInLoco setUserId:@"cordovaTestJulia0"];
}

+ (void) setPushProvider:(NSString *)token
{
    if (token) {
        ILMFirebaseProvider *firebaseProvider = [[ILMFirebaseProvider alloc] initWithToken:token];
        [ILMInLocoPush setPushProvider:firebaseProvider];
        NSLog(@"ILMCordovaPlugin: finished setting push provider with received token");
    } else {
        NSLog(@"ILMCordovaPlugin: setPushProvider - empty token");
    }
}

// HAS PERMISSION //
- (void) hasPermission:(CDVInvokedUrlCommand *)command
{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    __block CDVPluginResult *commandResult;
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings){
        switch (settings.authorizationStatus) {
            case UNAuthorizationStatusAuthorized: {
                NSLog(@"has push permission: true");
                commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:YES];
                break;
            }
            case UNAuthorizationStatusDenied: {
                NSLog(@"has push permission: false");
                commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:NO];
                break;
            }
            default: {
                NSLog(@"has push permission: unknown");
                commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                break;
            }
        }
        [self.commandDelegate sendPluginResult:commandResult callbackId:command.callbackId];
    }];
}

// GET TOKEN //
- (void) getToken:(CDVInvokedUrlCommand *)command 
{
    NSLog(@"get Token");
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:fcmToken];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

// GET APNS TOKEN //
- (void) getAPNSToken:(CDVInvokedUrlCommand *)command 
{
    NSLog(@"get APNS Token");
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:apnsToken];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

// CLEAR ALL NOTIFICATONS //
- (void)clearAllNotifications:(CDVInvokedUrlCommand *)command
{
  [self.commandDelegate runInBackground:^{
    NSLog(@"clear all notifications");
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
  }];
}

// UN/SUBSCRIBE TOPIC //
- (void) subscribeToTopic:(CDVInvokedUrlCommand *)command 
{
    NSString* topic = [command.arguments objectAtIndex:0];
    NSLog(@"subscribe To Topic %@", topic);
    [self.commandDelegate runInBackground:^{
        if(topic != nil)[[FIRMessaging messaging] subscribeToTopic:topic];
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:topic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) unsubscribeFromTopic:(CDVInvokedUrlCommand *)command 
{
    NSString* topic = [command.arguments objectAtIndex:0];
    NSLog(@"unsubscribe From Topic %@", topic);
    [self.commandDelegate runInBackground:^{
        if(topic != nil)[[FIRMessaging messaging] unsubscribeFromTopic:topic];
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:topic];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) registerNotification:(CDVInvokedUrlCommand *)command
{
    NSLog(@"view registered for notifications");
    
    notificatorReceptorReady = YES;
    NSData* lastPush = [AppDelegate getLastPush];
    if (lastPush != nil) {
        [ILMCordovaPlugin.plugin notifyOfMessage:lastPush];
    }
    
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void) notifyOfMessage:(NSData *)payload
{
    NSString *JSONString = [[NSString alloc] initWithBytes:[payload bytes] length:[payload length] encoding:NSUTF8StringEncoding];
    NSString * notifyJS = [NSString stringWithFormat:@"%@(%@);", notificationCallback, JSONString];
    NSLog(@"stringByEvaluatingJavaScriptFromString %@", notifyJS);
    
    if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
        [(UIWebView *)self.webView stringByEvaluatingJavaScriptFromString:notifyJS];
    } else {
        [self.webViewEngine evaluateJavaScript:notifyJS completionHandler:nil];
    }
}

-(void) notifyFCMTokenRefresh:(NSString *)token
{
    NSLog(@"notifyFCMTokenRefresh token: %@", token);
    fcmToken = token;
    NSString * notifyJS = [NSString stringWithFormat:@"%@('%@');", tokenRefreshCallback, token];
    NSLog(@"stringByEvaluatingJavaScriptFromString %@", notifyJS);
    
    if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
        [(UIWebView *)self.webView stringByEvaluatingJavaScriptFromString:notifyJS];
    } else {
        [self.webViewEngine evaluateJavaScript:notifyJS completionHandler:nil];
    }

    [ILMCordovaPlugin setPushProvider:token];
}

-(void) appEnterBackground
{
    NSLog(@"Set state background");
    appInForeground = NO;
}

-(void) appEnterForeground
{
    NSLog(@"Set state foreground");
    NSData* lastPush = [AppDelegate getLastPush];
    if (lastPush != nil) {
        [ILMCordovaPlugin.plugin notifyOfMessage:lastPush];
    }
    appInForeground = YES;
}


@end