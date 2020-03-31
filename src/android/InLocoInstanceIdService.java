package com.inlocomedia.android.engagement;

import com.google.firebase.iid.FirebaseInstanceId;
import com.inlocomedia.android.engagement.request.FirebasePushProvider;
import com.inlocomedia.android.engagement.request.PushProvider;
import com.adobe.phonegap.push.PushInstanceIDListenerService;

public class InLocoInstanceIdService extends PushInstanceIDListenerService {

    @Override
    public void onTokenRefresh() {
        String firebaseToken = FirebaseInstanceId.getInstance().getToken();

        if (firebaseToken != null && !firebaseToken.isEmpty()) {
            final PushProvider pushProvider = new FirebasePushProvider.Builder()
                    .setFirebaseToken(firebaseToken)
                    .build();
            InLocoPush.setPushProvider(this, pushProvider);
        }

        super.onTokenRefresh();
    }
}