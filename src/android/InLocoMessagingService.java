package com.inlocomedia.android.engagement;

import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;
import com.inlocomedia.android.engagement.InLocoPush;
import com.inlocomedia.android.engagement.PushMessage;
import com.adobe.phonegap.push.FCMService;

import java.util.Map;

public class InLocoMessagingService extends FCMService {

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        final Map<String, String> data = remoteMessage.getData();

        if (data != null) {
            final PushMessage pushContent = InLocoPush.decodeReceivedMessage(this, data);
            if (pushContent != null) {
                InLocoPush.presentNotification(
                        this,
                        pushContent,
                        this.getApplicationInfo().icon,
                        1111111
                );
            } else {
                super.onMessageReceived(remoteMessage);
            }
        }
    }
}
