# Memorize Scripture

A scripture memory app.

Android: https://play.google.com/store/apps/details?id=dev.ethnos.memorize_scripture
Apple: https://apps.apple.com/us/app/memorize-scripture-ethnosdev/id6449814205

## For rebuilding tests

```
dart run build_runner build --delete-conflicting-outputs
```

## For publishing iOS

Screen sizes:

- https://stackoverflow.com/a/33173632

- iPhone 14 Pro Max
- iPhone 8 Plus
- iPad Pro (12.9-inch) 

Publishing

- https://docs.flutter.dev/deployment/ios
- Update version and build number in Xcode

```
flutter build ipa
```

- Transporter

## For publishing Android

```
flutter build appbundle
```

## For rebuilding macos folder

Need the following in `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:

```
<key>com.apple.security.network.client</key>
<true/>
<key>keychain-access-groups</key>
<array/>
```

The first is to connect to the internet. The second is to use flutter_secure_storage.