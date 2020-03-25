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

import com.inlocomedia.android.common.InLoco;
import com.inlocomedia.android.common.InLocoEvents;

public final class InLocoEngagePlugin extends CordovaPlugin {

    private static final String TAG = "InLocoEngagement";
    private static boolean logsEnabled = true;

    private final Command setUser = new Command("setUser") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            String userId = json.optString("userId");
            InLoco.setUserId(context, userId);
        }
    };

    private final Command clearUser = new Command("clearUser") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            InLoco.clearUserId(context);
        }
    };

    private final Command trackEvent = new Command("trackEvent") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            String name = json.optString("name");
            HashMap<String, String> properties = toHashMap(json.optJSONObject("properties"));

            InLocoEvents.trackEvent(context, name, properties);
        }
    };

    private final Command givePrivacyConsent = new Command("givePrivacyConsent") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            boolean consent = json.optBoolean("consent");
            InLoco.givePrivacyConsent(context, consent);
        }
    };

    private final List<Command> commands = new ArrayList<Command>(Arrays.asList(setUser,
                                                                                clearUser,
                                                                                trackEvent,
                                                                                givePrivacyConsent));

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