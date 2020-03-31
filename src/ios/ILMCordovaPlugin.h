
#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>
#import <UIKit/UIKit.h>

@interface ILMCordovaPlugin : CDVPlugin

- (void)initWithOptions:(CDVInvokedUrlCommand *)command;
// - (void)hasGivenPrivacyConsent:(CDVInvokedUrlCommand *)command;
// - (void)givePrivacyConsent:(CDVInvokedUrlCommand *)command;
// - (void)isWaitingUserPrivacyConsent:(CDVInvokedUrlCommand *)command;

@end