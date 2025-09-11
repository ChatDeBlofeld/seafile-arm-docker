# Seafile on ARM in 5 minutes

A docker-compose based deployment intended to bring Seafile on any ARMv7/ARM64 board with little effort. A DBMS (MariaDB or MySQL) and a reverse-proxy with automated TLS certificates renewal are included.

Don't want automated TLS certs? See the [*No SWAG* section](#optional-no-swag) below.

This environment has been set up using the following images and packages (which you should glance at for further documentation):

- [Base Docker image](https://github.com/ChatDeBlofeld/seafile-arm-docker-base)
- [linuxserver/mariadb](https://github.com/linuxserver/docker-mariadb) as database server
- [linuxserver/swag](https://github.com/linuxserver/docker-swag) as reverse-proxy with cerbot support for _Let's Encrypt_.

Some other useful docs:

- [Seafile manual](https://manual.seafile.com/)
- [Compose file reference](https://docs.docker.com/compose/compose-file/compose-file-v3/)
- [Ngninx docs](https://nginx.org/en/docs/)

No guarantees of any kind are provided by using this environment.

## Prerequisites

A working docker-compose environment, a domain name associated with your server and the TCP ports 80 and 443 correctly forwarded. 

## Initialization

Clone this repository somewhere on your server:

```
$ git clone https://github.com/ChatDeBlofeld/seafile-arm-docker
$ cd seafile-arm-docker
```

### Compose topology

The topology provided should easily fulfill basic use cases. For a finer configuration, see the docs mentioned above.

#### Configuration

Copy the `.env.example` file:

```
$ cp .env.example .env
```

Then edit the dotenv with your favorite editor and take care at least of the following topics:

- Select your database server between MariaDB and MySQL by commenting/uncommenting the appropriate line.
- Set your domain at the `SEAFILE_HOST` variable.
- All variables mentioning credentials (email, passwords) **must** be updated for obvious security reasons.
- All volumes are mapped to the current directory by default, feel free to remap them to the most appropriate place for you, for example an external drive.

### Reverse-proxy

#### SWAG

First generate the certificates by running the service once:

```
$ docker compose up reverse-proxy
```

If everything went right, stop the container and copy the file `nginx/seafile.conf` to `/path/to/swag/volume/nginx/site-confs` and set your domain at the mentioned sections.

#### (Optional) No SWAG

Alternatively, you may want not to use the SWAG container for testing and whatever reasons.  Then:

1. Set `NOSWAG=1` in your dotenv.
2. Edit the file `seafile.noswag.conf` and set your local ip at the mentioned section.

Then depending on your use case configuration may differ.

##### Local network access only

In addition to the former, set `USE_HTTPS=0` in your dotenv. The application will be listening on port 80, if you want to initialize with another port, **both** `NOSWAG_PORT` and `SEAFILE_PORT` variables have to be edited and match.

## Run

Simply run:

```
$ docker compose up -d
```

You should now be able to access `http(s)://your.domain` and log in with your admin account.

>Note: after the first run, all the credentials related environment variables can be removed from the dotenv file.

## Updating

### Seafile service

Usually there's no breaking changes between the images, so the update is straightforward:

```
$ docker compose pull seafile
$ docker compose up -d
```

>Note: rollback will likely fail for major updates

#### Update to Seafile 11 with SQLite

**SQLite support has been removed in Seafile 11**, so if you are using SQLite, you will have to migrate your data to MariaDB or MySQL. See the [migration guide](https://github.com/ChatDeBlofeld/seafile-arm-docker-base/blob/v11.0.13/SQLITE_2_MYSQL.md) for more information.

### Thirdpart images

Like the `seafile` service, a pull of the new image should do the job.

### Reverse-proxy configuration

The Nginx configuration may be updated sometimes, then it has to be downloaded from this repository and copied to the right folder again.

For all default files provided by the swag container, see [this updating procedure](https://github.com/linuxserver/docker-swag#updating-configs).

## Troubleshooting

### Seahub failed to start

Set `daemon` to `False` in `gunicorn.conf.py` and restart the Seafile service to grab more information about a failed start.
