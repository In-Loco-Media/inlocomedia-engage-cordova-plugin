var argscheck = require('cordova/argscheck');
var exec = require('cordova/exec');
var cordova = require("cordova");
var inLocoEngageExport = {};

inLocoEngageExport.OPTIONS = {
  // setUser options
  USER_ID: 'userId',

  // trackEvent options
  EVENT_NAME: 'name',
  EVENT_PROPERTIES: 'properties',

  // checkIn options
  PLACE_NAME: 'placeName',
  PLACE_ID: 'placeId',
  EXTRAS: 'extras',
  ADDRESS: 'address',

  // addressValidation options
  LANGUAGE: 'language',
  COUNTRY: 'country',
  COUNTRY_NAME: 'countryName',
  COUNTRY_CODE: 'countryCode',
  ADMIN_AREA: 'adminArea',
  SUB_ADMIN_AREA: 'subAdminArea',
  LOCALITY: 'locality',
  SUB_LOCALITY: 'subLocality',
  THOROUGHFARE: 'thoroughfare',
  SUB_THOROUGHFARE: 'subThoroughfare',
  POSTAL_CODE: 'postalCode',
  LATITUDE: 'latitude',
  LONGITUDE: 'longitude',

  // givePrivacyConsent options
  CONSENT: 'consent',
  CONSENT_TYPES: 'consentTypes',

  // consent dialog options
  CONSENT_DIALOG_TITLE: 'consentDialogTitle',
  CONSENT_DIALOG_MESSAGE: 'consentDialogMessage',
  CONSENT_DIALOG_ACCEPT_TEXT: 'consentDialogAcceptText',
  CONSENT_DIALOG_DENY_TEXT: 'consentDialogDenyText',
  //CONSENT_TYPES: 'consentTypes',

  // consentTypes options
  ADDRESS_VALIDATION: "address_validation",
  ADVERTISEMENT: "advertisement",
  ENGAGE: "engage",
  EVENTS: "analytics",
  INSTALLED_APPS: "installed_apps",
  LOCATION: "location",
  CONTEXT_PROVIDER: "context_provider",
  COVID_19: "covid_19_aid"
};

inLocoEngageExport.ACTIONS = {
  SET_USER: 'setUser',
  CLEAR_USER: 'clearUser',
  GET_INSTALLATION_ID: 'getInstallationId',
  TRACK_EVENT: 'trackEvent',
  TRACK_LOCALIZED_EVENT: 'trackLocalizedEvent',
  REGISTER_CHECK_IN: 'registerCheckIn',
  SET_ADDRESS: 'setAddress',
  CLEAR_ADDRESS: 'clearAddress',
  REQUEST_PRIVACY_CONSENT: 'requestPrivacyConsent',
  GIVE_PRIVACY_CONSENT: 'givePrivacyConsent',
  ALLOW_CONSENT_TYPES: 'allowConsentTypes',
  SET_ALLOWED_CONSENT_TYPES: 'setAllowedConsentTypes',
  CHECK_CONSENT: 'checkConsent',
  CHECK_PRIVACY_CONSENT_MISSING: 'checkPrivacyConsentMissing',
  DENY_CONSENT_TYPES: 'denyConsentTypes'
};

inLocoEngageExport.setUser = function(args, successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.SET_USER, [args]);
};

inLocoEngageExport.clearUser = function(successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.CLEAR_USER, []);
}

inLocoEngageExport.getInstallationId = function(successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.GET_INSTALLATION_ID, []);
};

inLocoEngageExport.trackEvent = function(args, successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.TRACK_EVENT, [args]);
};

inLocoEngageExport.trackLocalizedEvent = function(args, successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.TRACK_LOCALIZED_EVENT, [args]);
};

inLocoEngageExport.registerCheckIn = function(args, successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.REGISTER_CHECK_IN, [args]);
};

inLocoEngageExport.setAddress = function(args, successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.SET_ADDRESS, [args]);
};

inLocoEngageExport.clearAddress = function(successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.CLEAR_ADDRESS, []);
}

inLocoEngageExport.requestPrivacyConsent = function(args, successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.REQUEST_PRIVACY_CONSENT, [args]);
};

inLocoEngageExport.givePrivacyConsent = function(args, successCallback, failureCallback) {
  if (args.hasOwnProperty('consent') && args.consent != null && !(typeof args.consent === 'boolean')) {
    args.consent = stringToBoolean(args.consent.toString());
  }

  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.GIVE_PRIVACY_CONSENT, [args]);
};

inLocoEngageExport.allowConsentTypes = function(args, successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.ALLOW_CONSENT_TYPES, [args]);
};

inLocoEngageExport.setAllowedConsentTypes = function(args, successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.SET_ALLOWED_CONSENT_TYPES, [args]);
};

inLocoEngageExport.checkConsent = function(args, successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.CHECK_CONSENT, [args]);
};

inLocoEngageExport.checkPrivacyConsentMissing = function(successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.CHECK_PRIVACY_CONSENT_MISSING, []);
};

inLocoEngageExport.denyConsentTypes = function(args, successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.DENY_CONSENT_TYPES, [args]);
};

module.exports = inLocoEngageExport;

function stringToBoolean (string) {
  switch(string.toLowerCase().trim()) {
      case "true": case "yes": case "1": return true;
      case "false": case "no": case "0": case null: return false;
      default: return Boolean(string);
  }
}