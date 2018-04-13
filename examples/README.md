# Superset Examples

Example configurations for MySQL, PostgreSQL, SQLite, and Celery are provided, along with a simple demo script for starting them.

Each demo provides a `superset_config.py` and a `docker-compose.yml`. Use these as guides for laying down your own instances.

Start a demo of Superset using the `demo.sh` script. The script takes a single argument that determines the back end for Superset: `sqlite`, `mysql`, `postgres`, or `celery`.

```bash
bash demo.sh mysql|postgres|sqlite|celery
```

You will be prompted to set up an admin user.

When finished navigate to [http://localhost:8088/](http://localhost:8088/) to see the demo.

Log in with the credentials you just created.

The demo will live for 5 minutes and then be brought down.

Here is a more detailed explanation of what the demo script is doing:

## MySQL

```bash
cd mysql

# Start Redis & MySQL services
docker-compose up -d redis mysql
# Wait for services to come up fully...

# Start Superset
docker-compose up -d superset
# Wait for Superset to come up fully...

# Initialize Superset DB
docker-compose exec superset superset-demo
# or `docker-compose exec superset superset-init` if no demo data needed

# Play around in demo...

# Bring everything down
docker-compose down -v
```

## PostgreSQL

```bash
cd postgres

# Start Redis & PostgreSQL services
docker-compose up -d redis postgres
# Wait for services to come up fully...

# Start Superset
docker-compose up -d superset
# Wait for Superset to come up fully...

# Initialize demo
docker-compose exec superset superset-demo
# or `docker-compose exec superset superset-init` if no demo data needed

# Play around in demo...

# Bring everything down
docker-compose down -v
```

## SQLite

```bash
cd sqlite

# Start Redis service
docker-compose up -d redis
# Wait for services to come up fully...

# Touch SQLite db file
mkdir -p superset
touch superset/superset.db

# Start Superset
docker-compose up -d superset
# Wait for Superset to come up fully...

# Initialize demo
docker-compose exec superset superset-demo
# or `docker-compose exec superset superset-init` if no demo data needed

# Play around in demo...

# Bring everything down
docker-compose down -v
```

## Celery

```bash
cd celery

# Start Redis & PostgreSQL services
docker-compose up -d redis postgres
# Wait for services to come up fully...

# Start Superset
docker-compose up -d superset
# Wait for Superset to come up fully...

# Start Celery worker
docker-compose up -d worker

# Initialize demo
docker-compose exec superset superset-demo
# or `docker-compose exec superset superset-init` if no demo data needed

# Play around in demo...

# Bring everything down
docker-compose down -v
```
