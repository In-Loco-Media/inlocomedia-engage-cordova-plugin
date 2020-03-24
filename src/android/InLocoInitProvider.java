package com.inlocomedia.android.engagement;

import android.content.ContentProvider;
import android.content.ContentValues;
import android.database.Cursor;
import android.net.Uri;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.Log;

public class InLocoInitProvider extends ContentProvider {
  
    @Override
    public boolean onCreate() {
      Log.d("InLocoInitProvider", "onCreate()");
        // Set initialization options
        InLocoEngagementOptions options = InLocoEngagementOptions.getInstance(getContext());

        // The App ID you obtained in the dashboard
        options.setApplicationId("88b25236-e53c-44ce-992d-32b15842593d");

        // Verbose mode; enables SDK logging, defaults to true.
        // Remember to set to false in production builds.
        options.setLogEnabled(true);

        //Initialize the SDK
        InLocoEngagement.init(getContext(), options);

        return false;
    }

    @Nullable
    @Override
    public Cursor query(@NonNull final Uri uri, @Nullable final String[] projection, @Nullable final String selection,
                        @Nullable final String[] selectionArgs,
                        @Nullable final String sortOrder) {
        return null;
    }

    @Nullable
    @Override
    public String getType(@NonNull final Uri uri) {
        return null;
    }

    @Nullable
    @Override
    public Uri insert(@NonNull final Uri uri, @Nullable final ContentValues values) {
        return null;
    }

    @Override
    public int delete(@NonNull final Uri uri, @Nullable final String selection, @Nullable final String[] selectionArgs) {
        return 0;
    }

    @Override
    public int update(@NonNull final Uri uri, @Nullable final ContentValues values, @Nullable final String selection,
                      @Nullable final String[] selectionArgs) {
        return 0;
    }
}
