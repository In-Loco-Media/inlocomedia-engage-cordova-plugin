
@import InLocoSDK;

#import "ILMCordovaPlugin.h"

@implementation ILMCordovaPlugin

- (void)setUser:(CDVInvokedUrlCommand *)command
{
    NSDictionary *params = [[command arguments] objectAtIndex:0];
    NSString *userId = params[@"userId"];

    if (userId != nil) {
        [ILMInLoco setUserId:userId];
    }

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)clearUser:(CDVInvokedUrlCommand *)command
{
    [ILMInLoco clearUserId];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)trackEvent:(CDVInvokedUrlCommand *)command
{
    NSDictionary *params = [[command arguments] objectAtIndex:0];
    NSString *eventName = params[@"name"];
    NSDictionary *givenProperties = params[@"properties"];
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];

    for (NSString* key in givenProperties) {
        [properties setObject:[NSString stringWithFormat:@"%@", [givenProperties valueForKey:key]] forKey:key];
    }

    [ILMInLocoEvents trackEvent:eventName properties:properties];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)registerCheckIn:(CDVInvokedUrlCommand *)command
{
    NSLog(@"Check in is not available for iOS");
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setAddress:(CDVInvokedUrlCommand *)command
{
    NSDictionary *params = [[command arguments] objectAtIndex:0];
    
    NSDictionary *localeDict = [NSDictionary dictionaryWithObjectsAndKeys:
    params[@"language"], NSLocaleLanguageCode, params[@"country"], NSLocaleCountryCode, nil];

    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:[NSLocale localeIdentifierFromComponents: localeDict]];
    
    ILMUserAddress *userAddress = [[ILMUserAddress alloc] init];

    [userAddress setLocale:locale];
    [userAddress setCountryName:params[@"countryName"]];
    [userAddress setCountryCode:params[@"countryCode"]];
    [userAddress setAdminArea:params[@"adminArea"]];
    [userAddress setSubAdminArea:params[@"subAdminArea"]];
    [userAddress setLocality:params[@"locality"]];
    [userAddress setSubLocality:params[@"subLocality"]];
    [userAddress setThoroughfare:params[@"thoroughfare"]];
    [userAddress setSubThoroughfare:params[@"subThoroughfare"]];
    [userAddress setPostalCode:params[@"postalCode"]];

    [userAddress setLatitude:params[@"latitude"]];
    [userAddress setLongitude:params[@"longitude"]];

    [ILMInLocoAddressValidation setUserAddress:userAddress];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)clearAddress:(CDVInvokedUrlCommand *)command
{
    [ILMInLocoAddressValidation clearUserAddress];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)givePrivacyConsent:(CDVInvokedUrlCommand *)command
{
    NSDictionary *params = [[command arguments] objectAtIndex:0];
    NSNumber *consent = params[@"consent"];
    NSArray *consentTypes = params[@"consentTypes"];
    CDVPluginResult *pluginResult = nil;

    if (consent != nil) {
        [ILMInLoco giveUserPrivacyConsent:consent.boolValue];
        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
    } else if (consentTypes != nil) {
        NSSet *consentTypesSet = [NSSet setWithArray:consentTypes];
        [ILMInLoco giveUserPrivacyConsentForTypes:consentTypesSet];
        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString:@"Missing or incorrect argument passed to method."];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)checkPrivacyConsentMissing:(CDVInvokedUrlCommand *)command
{
    [ILMInLoco checkPrivacyConsentMissing:^(BOOL consentMissing) {
        NSLog(@"Consent missing: %@", @(consentMissing));

        NSDictionary *data = [NSDictionary dictionaryWithObject:@(consentMissing) forKey:@"isConsentMissing"];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK 
                                                      messageAsDictionary:data];
                                                        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)checkConsent:(CDVInvokedUrlCommand *)command
{
    NSDictionary *params = [[command arguments] objectAtIndex:0];
    NSArray *consentTypesArray = params[@"consentTypes"];
    NSSet *consentTypes = [NSSet setWithArray:consentTypesArray];

    [ILMInLoco checkConsentForTypes:consentTypes withBlock:^(ILMConsentResult *result) {
        CDVPluginResult *pluginResult = nil;
        if (result && [result hasFinished]) {
            BOOL isWaitingConsent = [result isWaitingConsent];
            BOOL areAllConsentTypesGiven = [result areAllConsentTypesGiven];

            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:@(isWaitingConsent), @"isWaitingConsent",
                                                                            @(areAllConsentTypesGiven), @"areAllConsentTypesGiven", nil];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK 
                                         messageAsDictionary:data];
        
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                             messageAsString:@"Error while checking consent."];
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)requestPrivacyConsent:(CDVInvokedUrlCommand *)command
{
    NSDictionary *params = [[command arguments] objectAtIndex:0];
    NSString *title = params[@"consentDialogTitle"];
    NSString *message = params[@"consentDialogMessage"];
    NSString *acceptText = params[@"consentDialogAcceptText"];
    NSString *denyText = params[@"consentDialogDenyText"];
    NSArray *consentTypesArray = params[@"consentTypes"];
    NSSet *consentTypes = consentTypesArray ? [NSSet setWithArray:consentTypesArray] : nil;

    ILMConsentDialogOptionsBuilder *builder = [[ILMConsentDialogOptionsBuilder alloc] init];
    [builder setTitle:title];
    [builder setMessage:message];
    [builder setAcceptText:acceptText];
    [builder setDenyText:denyText];
    [builder setConsentTypes:consentTypes];


    ILMError *err;

    [ILMInLoco requestPrivacyConsentWithOptions:[builder build:&err] andConsentBlock:^(ILMConsentResult *result) {
        CDVPluginResult *pluginResult = nil;
        if (result && [result hasFinished]) {
            BOOL isWaitingConsent = [result isWaitingConsent];
            BOOL areAllConsentTypesGiven = [result areAllConsentTypesGiven];

            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:@(isWaitingConsent), @"isWaitingConsent",
                                                                            @(areAllConsentTypesGiven), @"areAllConsentTypesGiven", nil];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK 
                                         messageAsDictionary:data];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                             messageAsString:@"Error while requesting privacy consent. Privacy consent not set."];
            
        }

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)setAllowedConsentTypes:(CDVInvokedUrlCommand *)command
{
    NSDictionary *params = [[command arguments] objectAtIndex:0];
    NSArray *consentTypesArray = params[@"consentTypes"];
    NSSet *consentTypes = [NSSet setWithArray:consentTypesArray];

    [ILMInLoco setAllowedConsentTypes:consentTypes];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)allowConsentTypes:(CDVInvokedUrlCommand *)command
{
    NSDictionary *params = [[command arguments] objectAtIndex:0];
    NSArray *consentTypesArray = params[@"consentTypes"];
    NSSet *consentTypes = [NSSet setWithArray:consentTypesArray];

    [ILMInLoco allowConsentTypes:consentTypes];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)denyConsentTypes:(CDVInvokedUrlCommand *)command
{
    NSDictionary *params = [[command arguments] objectAtIndex:0];
    NSArray *consentTypesArray = params[@"consentTypes"];
    NSSet *consentTypes = [NSSet setWithArray:consentTypesArray];

    [ILMInLoco denyConsentTypes:consentTypes];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
