package com.inlocomedia.android.engagement;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;
import android.support.annotation.DrawableRes;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;

import com.inlocomedia.android.engagement.request.PushProvider;
import com.inlocomedia.android.engagement.user.EngageUser;

public final class InLocoEngagePlugin extends CordovaPlugin {

    private static final String TAG = "InLocoEngagement";
    private static boolean logsEnabled = true;

    private final Command initCommand = new Command("init") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            try {
                // Retrieve options passed during initialization
                String appId = json.optString("appId", null);
                logsEnabled = json.optBoolean("logsEnabled", true);

                // Create options object with the above values
                final InLocoEngagementOptions options = InLocoEngagementOptions.getInstance(context);
                options.setApplicationId(appId);
                options.setLogEnabled(logsEnabled);

                if (json.has("developmentDevices")) {
                    options.setDevelopmentDevices(getDevelopmentDevices(json.getJSONArray("developmentDevices")));
                }

                if (json.has("locationTrackingEnabled")) {
                    options.setLocationTrackingEnabled(json.getBoolean("locationTrackingEnabled"));
                }

                if (json.has("screenTrackingEnabled")) {
                    options.setScreenTrackingEnabled(json.getBoolean("screenTrackingEnabled"));
                }

                if (json.has("requiresUserPrivacyConsent")) {
                    options.setRequiresUserPrivacyConsent(json.getBoolean("requiresUserPrivacyConsent"));
                }

                // Initialize the SDK
                InLocoEngagement.init(context, options);
            } catch (Exception e) {
                if (logsEnabled) {
                    Log.e(TAG, "Failure during SDK initialization: '" + e.getMessage() + "'.");
                }
            }
        }
    };

    private final Command requestPermissions = new Command("requestPermissions") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            boolean askIfDenied = json.optBoolean("askIfDenied", false);

            InLocoEngagement.requestPermissions(context, new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, askIfDenied, null);
        }
    };

    private final Command isPushNotificationsEnabled = new Command("isPushNotificationsEnabled") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            JSONObject data = new JSONObject();

            try {
                data.put("isEnabled", InLocoEngagement.isPushNotificationsEnabled(context));

                callback.onSuccess(data);
            } catch (JSONException e) {
                callback.onFailure(e);
            }
        }
    };

    private final Command setPushNotificationsEnabled = new Command("setPushNotificationsEnabled") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            try {
                boolean enabled = json.optBoolean("enabled");

                InLocoEngagement.setPushNotificationsEnabled(context, enabled);
            } catch (Exception e) {
                Log.e(TAG, "Faled to modify push notifications setting: '" + e.getMessage() + "'.");
            }
        }
    };

    private final Command setPushProvider = new Command("setPushProvider") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            try {
                String name = json.optString("name");
                String token = json.optString("token");

                PushProvider pushProvider = new PushProvider.Builder()
                                                            .setName(name)
                                                            .setToken(token)
                                                            .build();

                InLocoEngagement.setPushProvider(context, pushProvider);
            } catch (Exception e) {
                Log.e(TAG, "Faled to set push provider: '" + e.getMessage() + "'.");
            }
        }
    };

    private final Command setUser = new Command("setUser") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            String userId = json.optString("userId");
            EngageUser user = new EngageUser(userId);

            InLocoEngagement.setUser(context, user);
        }
    };

    private final Command clearUser = new Command("clearUser") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            InLocoEngagement.clearUser(context);
        }
    };

    private final Command presentNotification = new Command("presentNotification") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            String dataAsString = json.optString("data", "");
            HashMap<String, String> data = toHashMap(dataAsString);

            String resourceName = json.optString("notificationIconName", "");
            @DrawableRes int resourceId = getDrawableId(context, resourceName);

            if (data.isEmpty()) {
                if (logsEnabled) {
                    Log.w(TAG, "Failed to present notification. Invalid content: '" + dataAsString + "'");
                }

                return;
            }

            final PushMessage pushContent = InLocoEngagement.decodeReceivedMessage(context, data);

            if (pushContent == null) {
                if (logsEnabled) {
                    Log.w(TAG, "Failed to present notification. Invalid content: '" + data + "'");
                }
                return;
            }

            InLocoEngagement.presentNotification(context,
                                                 pushContent,
                                                 resourceId > 0 ? resourceId : 0,
                                                 json.optInt("notificationId", getRandomNotificationId()),
                                                 json.optString("notificationChannelId", null));
        }
    };

    private final Command trackEvent = new Command("trackEvent") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            String name = json.optString("name");
            HashMap<String, String> properties = toHashMap(json.optJSONObject("properties"));

            InLocoEngagement.trackEvent(context, name, properties);
        }
    };

    private final Command hasGivenPrivacyConsent = new Command("hasGivenPrivacyConsent") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            JSONObject data = new JSONObject();

            try {
                data.put("hasGiven", InLocoEngagement.hasGivenPrivacyConsent(context));

                callback.onSuccess(data);
            } catch (JSONException e) {
                callback.onFailure(e);
            }
        }
    };

    private final Command givePrivacyConsent = new Command("givePrivacyConsent") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            boolean consent = json.optBoolean("consent");

            InLocoEngagement.givePrivacyConsent(context, consent);
        }
    };

    private final Command isWaitingUserPrivacyConsent = new Command("isWaitingUserPrivacyConsent") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            JSONObject data = new JSONObject();

            try {
                data.put("isWaiting", InLocoEngagement.isWaitingUserPrivacyConsent(context));

                callback.onSuccess(data);
            } catch (JSONException e) {
                callback.onFailure(e);
            }
        }
    };

    private final List<Command> commands = new ArrayList<Command>(Arrays.asList(initCommand,
                                                                                requestPermissions,
                                                                                isPushNotificationsEnabled,
                                                                                setPushNotificationsEnabled,
                                                                                setPushProvider,
                                                                                setUser,
                                                                                clearUser,
                                                                                presentNotification,
                                                                                trackEvent,
                                                                                hasGivenPrivacyConsent,
                                                                                givePrivacyConsent,
                                                                                isWaitingUserPrivacyConsent));

    @Override
    public boolean execute(final String action, final JSONArray inputs, final CallbackContext callbackContext) throws JSONException {
        try {
            final EngageCallback callback = new EngageCallback() {
                @Override
                public void onSuccess(final JSONObject data) {
                    PluginResult result = new PluginResult(PluginResult.Status.OK, data);
                    callbackContext.sendPluginResult(result);
                }

                @Override
                public void onFailure(final Exception e) {
                    PluginResult result = new PluginResult(PluginResult.Status.ERROR, e.getMessage());
                    callbackContext.sendPluginResult(result);
                }
            };

            boolean commandExecuted = false;
            for (final Command command : commands) {
                if (command.getId().equals(action)) {
                    cordova.getActivity().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            final JSONObject options = inputs.optJSONObject(0);

                            command.execute(getActivity(), options, callback);
                        }
                    });

                    commandExecuted = true;
                    break;
                }
            }

            if (!commandExecuted) {
                if (logsEnabled) {
                    Log.w(TAG, String.format("Invalid action received: %s", action));
                }

                PluginResult result = new PluginResult(PluginResult.Status.INVALID_ACTION);
                callbackContext.sendPluginResult(result);
            }
        } catch (Throwable t) {
            if (logsEnabled) {
                Log.e(TAG, "Action execution has failed: " + action, t);
            }
        }

        return true;
    }

    private String[] getDevelopmentDevices(JSONArray array) {
        String[] developmentDevices = null;
        
        if (array != null) {
            developmentDevices = new String[array.length()];
    
            for (int i = 0; i < developmentDevices.length; i++) {
                developmentDevices[i] = array.optString(i);
            }
        }

        return developmentDevices;
    }

    private HashMap<String, String> toHashMap(final String jsonString) {
        HashMap<String, String> hashMap = new HashMap<String, String>();

        try {
            hashMap = toHashMap(new JSONObject(jsonString));
        } catch (JSONException e) {
            if (logsEnabled) {
                Log.w(TAG, "Failed to parse data", e);
            }
        }

        return hashMap;
    }

    private HashMap<String, String> toHashMap(final JSONObject jsonObject) {
        HashMap<String, String> hashMap = new HashMap<String, String>();

        try {
            for (Iterator<String> it = jsonObject.keys(); it.hasNext(); ) {
                String key = it.next();
                hashMap.put(key, jsonObject.getString(key));
            }
        } catch (JSONException e) {
            if (logsEnabled) {
                Log.w(TAG, "Failed to parse data", e);
            }
        }

        return hashMap;
    }

    private int getDrawableId(Context context, String icon) {
        Resources resources = context.getResources();
        int iconId = resources.getIdentifier(icon, "drawable", context.getPackageName());
        
        if (iconId == 0) {
            iconId = resources.getIdentifier(icon, "mipmap", context.getPackageName());
        }

        return iconId;
    }

    private static int getRandomNotificationId() {
        return Integer.parseInt(new SimpleDateFormat("ddHHmmss", Locale.US).format(new Date()));
    }

    public Activity getActivity() {
        return cordova != null ? cordova.getActivity() : null;
    }

    abstract class Command {
        private String id;

        protected Command(final String id) {
            this.id = id;
        }

        abstract void execute(final Activity context, @Nullable final JSONObject json, @NonNull final EngageCallback callback);

        protected String getId() {
            return id;
        }
    }

    interface EngageCallback {

        void onSuccess(@NonNull final JSONObject data);

        void onFailure(@NonNull final Exception e);
    }
}