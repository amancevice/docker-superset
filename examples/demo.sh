#!/bin/bash -e

stderr() { printf "$(tput setaf $1)$2$(tput sgr0)" "${*:3}" >&2 ; }
execho() { stderr 240 "%s\n" "$*" ; eval "$@" ; }

case $1 in
	celery | mysql | postgres | sqlite) ;;
	*) echo "Usage: ./demo.sh mysql|postgres|sqlite|celery" ; exit 1 ;;
esac

cd $1

# Start back end
if [ "$1" == "sqlite" ]; then
	execho docker compose up -d redis
else
	execho docker compose up -d db redis
	execho sleep 10
fi

# Start Superset
execho docker compose up -d superset
if [ "$1" == 'celery' ]; then
	execho docker compose up -d worker
fi
execho sleep 10

# Inititalize Demo
execho docker compose exec superset superset-demo

# Show message
stderr 6 "%s\n" 'Navigate to http://localhost:8088 to view demo'
stderr 6 "%s " 'Press RETURN to bring down demo'
read
execho docker compose down -v
