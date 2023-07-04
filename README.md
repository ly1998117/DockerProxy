# Docker Proxy
## Description
This is a HTTPS certification and proxy service for docker containers. It allows you to run multiple containers without complex HTTPS signing operations. 
The proxy will sign automatically and forward the HTTPS request to the docker container without port exposure. 

The cript `install.sh` will install several systemd services.
+ nginx-proxy.service: the proxy
+ traefik.service: the traefik service to sign the https certificate
+ container-socket-proxy.service: the service to forward the https request to the container
+ traefik-certs-dumper.service: the service to dump the https certificate


## Service Install
This cript will install several systemd services. And move the matrix directory (configs) to `/matrix`.
```bash
./install.sh
```

## Usage
+ start your container with the network `matrix`
+ get your http field like `http://your.field.com`
+ add the label to `/matrix/nginx-proxy/labels`
```bash
traefik.http.routers.matrix-nginx-proxy-your-client.rule=Host(`your.field.com`)
traefik.http.routers.matrix-nginx-proxy-your-client.service=matrix-nginx-proxy-web
traefik.http.routers.matrix-nginx-proxy-your-client.tls=true
traefik.http.routers.matrix-nginx-proxy-your-client.tls.certResolver=default
traefik.http.routers.matrix-nginx-proxy-your-client.entrypoints=web-secure
```

+ add config to `/matrix/nginx-proxy/conf.d`
```bash
server {
        listen 8080;
        listen [::]:8080;

        server_name your.field.com;
	gzip on;
        gzip_types text/plain application/json;

                add_header Permissions-Policy interest-cohort=() always;

                add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

        add_header X-XSS-Protection "1; mode=block";


        location / {
                        resolver 127.0.0.11 valid=5s;
                        set $backend "your container name: your service port(service port in container, no need to expose port)";
                        proxy_pass http://$backend;

		proxy_set_header Host $host;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto $http_x_forwarded_proto;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection $connection_upgrade;
                client_body_buffer_size 25M;
                client_max_body_size 150M;
                proxy_max_temp_file_size 0;
        }
}
```
