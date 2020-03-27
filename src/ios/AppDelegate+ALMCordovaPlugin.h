#import "AppDelegate.h"
#import <UIKit/UIKit.h>
#import <Cordova/CDVViewController.h>

@interface AppDelegate (ALMCordovaPlugin)

+ (NSData*)getLastPush;

@end
