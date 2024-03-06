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

old one:

```
server {

    root /var/www/memorize.ethnos.dev/html;
    index index.html index.htm index.nginx-debian.html;

    server_name memorize.ethnos.dev api.memorize.ethnos.dev;

    location / {
        try_files $uri $uri/ =404;
    }

    listen [::]:443 ssl ipv6only=on; # managed by Certbot
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/memorize.ethnos.dev/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/memorize.ethnos.dev/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot


}
server {
    if ($host = api.memorize.ethnos.dev) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    if ($host = memorize.ethnos.dev) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen 80;
    listen [::]:80;

    server_name memorize.ethnos.dev api.memorize.ethnos.dev;
    return 404; # managed by Certbot
}
```