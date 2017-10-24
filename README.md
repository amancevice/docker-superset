# Superset

Docker image for [Superset](https://github.com/ApacheInfra/superset).


## Examples

Navigate to the [`examples`](./examples) directory to view examples of how to configure Superset with MySQL, PostgreSQL, or SQLite.


## Versions

This repo is tagged in parallel with superset. Pulling `amancevice/superset:0.18.5` will fetch the image of this repository running superset version `0.18.5`. It is possible that the `latest` tag includes new features/support libraries but will usually be in sync with the latest semantic version.


## Configuration

Follow the [instructions](https://superset.incubator.apache.org/installation.html#configuration) provided by Apache Superset for writing your own `superset_config.py`. Place this file in a local directory and mount this directory to `/etc/superset` inside the container. This location is included in the image's `PYTHONPATH`. Mounting this file to a different location is possible, but it will need to be in the `PYTHONPATH`.

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

## Amazon EC2 Container Service

You can use Superset with Amazon EC2 Container Service. We have made ready made task definitions for use with MySQL. Run it by following this steps:

1. On the host machine make the folder /data/superset/ a copy the `superset_config.py` file from `examples/mysql/superset` into it
2. Set owner and group of both /data/superset/ and /data/superset/superset_config.py to 999
3. Make a new Amazon ECS task definition using the JSON in `aws-task-def.json`
4. Run your task
5. Log into the host machine and initialize the database with an admin user and Superset tables using the superset-init helper script:
```bash
docker exec -it <container id> superset-init
```
