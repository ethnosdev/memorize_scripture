# Memorize Scripture

A scripture memory app.

Android: https://play.google.com/store/apps/details?id=dev.ethnos.memorize_scripture
Apple: https://apps.apple.com/us/app/memorize-scripture-ethnosdev/id6449814205

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
flutter build apk
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
