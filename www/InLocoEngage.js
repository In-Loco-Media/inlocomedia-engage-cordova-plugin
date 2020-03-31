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

module.exports = inLocoEngageExport;