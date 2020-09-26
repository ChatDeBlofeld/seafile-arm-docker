# Seafile on ARM in 5 minutes

A docker-compose based deployment intended to bring seafile on any ARMv7/v8 board with little effort. A database server and a reverse-proxy with automated SSL certificate renewal are included.

This environment has been set up using the following images and packages (which you should glance at for further documentation):

- [Seafile for Raspberry PI]( https://github.com/haiwen/seafile-rpi )
- [linuxserver/mariadb]( https://hub.docker.com/r/linuxserver/mariadb ) as database server
- [linuxserver/swag]( https://github.com/linuxserver/docker-swag ) as reverse-proxy with cerbot support for _Let's Encrypt_.

No guarantees of any kind are provided by using this environment.

## Prerequisites

A functionnal docker-compose environment, a domain name associated with your server and the ports 80 and 443 correctly forwarded. 

## Initialization

Clone this repository in a folder somewhere and change the commented sections in docker-compose.yml and docker-compose.init.yml with the values that fit your case. More configuration - especially for letsencrypt - can be set in the compose file, read the associated documentation if needed.

Then run the following command to begin the installation:

```
docker-compose -f docker-compose.yml -f docker-compose.init.yml run --rm seafile
```

Here are some configurations hints:

```
What is the name of the server? It will be displayed on the client.
3 - 15 letters or digits
[ server name ] Whatever

What is the ip or domain of the server?
For example: www.mycompany.com, 192.168.1.101
[ This server's ip or domain ] Your domain set in the compose file

Which port do you want to use for the seafile fileserver?
[ default "8082" ] Use default

-------------------------------------------------------
Please choose a way to initialize seafile databases:
-------------------------------------------------------

[1] Create new ccnet/seafile/seahub databases
[2] Use existing ccnet/seafile/seahub databases

[ 1 or 2 ] 1

What is the host of mysql server?
[ default "localhost" ] db

From which hosts could the mysql account be used?
[ default "%" ] Use default

What is the port of mysql server?
[ default "3306" ] Use default

What is the password of the mysql root user?
[ root password ] The password you set in the compose file

Enter the name for mysql user of seafile. It would be created if not exists.
[ default "seafile" ] Whatever (default is fine)

Enter the password for mysql user "seafile":
[ password for seafile ] Whatever

Enter the database name for ccnet-server:
[ default "ccnet-db" ]  Whatever (default is fine)

Enter the database name for seafile-server:
[ default "seafile-db" ] Whatever (default is fine)

Enter the database name for seahub:
[ default "seahub-db" ] Whatever (default is fine)
```

Then fill in an admin account and the installation is done.

Finally, run `docker-compose stop` to stop the containers during the next configuration step.

## Configuration

Some extra steps are needed, you **have to** use an editor with su rights for the first 3.

### In `/path/to/seafile/volume/conf/ccnet.conf` 

Remove the port associated with the `SERVICE_URL` and use https:

`SERVICE_URL = https://your.domain`

### In `/path/to/seafile/volume/conf/gunicorn.conf.py`

Change:

`bind = "127.0.0.1:8000"`

To:

`bind = "seafile:8000"`

### In `/path/to/seafile/volume/conf/seahub_settings.py` 

Add the following lines (with your domain correctly set):

```
FILE_SERVER_ROOT = 'https://your.domain/seafhttp'
```

### Reverse-proxy configuration

Copy the file `letsencrypt/seafile.conf` to `/path/to/reverse-proxy/volume/nginx/site-confs` and set your domain at the mentioned sections.

See the following resources for more information about this configuration:

- https://download.seafile.com/published/seafile-manual/deploy/deploy_with_nginx.md
- https://download.seafile.com/published/seafile-manual/deploy/https_with_nginx.md

## Run

Simply run:

```
docker-compose up -d
```

You should now be able to access `https://your.domain` and log in with your previously set admin account.

## Updating

Any patch (x.x.**y**) should be upgradable with a pull of the latest seafile-arm image.

The process for minor/major versions has not been fully considered yet.

## Troubleshooting

The `docker logs` command could provide precious information about what went wrong.

If the connection to the database server is refused when checking the root password (Errno 111), try waiting for a while (~5 minutes) until the server is fully started.

For any other initialization bugs, first try removing all volumes and containers and run again.

If seahub did not start, try running new containers with `docker-compose up -d --force-recreate`. Manually start it inside the container with `/opt/seafile/seafile-server-latest/seafile.sh start-fastcgi` could also help debuging.

If you can't run the letsencrypt container yet (no port forwarding, no domain or whatever), you may want using the testing reverse-proxy. It's a simple Nginx configuration without SSL, just change the mentioned field in `nginx/seafile.conf` and the seafile configuration files for using the hostname of your server.

For initialization:

`docker-compose -f docker-compose.yml -f docker-compose.testing.yml -f docker-compose.init.yml  run --rm seafile`

For run:

`docker-compose -f docker-compose.yml -f docker-compose.testing.yml up -d`
