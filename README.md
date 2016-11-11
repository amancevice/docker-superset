# Caravel

Docker image for [AirBnB's Superset](https://github.com/airbnb/superset).

*Formerly [Caravel](https://github.com/amancevice/caravel)*


## Demo

Run the superset demo by entering this command into your console:

```bash
git clone git@github.com:amancevice/superset.git
cd superset
docker-compose up -d
docker-compose exec superset demo
```

You will be prompted to set up an admin user.

When finished navigate to [http://localhost:8088/](http://localhost:8088/) to see the demo.

Log in with the credentials you just created.


## Versions

This repo is tagged in parallel with superset. Pulling `amancevice/superset:0.13.1` will fetch the image of this repository running superset version `0.13.1`. As it is an automated build, commits to the master branch of this repository trigger a re-build of the `latest` tag, while tagging master triggers a versioned build. It is possible that the `latest` tag includes new deployment-specific features but will usually be in sync with the latest semantic version.


## Database Setup

Determine where you will store Caravel's database; choose `SQLite`, `MySQL`, `PostgreSQL`, or `Redshift`. Use the `ENV` variable `SQLALCHEMY_DATABASE_URI` to point superset to the correct database. Be sure to set a `SECRET_KEY` when creating the container.


#### SQLite

If Caravel's database is created using SQLite the db file should be mounted from the host machine. In this example we will store a SQLite DB on our host machine in `~/superset/superset.db` and mount the directory to `/home/superset/.superset` in the container.

```bash
docker run --detach --name superset \
    --env SECRET_KEY="mySUPERsecretKEY" \
    --env SQLALCHEMY_DATABASE_URI="sqlite:////home/superset/.superset/superset.db" \
    --publish 8088:8088 \
    --volume ~/superset:/home/superset/db \
    amancevice/superset
```


#### MySQL

```bash
docker run --detach --name superset \
    --env SECRET_KEY="mySUPERsecretKEY" \
    --env SQLALCHEMY_DATABASE_URI="mysql://user:pass@host:port/db" \
    --publish 8088:8088 \
    amancevice/superset
```


#### PostgreSQL

```bash
docker run --detach --name superset \
    --env SECRET_KEY="mySUPERsecretKEY" \
    --env SQLALCHEMY_DATABASE_URI="postgresql://user:pass@host:port/db" \
    --publish 8088:8088 \
    amancevice/superset
```


#### Redshift

```bash
docker run --detach --name superset \
    --env SECRET_KEY="mySUPERsecretKEY" \
    --env SQLALCHEMY_DATABASE_URI="redshift+psycopg2://username@host.amazonaws.com:5439/db" \
    --publish 8088:8088 \
    amancevice/superset
```


## Database Initialization

After starting the Caravel server, initialize the database with an admin user and Caravel tables using the `superset-init` helper script:

```bash
docker run --detach --name superset ... amancevice/superset
docker exec -it superset superset-init
```


## Upgrading

Upgrading to a newer version of superset can be accomplished by re-pulling `amancevice/superset`at a specified superset version or `latest` (see above for more on this). Remove the old container and re-deploy, making sure to use the correct environmental configuration. Finally, ensure the superset database is migrated up to the head:

```bash
# Pull desired version
docker pull amancevice/superset

# Remove the current container
docker rm -f superset-old

# Deploy a new container ...
docker run --detach --name superset-new ...

# Upgrade the DB
docker exec superset-new superset db upgrade
```


## Additional Configuration

A custom configuration can be accomplished through mounting a Caravel config to `~superset/superset_config.py` in the container or by setting `ENV` variables:
* `ROW_LIMIT`
* `WEBSERVER_THREADS`
* `SECRET_KEY`
* `SQLALCHEMY_DATABASE_URI`
* `CSRF_ENABLED`
* `DEBUG`

Additional environmental variables prefixed with `SUPERSET_` will also be passed to the superset configuration (without the `SUPERSET_` prefix). See the [superset configuration file](https://github.com/airbnb/superset/blob/master/superset/config.py) for a list of available configuration keys.

For example, the following command will deploy superset with the [`LOG_LEVEL`](https://github.com/airbnb/superset/blob/master/superset/config.py) variable set in the superset configuration:

```bash
docker run --detach --name superset \
    --env SUPERSET_LOG_LEVEL="INFO" \
    --publish 8088:8088 \
    amancevice/superset
```
