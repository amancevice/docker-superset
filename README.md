# Superset

Docker image for [Superset](https://github.com/ApacheInfra/superset).

This project is unofficial and not related to Superset or Apache.

## Issues

Please **only** file issues in this project that are related to Docker and **do** include the Docker commands or compose configuration of your setup when filing issues (be sure to hide any secrets/passwords before submitting).

File issues/bugs with Superset at the [source](https://github.com/apache/incubator-superset/issues).

Please **do not** files issues like "Please include `<some-python-pip>` in the Dockerfile," open a [pull request](https://github.com/amancevice/superset/pulls) for updates/enhancements.


## Examples

Navigate to the [`examples`](./examples) directory to view examples of how to configure Superset with MySQL, PostgreSQL, or SQLite.


## Versions

This repo is tagged in parallel with superset. Pulling `amancevice/superset:0.18.5` will fetch the image of this repository running superset version `0.18.5`. It is possible that the `latest` tag includes new features/support libraries but will usually be in sync with the latest semantic version.


## Configuration

Follow the [instructions](https://superset.incubator.apache.org/installation.html#configuration) provided by Apache Superset for writing your own `superset_config.py`. Place this file in a local directory and mount this directory to `/etc/superset` inside the container. This location is included in the image's `PYTHONPATH`. Mounting this file to a different location is possible, but it will need to be in the `PYTHONPATH`.

View the contents of the [`examples`](./examples) directory to see some simple `superset_config.py` samples.


## Volumes

The image defines two data volumes: one for mounting configuration into the container, and one for data (logs, SQLite DBs, &c).

The configuration volume is located alternatively at `/etc/superset` or `/home/superset`; either is acceptable. Both of these directories are included in the `PYTHONPATH` of the image. Mount any configuration (specifically the `superset_config.py` file) here to have it read by the app on startup.

The data volume is located at `/var/lib/superset` and it is where you would mount your SQLite file (if you are using that as your backend), or a volume to collect any logs that are routed there. This location is used as the value of the `SUPERSET_HOME` environmental variable.

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

# Sync the base permissions
docker exec superset-new superset init
```
