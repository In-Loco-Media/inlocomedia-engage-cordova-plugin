var argscheck = require('cordova/argscheck');
var exec = require('cordova/exec');
var cordova = require("cordova");
var inLocoEngageExport = {};

inLocoEngageExport.OPTIONS = {
  // setUser options
  USER_ID: 'user_id',

  // trackEvent options
  EVENT_NAME: 'name',
  EVENT_PROPERTIES: 'properties',

  // checkIn options
  PLACE_NAME: 'place_name',
  PLACE_ID: 'place_id',
  EXTRAS: 'extras',

  // addressValidation options
  LANGUAGE: 'language',
  COUNTRY: 'country',
  COUNTRY_NAME: 'country_name',
  COUNTRY_CODE: 'country_code',
  ADMIN_AREA: 'admin_area',
  SUB_ADMIN_AREA: 'sub_admin_area',
  LOCALITY: 'locality',
  SUB_LOCALITY: 'sub_locality',
  THOROUGHFARE: 'thoroughfare',
  SUB_THOROUGHFARE: 'sub_thoroughfare',
  POSTAL_CODE: 'postal_code',
  LATITUDE: 'latitude',
  LONGITUDE: 'longitude',

  // givePrivacyConsent options
  CONSENT: 'consent',
  CONSENT_TYPES: 'consent_types',

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
  TRACK_EVENT: 'trackEvent',
  REGISTER_CHECK_IN: 'registerCheckIn',
  SET_ADDRESS: 'setAddress',
  CLEAR_ADDRESS: 'clearAddress',
  GIVE_PRIVACY_CONSENT: 'givePrivacyConsent',
  CHECK_PRIVACY_CONSENT_MISSING: 'checkPrivacyConsentMissing'
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

inLocoEngageExport.registerCheckIn = function(args, successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.REGISTER_CHECK_IN, [args]);
};

inLocoEngageExport.setAddress = function(args, successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.SET_ADDRESS, [args]);
};

inLocoEngageExport.clearAddress = function(successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.CLEAR_ADDRESS, []);
}

inLocoEngageExport.givePrivacyConsent = function(args, successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.GIVE_PRIVACY_CONSENT, [args]);
};

inLocoEngageExport.checkPrivacyConsentMissing = function(successCallback, failureCallback) {
  cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.CHECK_PRIVACY_CONSENT_MISSING, []);
};

module.exports = inLocoEngageExport;