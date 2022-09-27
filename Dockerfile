ARG NODE_VERSION=16
ARG PYTHON_VERSION=3.8

FROM python:$PYTHON_VERSION

# Configure environment
# superset recommended defaults: https://superset.apache.org/docs/installation/configuring-superset#running-on-a-wsgi-http-server
# gunicorn recommended defaults: https://docs.gunicorn.org/en/0.17.2/configure.html#security
ARG SUPERSET_VERSION=2.0.0
ENV FLASK_APP=superset
ENV GUNICORN_BIND=0.0.0.0:8088
ENV GUNICORN_LIMIT_REQUEST_FIELD_SIZE=8190
ENV GUNICORN_LIMIT_REQUEST_LINE=4094
ENV GUNICORN_THREADS=4
ENV GUNICORN_TIMEOUT=120
ENV GUNICORN_WORKERS=10
ENV GUNICORN_WORKER_CLASS=gevent
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONPATH=/etc/superset:/home/superset:$PYTHONPATH
ENV SUPERSET_REPO=apache/superset
ENV SUPERSET_HOME=/var/lib/superset
ENV SUPERSET_VERSION=$SUPERSET_VERSION
ENV GUNICORN_CMD_ARGS="--bind $GUNICORN_BIND --limit-request-field_size $GUNICORN_LIMIT_REQUEST_FIELD_SIZE --limit-request-line $GUNICORN_LIMIT_REQUEST_LINE --threads $GUNICORN_THREADS --timeout $GUNICORN_TIMEOUT --workers $GUNICORN_WORKERS --worker-class $GUNICORN_WORKER_CLASS"

# Create superset user & install dependencies
WORKDIR /home/superset
COPY requirements*.txt ./
RUN groupadd supergroup && \
    useradd -U -G supergroup superset && \
    chown superset:superset /home/superset && \
    mkdir -p /etc/superset && \
    mkdir -p $SUPERSET_HOME && \
    chown -R superset:superset /etc/superset && \
    chown -R superset:superset $SUPERSET_HOME && \
    apt-get update && \
    apt-get install -y \
        build-essential \
        curl \
        default-libmysqlclient-dev \
        freetds-bin \
        freetds-dev \
        libaio1 \
        libecpg-dev \
        libffi-dev \
        libldap2-dev \
        libpq-dev \
        libsasl2-2 \
        libsasl2-dev \
        libsasl2-modules-gssapi-mit \
        libssl-dev && \
        apt-get clean && \
    pip install -r requirements.txt && \
    pip install -r requirements-dev.txt && \
    pip install apache-superset==$SUPERSET_VERSION

# Configure Filesystem
COPY bin /usr/local/bin
VOLUME /etc/superset
VOLUME /home/superset
VOLUME /var/lib/superset

# Finalize application
EXPOSE 8088
USER superset
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]
CMD ["gunicorn", "superset.app:create_app()"]
