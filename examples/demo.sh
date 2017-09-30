#!/bin/bash

set -e

if [ -z $1 ]; then
  echo "Usage: bash demo.sh mysql|postgres|sqlite|celery"
  exit 1
elif [ "$1" != "mysql" ] && [ "$1" != "postgres" ] && [ "$1" != "sqlite" ] && [ "$1" != "celery" ]; then
  echo "Usage: bash demo.sh mysql|postgres|sqlite|celery"
  exit 1
fi

cd $1

# Start back end
if [ "$1" == "sqlite" ]; then
  echo "Starting redis service..."
  docker-compose up -d redis
  >| ./superset/superset.db
elif [ "$1" == "mysql" ] || [ "$1" == "postgres" ]; then
  echo "Starting redis & $1 services..."
  docker-compose up -d redis $1
  echo "Sleeping for 30s"
  sleep 30
else
  echo "Starting redis & postgres services..."
  docker-compose up -d redis postgres
  echo "Sleeping for 30s"
  sleep 30
fi

# Start Superset
echo "Starting Superset..."
docker-compose up -d superset
if [ "$1" == "celery" ]; then
  echo "Starting Superset worker..."
  docker-compose up -d worker
fi
echo "Sleeping for 30s"
sleep 30

# Inititalize Demo
docker-compose exec superset superset-demo

echo "Navigate to http://localhost:8088 to view demo"
echo -n "Press RETURN to bring down demo"
read down
docker-compose down -v
