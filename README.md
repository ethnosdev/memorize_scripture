# Memorize Scripture

A scripture memory app.

Android: https://play.google.com/store/apps/details?id=dev.ethnos.memorize_scripture
Apple: https://apps.apple.com/us/app/memorize-scripture-ethnosdev/id6449814205

## Sharing verses from other apps (Deep Linking)

Other apps (Bible readers, devotionals, study apps, websites) can send Scripture verses directly into Memorize Scripture using the custom URL scheme `memorizescripture://`.

### URL Format

```
memorizescripture://add?prompt=<PROMPT>&text=<TEXT>&version=<VERSION>
```

Alternatively, the root path syntax `memorizescripture://?prompt=<PROMPT>&text=<TEXT>&version=<VERSION>` is also supported.

### Query Parameters

| Parameter | Type | Required | Description | Example |
| :--- | :--- | :--- | :--- | :--- |
| `prompt` | String | Yes* | The verse reference or flashcard prompt. | `Joel 2:1`, `John 3:16` |
| `text` | String | Yes* | The Scripture text to memorize. | `Blow the ram's horn in Zion...` |
| `version` | String | Optional | The Bible translation name or abbreviation. | `BSB`, `ESV`, `KJV`, `NIV` |

*\* At least one of `prompt` or `text` must be provided. All parameter values must be properly URL/percent-encoded.*

### User Experience / Behavior

When Memorize Scripture receives a verse via deep link:

1. **Collection Selection**:
   - If the user has **no collections yet**, a creation dialog appears prefilled with **"Bible Verses"** (editable; pressing <kbd>Enter</kbd> or **OK** creates it immediately).
   - If the user **already has collections**, a bottom sheet appears letting them choose an existing collection or create a new one.
2. **Verse Review & Save**:
   - The app navigates to the **Add verse** screen with the prompt and verse text prefilled from the deep link.
   - The user reviews the verse and taps the checkmark (✓) in the upper-right corner to save it.

### Code Examples

#### Flutter / Dart (`url_launcher`)

```dart
import 'package:url_launcher/url_launcher.dart';

Future<bool> shareToMemorizeScripture({
  required String reference,
  required String text,
  String? version,
}) async {
  final uri = Uri(
    scheme: 'memorizescripture',
    host: 'add',
    queryParameters: {
      'prompt': reference,
      'text': text,
      if (version != null) 'version': version,
    },
  );

  if (await canLaunchUrl(uri)) {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
  return false;
}
```

#### Swift (iOS)

```swift
import UIKit

func shareToMemorizeScripture(reference: String, text: String, version: String? = nil) {
    var components = URLComponents()
    components.scheme = "memorizescripture"
    components.host = "add"
    var queryItems = [
        URLQueryItem(name: "prompt", value: reference),
        URLQueryItem(name: "text", value: text)
    ]
    if let version = version {
        queryItems.append(URLQueryItem(name: "version", value: version))
    }
    components.queryItems = queryItems

    guard let url = components.url else { return }

    if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    } else {
        // Fallback: Open Memorize Scripture on App Store
        if let appStoreUrl = URL(string: "https://apps.apple.com/us/app/memorize-scripture-ethnosdev/id6449814205") {
            UIApplication.shared.open(appStoreUrl)
        }
    }
}
```

> **Note for iOS**: To check `UIApplication.shared.canOpenURL`, add `memorizescripture` to `LSApplicationQueriesSchemes` in your app's `Info.plist`:
> ```xml
> <key>LSApplicationQueriesSchemes</key>
> <array>
>     <string>memorizescripture</string>
> </array>
> ```

#### Kotlin (Android)

```kotlin
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri

fun shareToMemorizeScripture(
    context: Context,
    reference: String,
    text: String,
    version: String? = null
) {
    val builder = Uri.Builder()
        .scheme("memorizescripture")
        .authority("add")
        .appendQueryParameter("prompt", reference)
        .appendQueryParameter("text", text)

    version?.let { builder.appendQueryParameter("version", it) }

    val intent = Intent(Intent.ACTION_VIEW, builder.build()).apply {
        flags = Intent.FLAG_ACTIVITY_NEW_TASK
    }

    try {
        context.startActivity(intent)
    } catch (e: ActivityNotFoundException) {
        // Fallback: Open Memorize Scripture on Google Play
        val playStoreIntent = Intent(
            Intent.ACTION_VIEW,
            Uri.parse("https://play.google.com/store/apps/details?id=dev.ethnos.memorize_scripture")
        ).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        context.startActivity(playStoreIntent)
    }
}
```

#### Web / HTML

```html
<a href="memorizescripture://add?prompt=Joel+2%3A1&text=Blow+the+ram%E2%80%99s+horn+in+Zion...&version=BSB">
  Save to Memorize Scripture
</a>
```

#### Testing with CLI

- **iOS Simulator**:
  ```bash
  xcrun simctl openurl booted "memorizescripture://add?prompt=Joel+2:1&text=Blow+the+ram's+horn+in+Zion&version=BSB"
  ```

- **Android Device / Emulator (ADB)**:
  ```bash
  adb shell am start -a android.intent.action.VIEW -d "memorizescripture://add?prompt=Joel+2:1\&text=Blow+the+ram\'s+horn+in+Zion\&version=BSB"
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
flutter build apk --split-per-abi
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

## For rebuilding android folder

Rename `android` folder to `android_old`. Delete that when finished.

```
flutter create --org dev.ethnos.memorize_scripture .
```

Make sure that nothing is added to the package name (do a project search).

- Overview: https://docs.flutter.dev/deployment/android
- `file_picker`: https://github.com/miguelpruivo/flutter_file_picker/wiki/Setup#android
- `flutter_secure_storage`: https://pub.dev/packages/flutter_secure_storage#configure-android-version
- `url_launcher`: https://pub.dev/packages/url_launcher#android
- Launcher icon: https://stackoverflow.com/a/55054303 (1024 version in supplemental folder) Yellow background: #FFE800 
- App signing: Copy `key.properties` from `android_old` to `android`.
- Configure signing in gradle: https://docs.flutter.dev/deployment/android#configure-signing-in-gradle
- AndroidManifest: Use internet permission.
- AndroidManifest: label is `Memorize`.

## Deploying

Add two A records to the DNS for the app so the subdomains are `memorize` and `api.memorize`.

```
memorize.ethnos.dev
api.memorize.ethnos.dev
```

The API calls will go over the `api.memorize` subdomain.

Secure the server like so:

- https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-22-04
- https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-on-ubuntu-22-04
- https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-22-04
- https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-22-04

Here is the NGINX config:

```
# Memorize Scripture web page server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    server_name memorize.ethnos.dev;

    ssl_certificate /etc/letsencrypt/live/memorize.ethnos.dev/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/memorize.ethnos.dev/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    client_max_body_size 10m;

    root /var/www/memorize.ethnos.dev/html;
    index index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }
}

# Memorize Scripture API server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    server_name api.memorize.ethnos.dev;

    ssl_certificate /etc/letsencrypt/live/memorize.ethnos.dev/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/memorize.ethnos.dev/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location / {
        proxy_pass http://localhost:8090;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    listen [::]:80;

    server_name memorize.ethnos.dev api.memorize.ethnos.dev;
    return 301 https://$server_name$request_uri;
}
```

### Set up PocketBase

Download to ethnosdev home folder with wget

```
wget <Linux download link>
unzip <downloaded file>
```

Put files in pb folder in home folder.

```
mkdir ~/pb
mv pocketbase ~/pb/
```

Make a special secure user:

```
sudo useradd -r -s /bin/false pocketbase
sudo chown -R pocketbase:pocketbase ~/pb
```

Create a system service:

```
sudo nano /etc/systemd/system/pocketbase.service
```

```
[Unit]
Description = pocketbase

[Service]
Type             = simple
User             = pocketbase
Group            = pocketbase
LimitNOFILE      = 4096
Restart          = always
RestartSec       = 5s
WorkingDirectory = /home/ethnosdev/pb
StandardOutput   = append:/home/ethnosdev/pb/errors.log
StandardError    = append:/home/ethnosdev/pb/errors.log
ExecStart        = /home/ethnosdev/pb/pocketbase serve --http="127.0.0.1:8090"

[Install]
WantedBy = multi-user.target
```

Then enable the service:

```
sudo systemctl daemon-reload
sudo systemctl enable pocketbase
sudo systemctl start pocketbase
```

Setup admin account:

```
https://api.memorize.ethnos.dev/_/
```

Use a very strong password.

Add the following schema:

```
backup (collection name)
  user (relation)
  data (plain text)

api rules (all)
  user = @request.auth.id
```

Settings
  Application name: Memorize Scripture
  Application url: http://api.memorize.ethnos.dev
