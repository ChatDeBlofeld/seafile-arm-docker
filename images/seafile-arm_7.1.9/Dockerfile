ARG VERSION=7.1.9

FROM debian:buster AS builder

ARG VERSION

RUN apt-get update -y && apt-get install -y \
    wget \
    sudo

# Build seafile
RUN wget https://raw.githubusercontent.com/ChatDeBlofeld/seafile-rpi/master/build3.sh
RUN chmod u+x build3.sh && ./build3.sh $VERSION pro

# Extract package
RUN tar -xzf built-seafile-server-pkgs/*.tar.gz
RUN mkdir seafile && mv seafile-server-$VERSION seafile

WORKDIR /seafile

# Fix import not found when running seafile
RUN ln -s python3.7 seafile-server-$VERSION/seafile/lib/python3.6

# Prepare media folder to be exposed
RUN mv seafile-server-$VERSION/seahub/media .

FROM debian:buster

ARG VERSION

RUN apt-get update && apt-get install -y \
    sudo \
    procps \
    python3 \
    python3-setuptools \
    python3-ldap \
    python3-sqlalchemy

WORKDIR /opt/seafile

COPY --from=builder /seafile /opt/seafile

# Add version in container context
ENV VERSION $VERSION

COPY scripts /root

CMD ["/root/launch.sh"]
