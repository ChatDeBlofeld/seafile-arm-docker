## Memcached (seahub_config.py)

```python
CACHES = {
    'default': {
        'BACKEND': 'django_pylibmc.memcached.PyLibMCCache',
        'LOCATION': 'memcached:11211',
    },
}
```

## Webdav (seafdav.conf)

```
[WEBDAV]
enabled = true
host = seafile
port = 8080
fastcgi = false
share_name = /seafdav
```
