package com.inlocomedia.android.engagement;

import android.Manifest;
import android.app.Activity;
import android.util.Log;

import com.inlocomedia.android.engagement.request.WebhookDeviceRegisterRequest;
import com.inlocomedia.android.engagement.request.UnregisterDeviceRequest;
import com.inlocomedia.android.engagement.request.FirebaseDeviceRegisterRequest;
import com.inlocomedia.android.engagement.request.RegisterDeviceRequest;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public final class InLocoEngagePlugin extends CordovaPlugin {
    private static final String TAG = "InLocoEngagement";
    private static boolean sLogEnabled = true;

    private final Command initCommand = new Command("init") {

        @Override
        public void execute(final Activity context, final JSONObject json) {

            String appId = json.optString("appId", null);
            sLogEnabled = json.optBoolean("logsEnabled", true);

            if (sLogEnabled) {

                if (appId == null || appId.isEmpty()) {
                    Log.e(TAG, "Missing application id. Please verify if you have set it correctly");
                }
            }

            final InLocoEngagementOptions options = InLocoEngagementOptions.getInstance(context);
            options.setApplicationId(appId);
            options.setLogEnabled(sLogEnabled);

            InLocoEngagement.init(context, options);
        }
    };

    private final Command registerDeviceFirebase = new Command("registerDeviceFirebase") {
        @Override
        void execute(final Activity context, final JSONObject json) {

            final RegisterDeviceRequest request = new FirebaseDeviceRegisterRequest.Builder()
                    .setUserId(json.optString("userId"))
                    .setFirebaseToken(json.optString("firebaseToken"))
                    .build();

            InLocoEngagement.registerDeviceForPushServices(context, request);
        }
    };

    private final Command registerDeviceWebhook = new Command("registerDeviceWebhook") {
        @Override
        void execute(final Activity context, final JSONObject json) {
            final RegisterDeviceRequest request = new WebhookDeviceRegisterRequest.Builder()
                    .setUserId(json.optString("userId"))
                    .build();

            InLocoEngagement.registerDeviceForPushServices(context, request);
        }
    };

    private final Command unregisterDevice = new Command("unregisterDevice") {
        @Override
        void execute(final Activity context, final JSONObject json) {
            final UnregisterDeviceRequest request = new UnregisterDeviceRequest.Builder()
                    .setUserId(json.optString("userId"))
                    .build();

            InLocoEngagement.unregisterDeviceForPushServices(context, request);
        }
    };

    private final Command requestPermissions = new Command("requestPermissions") {
        @Override
        void execute(final Activity context, final JSONObject json) {
            boolean askIfDenied = json.optBoolean("askIfDenied", false);

            InLocoEngagement.requestPermissions(context, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, askIfDenied, null);
        }
    };

    private final List<Command> commands = new ArrayList<Command>(Arrays.asList(initCommand,
                                                                                registerDeviceFirebase,
                                                                                registerDeviceWebhook,
                                                                                unregisterDevice,
                                                                                requestPermissions));

    @Override
    public boolean execute(String action, JSONArray inputs, CallbackContext callbackContext) throws JSONException {

        try {

            PluginResult result = null;

            final JSONObject options = inputs.optJSONObject(0);
            if (options != null) {
                for (final Command command : commands) {
                    if (command.getId().equals(action)) {
                        cordova.getActivity().runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                command.execute(getActivity(), options);
                            }
                        });
                        result = new PluginResult(PluginResult.Status.OK);
                        break;
                    }
                }
            }

            if (result == null) {
                if (sLogEnabled) {
                    Log.w(TAG, String.format("Invalid action received: %s", action));
                }
                result = new PluginResult(PluginResult.Status.INVALID_ACTION);
            }

            callbackContext.sendPluginResult(result);

        } catch (Throwable t) {
            if (sLogEnabled) {
                Log.e(TAG, "Action execution has failed: " + action, t);
            }
        }

        return true;
    }

    public Activity getActivity() {
        return cordova != null ? cordova.getActivity() : null;
    }

    abstract class Command {
        private String id;

        protected Command(final String id) {
            this.id = id;
        }

        abstract void execute(final Activity context, JSONObject json);

        protected String getId() {
            return id;
        }
    }
}

