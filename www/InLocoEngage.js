var argscheck = require('cordova/argscheck');
var exec = require('cordova/exec');
var inLocoEngageExport = {};

inLocoEngageExport.OPTIONS = {
  APP_ID: 'appId',
  LOGS_ENABLED: 'logsEnabled'
};

inLocoEngageExport.OPTIONS = {
    APP_ID: 'appId',
    LOGS_ENABLED: 'logsEnabled',
    USER_ID: 'userId',
    FIREBASE_TOKEN: 'firebaseToken',
    ASK_IF_DENIED: 'askIfDenied'
};

inLocoEngageExport.ACTIONS = {
  INITIALIZATION: 'init',
  REGISTER_DEVICE_FIREBASE: "registerDeviceFirebase",
  REGISTER_DEVICE_WEBHOOK: "registerDeviceWebhook",
  UNREGISTER_DEVICE: "unregisterDevice",
  REQUEST_PERMISSIONS: "requestPermissions"
};

inLocoEngageExport.initWithOptions = function(args, successCallback, failureCallback) {
	cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.INITIALIZATION, [args]);
};

inLocoEngageExport.registerDeviceFirebase = function(args, successCallback, failureCallback) {
    cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.REGISTER_DEVICE_FIREBASE, [args]);
};

inLocoEngageExport.registerDeviceWebhook = function(args, successCallback, failureCallback) {
    cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.REGISTER_DEVICE_WEBHOOK, [args]);
};

inLocoEngageExport.unregisterDevice = function(args, successCallback, failureCallback) {
    cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.UNREGISTER_DEVICE, [args]);
};

inLocoEngageExport.requestPermissions = function(args, successCallback, failureCallback) {
    cordova.exec(successCallback, failureCallback, 'InLocoEngage', inLocoEngageExport.ACTIONS.REQUEST_PERMISSIONS, [args]);
};

module.exports = inLocoEngageExport;