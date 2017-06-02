FROM amancevice/pandas:0.19.2-python3

# Configure environment
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH=$PATH:/home/superset/.bin \
    PYTHONPATH=/home/superset/.superset:$PYTHONPATH \
    SUPERSET_VERSION=0.18.3

# Install dependencies & create superset user
RUN apk add --no-cache \
        curl \
        cyrus-sasl-dev \
        libffi-dev \
        mariadb-dev \
        openldap-dev \
        postgresql-dev && \
    pip3 install \
        flask-mail==0.9.1 \
        flask-oauth==0.12 \
        flask_oauthlib==0.9.3 \
        impyla==0.14.0 \
        mysqlclient==1.3.7 \
        psycopg2==2.6.1 \
        pyhive==0.2.1 \
        pyldap==2.4.28 \
        redis==2.10.5 \
        sqlalchemy-redshift==0.5.0 \
        sqlalchemy-clickhouse==0.1.1.post3 \
        superset==$SUPERSET_VERSION && \
    addgroup superset && \
    adduser -h /home/superset -G superset -D superset && \
    mkdir /home/superset/.superset && \
    touch /home/superset/.superset/superset.db && \
    chown -R superset:superset /home/superset

# Configure Filesysten
WORKDIR /home/superset
COPY superset .
VOLUME /home/superset/.superset

# Deploy application
EXPOSE 8088
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]
ENTRYPOINT ["superset"]
CMD ["runserver"]
USER superset
