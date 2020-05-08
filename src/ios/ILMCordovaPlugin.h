
#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>
#import <UIKit/UIKit.h>

@interface ILMCordovaPlugin : CDVPlugin

- (void)setUser:(CDVInvokedUrlCommand *)command;
- (void)clearUser:(CDVInvokedUrlCommand *)command;
- (void)getInstallationId:(CDVInvokedUrlCommand *)command;
- (void)trackEvent:(CDVInvokedUrlCommand *)command;
- (void)registerCheckIn:(CDVInvokedUrlCommand *)command;
- (void)setAddress:(CDVInvokedUrlCommand *)command;
- (void)clearAddress:(CDVInvokedUrlCommand *)command;
- (void)givePrivacyConsent:(CDVInvokedUrlCommand *)command;
- (void)checkPrivacyConsentMissing:(CDVInvokedUrlCommand *)command;
- (void)checkConsent:(CDVInvokedUrlCommand *)command;
- (void)requestPrivacyConsent:(CDVInvokedUrlCommand *)command;
- (void)setAllowedConsentTypes:(CDVInvokedUrlCommand *)command;
- (void)allowConsentTypes:(CDVInvokedUrlCommand *)command;
- (void)denyConsentTypes:(CDVInvokedUrlCommand *)command;

@end