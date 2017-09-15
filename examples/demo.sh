#!/bin/bash

set -e

if [ -z $1 ]; then
  echo "Usage: bash demo.sh mysql|postgres|sqlite"
  exit 1
elif [ "$1" != "mysql" ] && [ "$1" != "postgres" ] && [ "$1" != "sqlite" ]; then
  echo "Usage: bash demo.sh mysql|postgres|sqlite"
  exit 1
fi

cd $1

# Start back end
if [ "$1" == "sqlite" ]; then
  echo "Starting redis service..."
  docker-compose up -d redis
else
  echo "Starting redis & $1 services..."
  docker-compose up -d redis $1
  echo "Sleeping for 30s"
  sleep 30
fi

# Start Superset
echo "Starting Superset..."
docker-compose up -d superset
echo "Sleeping for 30s"
sleep 30

# Inititalize Demo
docker-compose exec superset superset-demo

echo "Navigate to http://localhost:8088 to view demo"
echo -n "Press RETURN to bring down demo"
read down
docker-compose down -v
