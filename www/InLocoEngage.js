var argscheck = require('cordova/argscheck');
var exec = require('cordova/exec');
var cordova = require("cordova");
var inLocoEngageExport = {};

inLocoEngageExport.OPTIONS = {
  // Initialization options
  APP_ID: 'appId',
  DEVELOPMENT_DEVICES: 'developmentDevices',
  LOGS_ENABLED: 'logsEnabled',
  LOCATION_TRACKIN_GENABLED: 'locationTrackingEnabled',
  SCREEN_TRACKING_ENABLED: 'screenTrackingEnabled',
  REQUIRES_USER_PRIVACY_CONSENT: 'requiresUserPrivacyConsent',

  // requestPermissions options
  ASK_IF_DENIED: 'askIfDenied',

  // setPushNotificationsEnabled options
  ENABLED: 'enabled',

  // setPushProvider options
  PUSH_PROVIDER_NAME: 'name',
  PUSH_PROVIDER_TOKEN: 'token',

  // setUser options
  USER_ID: 'userId',

  // trackEvent options
  EVENT_NAME: 'name',
  EVENT_PROPERTIES: 'properties',

  // givePrivacyConsent options
  CONSENT_STATE: 'consent',

  // presentNotification options
  NOTIFICATION_DATA: 'data',
  NOTIFICATION_ICON_NAME: 'notificationIconName',
  NOTIFICATION_ID: 'notificationId',
  NOTIFICATION_CHANNEL_ID: 'notificationChannelId'
};

inLocoEngageExport.ACTIONS = {
  INITIALIZATION: 'initWithOptions',
  REQUEST_PERMISSIONS: 'requestPermissions',
  IS_PUSH_NOTIFICATIONS_ENABLED: 'isPushNotificationsEnabled',
  SET_PUSH_NOTIFICATIONS_ENABLED: 'setPushNotificationsEnabled',
  SET_PUSH_PROVIDER: 'setPushProvider',
  SET_USER: 'setUser',
  CLEAR_USER: 'clearUser',
  TRACK_EVENT: 'trackEvent',
  HAS_GIVEN_PRIVACY_CONSENT: 'hasGivenPrivacyConsent',
  GIVE_PRIVACY_CONSENT: 'givePrivacyConsent',
  IS_WAITING_USER_PRIVACY_CONSENT: 'isWaitingUserPrivacyConsent',
  PRESENT_NOTIFICATION: 'presentNotification'
};


inLocoEngageExport.initWithOptions = function(args, successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.INITIALIZATION, [args]);
};

inLocoEngageExport.requestPermissions = function(args, successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.REQUEST_PERMISSIONS, [args]);
};

inLocoEngageExport.isPushNotificationsEnabled = function(successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.IS_PUSH_NOTIFICATIONS_ENABLED, []);
};

inLocoEngageExport.setPushNotificationsEnabled = function(args, successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.SET_PUSH_NOTIFICATIONS_ENABLED, [args]);
};

inLocoEngageExport.setPushProvider = function(args, successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.SET_PUSH_PROVIDER, [args]);
};

inLocoEngageExport.setUser = function(args, successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.SET_USER, [args]);
};

inLocoEngageExport.clearUser = function(successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.CLEAR_USER, []);
}

inLocoEngageExport.trackEvent = function(args, successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.TRACK_EVENT, [args]);
};

inLocoEngageExport.hasGivenPrivacyConsent = function(successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.HAS_GIVEN_PRIVACY_CONSENT, []);
};

inLocoEngageExport.givePrivacyConsent = function(args, successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.GIVE_PRIVACY_CONSENT, [args]);
};

inLocoEngageExport.isWaitingUserPrivacyConsent = function(successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.IS_WAITING_USER_PRIVACY_CONSENT, []);
};

inLocoEngageExport.presentNotification = function(args, successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.PRESENT_NOTIFICATION, [args]);
};


inLocoEngageExport.hasPermission = function(success, error) {
  if (cordova.platformId !== 'ios') {
    success(true);
    return;
  }
  cordova.exec(success, error, 'InLocoEngage', 'hasPermission', []);
};

inLocoEngageExport.subscribeToTopic = function(topic, success, error) {
  cordova.exec(success, error, 'InLocoEngage', 'subscribeToTopic', [topic]);
};

inLocoEngageExport.unsubscribeFromTopic = function(topic, success, error) {
  cordova.exec(success, error, 'InLocoEngage', 'unsubscribeFromTopic', [topic]);
};

inLocoEngageExport.onNotification = function(callback, success, error) {
  InLocoEngage.onNotificationReceived = callback;
  //inLocoEngageExport.onNotificationReceived = callback; ???
  exec(success, error, 'InLocoEngage', 'registerNotification', []);
};

inLocoEngageExport.onTokenRefresh = function(callback) {
  InLocoEngage.onTokenRefreshReceived = callback;
};

inLocoEngageExport.getToken = function(success, error) {
  exec(success, error, 'InLocoEngage', 'getToken', []);
};

inLocoEngageExport.onNotificationReceived = function(payload) {
  console.log("ILMCordovaPlugin: JS: Received push notification");
  console.log(payload);
};

// DEFAULT TOKEN REFRESH CALLBACK //
inLocoEngageExport.onTokenRefreshReceived = function(token) {
  console.log("ILMCordovaPlugin: JS: Received token refresh");
  console.log(token);
};

// function InLocoEngage() {
//   console.log("InLocoEngage.js: is created");
// }

// // CHECK FOR PERMISSION
// InLocoEngage.prototype.hasPermission = function(success, error) {
//   if (cordova.platformId !== "ios") {
//     success(true);
//     return;
//   }
//   exec(success, error, "InLocoEngage", "hasPermission", []);
// };

// // SUBSCRIBE TO TOPIC //
// InLocoEngage.prototype.subscribeToTopic = function(topic, success, error) {
//   exec(success, error, "InLocoEngage", "subscribeToTopic", [topic]);
// };

// // UNSUBSCRIBE FROM TOPIC //
// InLocoEngage.prototype.unsubscribeFromTopic = function(topic, success, error) {
//   exec(success, error, "InLocoEngage", "unsubscribeFromTopic", [topic]);
// };

// NOTIFICATION CALLBACK //


// // TOKEN REFRESH CALLBACK //
// InLocoEngage.prototype.onTokenRefresh = function(callback) {
//   InLocoEngage.prototype.onTokenRefreshReceived = callback;
// };

// GET TOKEN //
// InLocoEngage.prototype.getToken = function(success, error) {
//   exec(success, error, "InLocoEngage", "getToken", []);
// };

// // GET APNS TOKEN //
// InLocoEngage.prototype.getAPNSToken = function(success, error) {
//   if (cordova.platformId !== "ios") {
//     success(null);
//     return;
//   }
//   exec(success, error, "InLocoEngage", "getAPNSToken", []);
// };

// // CLEAR ALL NOTIFICATIONS //
// InLocoEngage.prototype.clearAllNotifications = function(success, error) {
//   exec(success, error, "InLocoEngage", "clearAllNotifications", []);
// };

// // DEFAULT NOTIFICATION CALLBACK //




// FIRE READY //
cordova.exec(
  function(result) {
    console.log("ILMCordovaPlugin Ready OK");
  },
  function(result) {
    console.log("FCMPILMCordovaPluginlugin Ready ERROR");
  },
  "InLocoEngage",
  "ready",
  []
);

//var fcmPlugin = new InLocoEngage();

//module.exports = fcmPlugin;
module.exports = inLocoEngageExport;