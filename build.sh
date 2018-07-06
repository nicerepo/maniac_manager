#!/bin/bash

flutter build apk
cp build/app/outputs/apk/release/app-armeabi-v7a-release.apk ./

flutter build apk --target-platform=android-arm64
cp build/app/outputs/apk/release/app-arm64-v8a-release.apk ./
