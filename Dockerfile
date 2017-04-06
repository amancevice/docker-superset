FROM amancevice/pandas:0.18.1-python3

# Configure environment
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH=$PATH:/home/superset/.bin \
    PYTHONPATH=/home/superset/.superset:$PYTHONPATH \
    SUPERSET_VERSION=0.17.3

# Install dependencies & create superset user
RUN apk add --no-cache \
        curl \
        libffi-dev \
        cyrus-sasl-dev \
        mariadb-dev \
        postgresql-dev && \
    pip3 install \
        superset==$SUPERSET_VERSION \
        mysqlclient==1.3.7 \
        ldap3==2.1.1 \
        psycopg2==2.6.1 \
        redis==2.10.5 \
        sqlalchemy-redshift==0.5.0 \
        flask-oauth==0.12 \
        flask_oauthlib==0.9.3 \
        flask-mail==0.9.1 && \
    addgroup superset && \
    adduser -h /home/superset -G superset -D superset && \
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
