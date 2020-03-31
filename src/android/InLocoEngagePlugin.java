package com.inlocomedia.android.engagement;

import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;
import android.location.Address;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.Log;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Set;

import com.inlocomedia.android.common.InLoco;
import com.inlocomedia.android.common.InLocoEvents;
import com.inlocomedia.android.common.listener.InLocoListener;
import com.inlocomedia.android.common.listener.Result;
import com.inlocomedia.android.location.CheckIn;
import com.inlocomedia.android.location.InLocoVisits;

public final class InLocoEngagePlugin extends CordovaPlugin {

    private static final String TAG = "InLocoEngage";
    private static boolean logsEnabled = true;

    // Custom Audience
    private final Command setUser = new Command("setUser") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            String userId = json.optString("user_id");

            InLoco.setUserId(context, userId);
        }
    };

    private final Command clearUser = new Command("clearUser") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            InLoco.clearUserId(context);
        }
    };

    // Custom Event
    private final Command trackEvent = new Command("trackEvent") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            String name = json.optString("name");
            HashMap<String, String> properties = toHashMap(json.optJSONObject("properties"));

            InLocoEvents.trackEvent(context, name, properties);
        }
    };

    // Check In
    private final Command registerCheckIn = new Command("registerCheckIn") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            String placeName = json.optString("place_name");
            String placeId = json.optString("place_id");
            HashMap<String, String> extras = toHashMap(json.optJSONObject("extras"));
            CheckIn checkIn = new CheckIn.Builder()
                    .placeName(placeName)
                    .placeId(placeId)
                    .extras(extras)
                    .build();

            InLocoVisits.registerCheckIn(context, checkIn);
            Log.i(TAG, "CHECK IN REGISTRED");
        }
    };

    // Privacy Consent
    private final Command givePrivacyConsent = new Command("givePrivacyConsent") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            if (json.has("consent")) {
                boolean consent = json.optBoolean("consent");
                InLoco.givePrivacyConsent(context, consent);
            } else {
                JSONArray arrayJson = json.optJSONArray("consent_types");
                Set<String> consentTypes =  new HashSet<>();
                for(int i = 0; i < arrayJson.length(); i++)
                    consentTypes.add(arrayJson.optString(i));

                InLoco.givePrivacyConsent(context, consentTypes);
            }
        }
    };

    private final Command checkPrivacyConsentMissing = new Command("checkPrivacyConsentMissing") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            InLoco.checkPrivacyConsentMissing(context, new InLocoListener<Boolean>() {
                @Override
                public void onResult(final Result<Boolean> result) {
                    boolean isConsentMissing = result.getResult();
                    try {
                        JSONObject data = new JSONObject();
                        data.put("is_consent_missing", isConsentMissing);
                        callback.onSuccess(data);
                    } catch (JSONException e) {
                        callback.onFailure(e);
                    }
                }
            });
        }
    };

    // Address Validation
    private final Command setAddress = new Command("setAddress") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            String language = json.optString("language");
            String country = json.optString("country");
            Locale locale = new Locale(language, country);

            Address address = new Address(locale);
            address.setCountryName(json.optString("country_name"));
            address.setCountryCode(json.optString("country_code"));
            address.setAdminArea(json.optString("admin_area"));
            address.setSubAdminArea(json.optString("sub_admin_area"));
            address.setLocality(json.optString("locality"));
            address.setSubLocality(json.optString("sub_locality"));
            address.setThoroughfare(json.optString("thoroughfare"));
            address.setSubThoroughfare(json.optString("sub_thoroughfare"));
            address.setPostalCode(json.optString("postal_code"));
            address.setLatitude(json.optDouble("latitude"));
            address.setLongitude(json.optDouble("longitude"));

            InLocoAddressValidation.setAddress(context, address);

            Log.i(TAG, "ADDRESS REGISTRED");
        }
    };

    private final Command clearAddress = new Command("clearAddress") {
        @Override
        public void execute(final Activity context, final JSONObject json, final EngageCallback callback) {
            InLocoAddressValidation.clearAddress(context);
        }
    };

    private final List<Command> commands = new ArrayList<Command>(Arrays.asList(setUser,
                                                                                clearUser,
                                                                                trackEvent,
                                                                                registerCheckIn,
                                                                                givePrivacyConsent,
                                                                                checkPrivacyConsentMissing,
                                                                                setAddress,
                                                                                clearAddress));

    @Override
    public boolean execute(final String action, final JSONArray inputs, final CallbackContext callbackContext) {
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