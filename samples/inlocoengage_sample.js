function initInLocoEngage() {
    if (! InLocoEngage ) {
        alert( 'InLocoEngage plugin not ready' );
        return;
    }

    InLocoEngage.initWithOptions({
        appId: "<Application_Id>",
        logsEnabled: true
    });
}

function registerDeviceFirebase() {
    if (! InLocoEngage ) {
        alert( 'InLocoEngage plugin not ready' );
        return;
    }

    InLocoEngage.registerDeviceFirebase({
        userId: "<Application_Id>",
        firebaseToken: "<firebaseToken>"
    });
}

function registerDeviceWebhook() {
    if (! InLocoEngage ) {
        alert( 'InLocoEngage plugin not ready' );
        return;
    }

    InLocoEngage.registerDeviceWebhook({
        userId: "<User Id>"
    });
}

function unregisterDevice() {
    if (! InLocoEngage ) {
        alert( 'InLocoEngage plugin not ready' );
        return;
    }

    InLocoEngage.unregisterDevice({
        userId: "<User Id>"
    });
}

