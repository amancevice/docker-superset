FROM debian:stretch

# Superset version
ARG SUPERSET_VERSION=0.26.3

# Configure environment
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONPATH=/etc/superset:/home/superset:$PYTHONPATH \
    SUPERSET_REPO=apache/incubator-superset \
    SUPERSET_VERSION=${SUPERSET_VERSION} \
    SUPERSET_HOME=/var/lib/superset

# Create superset user & install dependencies
RUN useradd -U -m superset && \
    mkdir /etc/superset  && \
    mkdir ${SUPERSET_HOME} && \
    chown -R superset:superset /etc/superset && \
    chown -R superset:superset ${SUPERSET_HOME} && \
    apt-get update && \
    apt-get install -y \
        build-essential \
        curl \
        default-libmysqlclient-dev \
        freetds-dev \
        freetds-bin \
        libffi-dev \
        libldap2-dev \
        libpq-dev \
        libsasl2-dev \
        libssl-dev \
        python3-dev \
        python3-pip && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/* && \
    curl https://raw.githubusercontent.com/${SUPERSET_REPO}/${SUPERSET_VERSION}/requirements.txt -o requirements.txt && \
    pip3 install --no-cache-dir \
        -r requirements.txt \
        Werkzeug==0.14.1 \
        flask-cors==3.0.6 \
        flask-mail==0.9.1 \ 
        flask-oauth==0.12 \
        flask_oauthlib==0.9.5 \
        gevent==1.3.4 \
        impyla==0.14.1 \
        mysqlclient==1.3.13 \
        pymssql==2.1.3 \
        psycopg2==2.7.5 \
        pyathena==1.2.5 \
        pyldap==3.0.0 \
        redis==2.10.6 \
        sqlalchemy-clickhouse==0.1.3.post0 \
        sqlalchemy-redshift==0.7.1 \ 
        superset==${SUPERSET_VERSION} && \
    rm requirements.txt

# Configure Filesystem
COPY superset /usr/local/bin
VOLUME /home/superset \
       /etc/superset \
       /var/lib/superset
WORKDIR /home/superset

# Deploy application
EXPOSE 8088
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]
CMD ["gunicorn", "-w", "2", "--timeout", "60", "-b", "0.0.0.0:8088", "--limit-request-line", "0", "--limit-request-field_size", "0", "superset:app"]
USER superset
