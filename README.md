# Seafile on ARM in 5 minutes

A docker-compose based deployment intended to bring Seafile on any ARMv7/ARM64 board with little effort. A database server and a reverse-proxy with automated SSL/TLS certificates renewal are included.

This environment has been set up using the following images and packages (which you should glance at for further documentation):

- [Base Docker image]( https://github.com/ChatDeBlofeld/seafile-arm-docker-base )
- [linuxserver/mariadb]( https://github.com/linuxserver/docker-mariadb ) as database server
- [linuxserver/swag]( https://github.com/linuxserver/docker-swag ) as reverse-proxy with cerbot support for _Let's Encrypt_.

No guarantees of any kind are provided by using this environment.

## Prerequisites

A functional docker-compose environment, a domain name associated with your server and the TCP ports 80 and 443 correctly forwarded. 

## Initialization

Clone this repository somewhere on your server:

```
$ git clone https://github.com/ChatDeBlofeld/seafile-arm-docker
$ cd seafile-arm-docker
```

### Compose topology

The topology provided should easily fulfill basic use cases. For a finer configuration, see the docs mentioned above.

Some points need attention though when editing the compose file.

#### Environment variables

- Your domain has to be set in the `seafile` and `reverse-proxy` services
- All variables mentioning credentials (email, password) **must** be updated for obvious security reasons. Keep in mind that the MySQL root passwords in the `seafile` and `db` services have to match.

#### Volumes

By default, all data are stored in the compose file directory. Feel free to remap the volumes wherever you need, for example on an external drive. Just be careful that the `seahub-data` volume is also used in the `reverse-proxy` service.

### Reverse-proxy configuration

First generate the certificates by running the service once:

```
$ docker-compose up reverse-proxy
```

If everything went right, stop the container and copy the file `nginx/seafile.conf` to `/path/to/reverse-proxy/volume/nginx/site-confs` and set your domain at the mentioned sections.

You may want to see the following resources for more information about this configuration:

- https://manual.seafile.com/deploy/deploy_with_nginx/
- https://manual.seafile.com/deploy/https_with_nginx

## Run

Simply run:

```
$ docker-compose up -d
```

You should now be able to access `https://your.domain` and log in with your admin account.

>Note: after the first run, all the credentials related environment variables can be removed from the compose file.

## Updating

### Seafile service

Currently there's no breaking changes between the images, so the update is straightforward:

```
$ docker-compose down
$ docker-compose pull seafile
$ docker-compose up -d
```

>Note: rollback will likely fail for major updates

### Thirdpart images

Like the `seafile` service, a pull of the new image should do the job.

### Reverse-proxy configuration

The Nginx configuration may be updated sometimes, then it has to be downloaded from this repository and copied to the right folder again.

For all default files provided by the swag container, see [this updating procedure](https://github.com/linuxserver/docker-swag#updating-configs).

## Troubleshooting

### Seahub failed to start

Set `daemon` to `False` in `gunicorn.conf.py` and restart the Seafile service to grab more information about a failed start.

### Test environment

If you can't run the swag container yet (no port forwarding, no domain or whatever), you may want to use the testing web server. It's a simple Nginx configuration without SSL/TLS, just change the mentioned field in `nginx/seafile.testing.conf` and the seafile configuration files for using the hostname of your server (probably `127.0.0.1`). The variable `ENABLE_TLS` in the compose file has to be set to `0` as well.

Then run:

```
$ docker-compose -f docker-compose.yml -f docker-compose.testing.yml up -d
```
