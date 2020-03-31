#!/usr/bin/env node
'use strict';

var fs = require('fs');
var path = require('path');

fs.ensureDirSync = function(dir) {
    if (!fs.existsSync(dir)) {
        dir.split(path.sep).reduce(function(currentPath, folder) {
            currentPath += folder + path.sep;
            if (!fs.existsSync(currentPath)) {
                fs.mkdirSync(currentPath);
            }
            return currentPath;
        }, '');
    }
};

var config = fs.readFileSync('config.xml').toString();
var name = getValue(config, 'name');

var IOS_DIR = 'platforms/ios';

var FILE = {
    FCM: {
        dest: [
            IOS_DIR + '/' + name + '/Resources/GoogleService-Info.plist',
            IOS_DIR + '/' + name + '/Resources/Resources/GoogleService-Info.plist'
        ],
        src: [
            'GoogleService-Info.plist',
            IOS_DIR + '/www/GoogleService-Info.plist',
            'www/GoogleService-Info.plist'
        ]
    },
    INLOCO: {
        dest: [
            IOS_DIR + '/' + name + '/Resources/InLocoOptions.plist',
            IOS_DIR + '/' + name + '/Resources/Resources/InLocoOptions.plist'
        ],
        src: [
            'InLocoOptions.plist',
            IOS_DIR + '/www/InLocoOptions.plist',
            'www/InLocoOptions.plist'
        ]
    }
};

// Copy key files to their platform specific folders
if (directoryExists(IOS_DIR)) {
    copyKey(FILE.FCM);
    copyKey(FILE.INLOCO);
}

function copyKey(platform, callback) {
    for (var i = 0; i < platform.src.length; i++) {
        var file = platform.src[i];
        if (fileExists(file)) {
            try {
                var contents = fs.readFileSync(file).toString();

                try {
                    platform.dest.forEach(function(destinationPath) {
                        var folder = destinationPath.substring(0, destinationPath.lastIndexOf('/'));
                        fs.ensureDirSync(folder);
                        fs.writeFileSync(destinationPath, contents);
                    });
                } catch (e) {
                    // skip
                }

                callback && callback(contents);
            } catch (err) {
                console.log(err);
            }

            break;
        }
    }
}

function getValue(config, name) {
    var value = config.match(new RegExp('<' + name + '>(.*?)</' + name + '>', 'i'));
    if (value && value[1]) {
        return value[1];
    } else {
        return null;
    }
}

function fileExists(path) {
    try {
        return fs.statSync(path).isFile();
    } catch (e) {
        return false;
    }
}

function directoryExists(path) {
    try {
        return fs.statSync(path).isDirectory();
    } catch (e) {
        return false;
    }
}