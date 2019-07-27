FROM python:3.6

# Superset version
ARG SUPERSET_VERSION=0.33.0rc1

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
    SUPERSET_DOWNLOAD_URL=https://github.com/apache/incubator-superset/archive/$SUPERSET_VERSION.tar.gz \
    SUPERSET_HOME=/var/lib/superset
ENV GUNICORN_CMD_ARGS="--workers ${GUNICORN_WORKERS} --timeout ${GUNICORN_TIMEOUT} --bind ${GUNICORN_BIND} --limit-request-line ${GUNICORN_LIMIT_REQUEST_LINE} --limit-request-field_size ${GUNICORN_LIMIT_REQUEST_FIELD_SIZE}"

# Create superset user & install dependencies
RUN useradd -U -m superset && \
    mkdir /etc/superset  && \
    mkdir -p ${SUPERSET_HOME} && \
    chown -R superset:superset /etc/superset && \
    chown -R superset:superset ${SUPERSET_HOME} && \
    apt-get update && \
    apt-get install -y \
        apt-transport-https apt-utils

# Install common useful packages
RUN apt-get install -y vim less curl netcat postgresql-client redis-tools

RUN apt-get update -y && apt-get install -y build-essential libssl-dev \
    libffi-dev python3-dev libsasl2-dev libldap2-dev libxi-dev

# Install nodejs for custom build
# https://github.com/apache/incubator-superset/blob/master/docs/installation.rst#making-your-own-build
# https://nodejs.org/en/download/package-manager/
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt-get install -y nodejs

WORKDIR $SUPERSET_HOME

# Download & install superset
RUN wget -O superset.tar.gz $SUPERSET_DOWNLOAD_URL \
    && tar -xzf superset.tar.gz -C $SUPERSET_HOME --strip-components=1 \
    && rm superset.tar.gz

# RUN mkdir -p /home/superset/.cache
# RUN mkdir -p /home/superset/config
COPY database-dependencies.txt .

RUN pip install --upgrade setuptools pip \
    && pip install -r requirements.txt \
    && pip install -r requirements-dev.txt \
    && pip install -e . \
    && pip install -r database-dependencies.txt

RUN cd superset/assets \
    && npm ci \
    && npm run build \
    && rm -rf node_modules

# Configure Filesystem
VOLUME /home/superset \
       /etc/superset \
       /var/lib/superset
WORKDIR /home/superset
RUN chown -R superset:superset ${SUPERSET_HOME} 

# Deploy application
EXPOSE 8088
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]
CMD ["gunicorn", "superset:app"]
USER superset
