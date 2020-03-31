
@import InLocoSDK;

#import "ILMCordovaPlugin.h"

@implementation ILMCordovaPlugin

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


@end