# Production Setup

We currently recommend and support production installation via docker-compose. This document assumes you have system running debian 10 (buster).

## Install nginx
Follow [https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-debian-10](https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-debian-10)

## SSL
Follow [https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-debian-10](https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-debian-10)

## Diaspora setup via docker-compose
```
cd
git clone https://github.com/c4social/diaspora.git
cd diaspora
cp config/diaspora.toml.example config/diaspora.toml
```
### Edit config/diaspora.toml
1. Uncomment `url=...`. Use `localhost` for testing, actual url for production
1. Uncomment `certificate_authorities=...`
1. Uncomment `require_ssl=false` and set to `true`
1. Uncomment `listen = “0.0.0.0:3000”`
1. Uncomement and set `redis = “redis://redis”`
1. Uncomment and set `autofollow_on_join = false` to turn off phone home
or leave it at true and set autofollow_on_join_user to your user of choice later (requires restart).

### Configure email needed

Mailgun is used in this example.

```
[configuration.mail]
enable  = true
sender_address = “Example <diaspora@example.com>”
method = “smtp”

[configuration.mail.smtp]
host = “smtp.mailgun.org”
port = 587
authentication = “plain”
username = “postmaster@example.com”
password = “....”  # reset pw at mailgun link if you need to
starttls_auto = true
```

### Connect database
```
cp config/database.yml.example config/database.yml
vi config/database.yml 
# change host to `postgres`
# change user to `diaspora`
# change password to `diaspora`
```

### Create and initialize database
```
docker-compose up -d postgres
docker-compose run --rm unicorn bin/rake db:create db:migrate
```

### Create data storage location 
sudo chown -R 942:942 data
mkdir tmp
sudo chown -R 942:942 tmp

### Start diaspora
docker-compose up -d


### Connect Reverse Proxy
Nginx config should look like this:
```
server {

    root /home/<your user>/diaspora/data/;

    server_name example.com;

    client_max_body_size 5M; 
    client_body_buffer_size 256K;

    try_files $uri @diaspora;

    location /assets/ {
        expires max;
        add_header Cache-Control public;
    } 

    location @diaspora {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_pass http://localhost:3000;
    } 

    listen [::]:443 ssl ipv6only=on; # managed by Certbot
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}
server {

    if ($host = example.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

    listen 80;
    listen [::]:80;

    server_name example.com;
    return 404; # managed by Certbot

}
```

## Maintenance

### Restart one or more services
`docker-compose restart sidekiq`

### View logs of a service
`docker logs diaspora_sidekiq`

### Get shell to run bundle-based commands
```
docker ps   # find the id of diaspora_sidekiq or unicorn 
docker exec -it <container_id> bash
```

### Make your account an admin (requires shell)
```
bin/bundle exec rails console
Role.add_admin User.where(username: "weex").first.person
```

### Test email (requires shell)
```
bin/bundle exec rails runner 'Notifier.admin("test message", User.where(username: "your_username")).each(&:deliver_now)'
```
