# Superset

Docker image for [AirBnB's Superset](https://github.com/airbnb/superset).

*Formerly [Caravel](https://github.com/amancevice/caravel)*


## Examples

Navigate to the [`examples`](./examples) directory to view examples of how to configure Superset with MySQL, PostgreSQL, or SQLite.


## Versions

This repo is tagged in parallel with superset. Pulling `amancevice/superset:0.17.3` will fetch the image of this repository running superset version `0.17.3`. It is possible that the `latest` tag includes new features/support libraries but will usually be in sync with the latest semantic version.


## Configuration

Follow the [instructions](http://airbnb.io/superset/installation.html#configuration) provided by AirBnB for writing your own `superset_config.py`. Place this file in a local directory and mount this directory to `/home/superset/.superset` inside the container. This location is included in the image's `PYTHONPATH`. Mounting this file to a different location is possible, but it will need to be in the `PYTHONPATH`.

View the contents of the [`examples`](./examples) directory to see some simple `superset_config.py` samples.


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
