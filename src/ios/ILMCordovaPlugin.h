
#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>
#import <UIKit/UIKit.h>

@interface ILMCordovaPlugin : CDVPlugin

- (void)setUser:(CDVInvokedUrlCommand *)command;
- (void)clearUser:(CDVInvokedUrlCommand *)command;
- (void)trackEvent:(CDVInvokedUrlCommand *)command;
- (void)registerCheckIn:(CDVInvokedUrlCommand *)command;
- (void)setAddress:(CDVInvokedUrlCommand *)command;
- (void)clearAddress:(CDVInvokedUrlCommand *)command;
- (void)givePrivacyConsent:(CDVInvokedUrlCommand *)command;
- (void)checkPrivacyConsentMissing:(CDVInvokedUrlCommand *)command;

@end