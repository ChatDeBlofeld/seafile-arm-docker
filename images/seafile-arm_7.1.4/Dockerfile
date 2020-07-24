FROM arm32v7/debian:buster

RUN apt-get update && apt-get install -y \
    sudo \
    procps \
    wget \
    libjpeg-dev \
    python3 \
    python3-setuptools \
    python3-ldap \
    libmemcached-dev \
    zlib1g-dev \
    libxml2-dev \
    libxslt-dev \
    python3-jinja2 \
    python3-sqlalchemy

ARG VERSION=7.1.4

WORKDIR /opt/seafile

RUN wget -qO- https://github.com/haiwen/seafile-rpi/releases/download/v${VERSION}/seafile-server_${VERSION}_pi-buster-stable.tar.gz | tar -xzC .

# Fix import not found when running seahub
RUN apt-get install -y python3-pip \
    && pip3 install -U Pillow -t /opt/seafile/seafile-server-$VERSION/seahub/thirdpart \
    # pip is way too heavy to be installed as a permanent dependency
    && apt-get remove -y python3-pip \
    && apt-get autoremove -y \
    && apt-get clean
    

# Fix import not found when running seafile
RUN ln -s python3.7 seafile-server-$VERSION/seafile/lib/python3.6

# Prepare media folder to be exposed
RUN mv seafile-server-$VERSION/seahub/media .

# Add version in container context
ENV VERSION $VERSION

COPY scripts /root

CMD ["/root/launch.sh"]
