var argscheck = require('cordova/argscheck');
var exec = require('cordova/exec');
var inLocoEngageExport = {};

inLocoEngageExport.OPTIONS = {
  // setUser options
  USER_ID: 'userId',

  // trackEvent options
  EVENT_NAME: 'name',
  EVENT_PROPERTIES: 'properties',

  // givePrivacyConsent options
  CONSENT_STATE: 'consent'
};

inLocoEngageExport.ACTIONS = {
  SET_USER: 'setUser',
  CLEAR_USER: 'clearUser',
  TRACK_EVENT: 'trackEvent',
  GIVE_PRIVACY_CONSENT: 'givePrivacyConsent'
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

inLocoEngageExport.givePrivacyConsent = function(args, successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.GIVE_PRIVACY_CONSENT, [args]);
};

module.exports = inLocoEngageExport;