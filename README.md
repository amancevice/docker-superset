# Superset

Docker image for [AirBnB's Superset](https://github.com/airbnb/superset).

*Formerly [Caravel](https://github.com/amancevice/caravel)*


## Demo

Run the superset demo by entering this command into your console:

```bash
git clone git@github.com:amancevice/superset.git
cd superset
docker-compose up -d redis mysql
# Wait for MySQL to come online...
docker-compose up -d superset
# Wait for Superset to come online...
docker-compose exec superset demo
```

You will be prompted to set up an admin user.

When finished navigate to [http://localhost:8088/](http://localhost:8088/) to see the demo.

Log in with the credentials you just created.


## Versions

This repo is tagged in parallel with superset. Pulling `amancevice/superset:0.13.1` will fetch the image of this repository running superset version `0.13.1`. It is possible that the `latest` tag includes new features/support libraries but will usually be in sync with the latest semantic version.


## Configuration

As of `0.15.0` I have removed the default `superset_config.py` file that is laid down. Users who wish to override the defaults should review the [configuration](https://github.com/airbnb/superset/blob/master/superset/config.py) provided by AirBnB, determine which values to override, and mount this file to `/home/superset/superset_config.py`.

A very simple example is available for reference at [`./superset_config.py`](./superset_config.py) (which is used by the demo docker-compose file).


## Database Initialization

After starting the Superset server, initialize the database with an admin user and Superset tables using the `superset-init` helper script:

```bash
docker run --detach --name superset [options] amancevice/superset
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
docker run --detach --name superset-new [options] amancevice/superset

# Upgrade the DB
docker exec superset-new superset db upgrade
```
