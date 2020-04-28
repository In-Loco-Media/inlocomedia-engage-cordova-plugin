package com.inlocomedia.android.engagement;

import com.google.firebase.messaging.RemoteMessage;
import com.adobe.phonegap.push.FCMService;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
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
                        getRandomNotificationId()
                );
            } else {
                super.onMessageReceived(remoteMessage);
            }
        }
    }

    private static int getRandomNotificationId() {
        return Integer.parseInt(new SimpleDateFormat("ddHHmmss", Locale.US).format(new Date()));
    }
}
