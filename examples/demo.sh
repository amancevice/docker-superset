#!/bin/bash

set -e

case $1 in
  celery | mysql | postgres | sqlite) ;;
  *) echo "Usage: ./demo.sh mysql|postgres|sqlite|celery" ; exit 1 ;;
esac

cd $1

# Start back end
if [ "$1" == "sqlite" ]; then
  echo "Starting redis service..."
  docker compose up -d redis
else
  echo "Starting db & redis services..."
  docker compose up -d db redis
  echo "Sleeping for 10s"
  sleep 10
fi

# Start Superset
echo "Starting Superset..."
docker compose up -d superset
if [ "$1" == "celery" ]; then
  echo "Starting Superset worker..."
  docker compose up -d worker
fi
echo "Sleeping for 10s"
sleep 10

# Inititalize Demo
docker compose exec superset superset-demo

echo "Navigate to http://localhost:8088 to view demo"
echo -n "Press RETURN to bring down demo"
read down
docker compose down -v
