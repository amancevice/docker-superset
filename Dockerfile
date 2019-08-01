##
# Build assets
FROM node:12.7 AS build
ARG SUPERSET_VERSION=0.33.0rc1
WORKDIR /var/lib/superset/
RUN wget -O superset.tar.gz https://github.com/apache/incubator-superset/archive/${SUPERSET_VERSION}.tar.gz
RUN tar xzf superset.tar.gz -C /var/lib/superset/ --strip-components=1
WORKDIR /var/lib/superset/superset/assets
RUN npm install
RUN npm run build

##
# Install Superset and dependencies as Python packages
FROM python:3.6 AS install
WORKDIR /var/lib/superset/
COPY --from=build /var/lib/superset/ .
RUN pip install . -r requirements.txt

##
# Build runtime
FROM python:3.6 AS runtime

# Configure environment
ENV GUNICORN_BIND=0.0.0.0:8088 \
    GUNICORN_LIMIT_REQUEST_FIELD_SIZE=0 \
    GUNICORN_LIMIT_REQUEST_LINE=0 \
    GUNICORN_TIMEOUT=60 \
    GUNICORN_WORKERS=2 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONPATH=/etc/superset:/home/superset:$PYTHONPATH \
    SUPERSET_REPO=apache/incubator-superset \
    SUPERSET_VERSION=${SUPERSET_VERSION} \
    SUPERSET_HOME=/var/lib/superset
ENV GUNICORN_CMD_ARGS="--workers ${GUNICORN_WORKERS} --timeout ${GUNICORN_TIMEOUT} --bind ${GUNICORN_BIND} --limit-request-line ${GUNICORN_LIMIT_REQUEST_LINE} --limit-request-field_size ${GUNICORN_LIMIT_REQUEST_FIELD_SIZE}"

# Create superset user & install dependencies
RUN useradd -U -m superset && \
    mkdir -p /etc/superset  && \
    mkdir -p ${SUPERSET_HOME} && \
    chown -R superset:superset /etc/superset && \
    chown -R superset:superset ${SUPERSET_HOME} && \
    apt-get update && \
    apt-get install -y \
        build-essential \
        curl \
        default-libmysqlclient-dev \
        freetds-bin \
        freetds-dev \
        libffi-dev \
        libldap2-dev \
        libpq-dev \
        libsasl2-2 \
        libsasl2-dev \
        libsasl2-modules-gssapi-mit \
        libssl1.0 && \
    apt-get clean

# Copy Superset from build stage & install database helpers
WORKDIR /usr/local/lib/python3.6/site-packages
COPY --from=install /usr/local/lib/python3.6/site-packages .
RUN pip install --no-cache-dir \
        cython==0.29.13 \
        flask-cors==3.0.3 \
        flask-mail==0.9.1 \
        flask-oauth==0.12 \
        flask_oauthlib==0.9.5 \
        gevent==1.2.2 \
        impyla==0.14.0 \
        infi.clickhouse-orm==1.0.2 \
        mysqlclient==1.4.2 \
        psycopg2==2.7.6.1 \
        pyathena==1.5.1 \
        pybigquery==0.4.10 \
        pyhive==0.5.1 \
        pyldap==2.4.28 \
        pymssql==2.1.4 \
        redis==2.10.5 \
        sqlalchemy-clickhouse==0.1.5.post0 \
        sqlalchemy-redshift==0.7.1 \
        werkzeug==0.14.1

# Configure Filesystem
COPY superset /usr/local/bin
VOLUME /home/superset \
       /etc/superset \
       /var/lib/superset
WORKDIR /home/superset

# Deploy application
EXPOSE 8088
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]
CMD ["gunicorn", "superset:app"]
USER superset
