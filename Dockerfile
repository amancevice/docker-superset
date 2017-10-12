FROM debian:stretch

# Superset version
ARG SUPERSET_VERSION=0.20.4

# Configure environment
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONPATH=/etc/superset:$PYTHONPATH \
    SUPERSET_VERSION=${SUPERSET_VERSION} \
    SUPERSET_HOME=/home/superset

# Create superset user & install dependencies
RUN useradd -U -m superset && \
    apt-get update && \
    apt-get install -y \
        build-essential \
        curl \
        default-libmysqlclient-dev \
        libldap2-dev \
        libpq-dev \
        libsasl2-dev \
        libssl-dev \
        openjdk-8-jdk \
        python3-dev \
        python3-pip && \
    pip3 install \
        flask-mail==0.9.1 \
        flask-oauth==0.12 \
        flask_oauthlib==0.9.3 \
        gevent==1.2.2 \
        impyla==0.14.0 \
        mysqlclient==1.3.7 \
        psycopg2==2.6.1 \
        pyathenajdbc==1.2.0 \
        pyhive==0.5.0 \
        pyldap==2.4.28 \
        redis==2.10.5 \
        sqlalchemy-redshift==0.5.0 \
        sqlalchemy-clickhouse==0.1.1.post3 \
        Werkzeug==0.12.1 \
        superset==${SUPERSET_VERSION}

# Configure Filesystem
COPY superset /usr/local/bin
VOLUME /etc/superset
WORKDIR /home/superset

# Deploy application
EXPOSE 8088
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]
ENTRYPOINT ["superset"]
CMD ["runserver"]
USER superset
