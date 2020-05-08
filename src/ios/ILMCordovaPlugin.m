
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

- (void)getInstallationId:(CDVInvokedUrlCommand *)command
{
    [ILMInLoco getInstallationId:^(NSString *installationId) {
        NSDictionary *data = [NSDictionary dictionaryWithObject:installationId forKey:@"installationId"];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK 
                                                      messageAsDictionary:data];
                                                        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
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

- (void)trackLocalizedEvent:(CDVInvokedUrlCommand *)command
{
    NSDictionary *params = [[command arguments] objectAtIndex:0];
    NSString *eventName = params[@"name"];
    NSDictionary *givenProperties = params[@"properties"];
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];

    for (NSString* key in givenProperties) {
        [properties setObject:[NSString stringWithFormat:@"%@", [givenProperties valueForKey:key]] forKey:key];
    }

    [ILMInLocoVisits trackLocalizedEvent:eventName properties:properties];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)registerCheckIn:(CDVInvokedUrlCommand *)command
{
    NSDictionary *params = [[command arguments] objectAtIndex:0];
    NSString *placeName = params[@"placeName"];
    NSString *placeId = params[@"placeId"];
    NSDictionary *givenExtras = params[@"extras"];
    NSDictionary *address = params[@"address"];

    NSMutableDictionary *extras = [[NSMutableDictionary alloc] init];

    for (NSString* key in givenExtras) {
        [extras setObject:[NSString stringWithFormat:@"%@", [givenExtras valueForKey:key]] forKey:key];
    }

    ILMCheckIn *checkIn = [[ILMCheckIn alloc] init];
    checkIn.placeId = placeId;
    checkIn.placeName = placeName;
    checkIn.extras = extras;

    if (address != nil && [address count] > 0) {
        ILMUserAddress *userAddress = [self addressFromDictionary:address];
        checkIn.userAddress = userAddress;
    }

    [ILMInLocoVisits registerCheckIn:checkIn];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setAddress:(CDVInvokedUrlCommand *)command
{
    NSDictionary *params = [[command arguments] objectAtIndex:0];
    
    ILMUserAddress *userAddress = [self addressFromDictionary:params];

    [ILMInLocoAddressValidation setUserAddress:userAddress];

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (ILMUserAddress *)addressFromDictionary:(NSDictionary *)address
{  
    ILMUserAddress *userAddress = [[ILMUserAddress alloc] init];

    [userAddress setCountryName:address[@"countryName"]];
    [userAddress setCountryCode:address[@"countryCode"]];
    [userAddress setAdminArea:address[@"adminArea"]];
    [userAddress setSubAdminArea:address[@"subAdminArea"]];
    [userAddress setLocality:address[@"locality"]];
    [userAddress setSubLocality:address[@"subLocality"]];
    [userAddress setThoroughfare:address[@"thoroughfare"]];
    [userAddress setSubThoroughfare:address[@"subThoroughfare"]];
    [userAddress setPostalCode:address[@"postalCode"]];

    [userAddress setLatitude:address[@"latitude"]];
    [userAddress setLongitude:address[@"longitude"]];

    if (address[@"locale"]) {
        NSString *parsedLocale = [address[@"locale"] stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:parsedLocale];
        [userAddress setLocale:locale];
    }

    return userAddress;
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
