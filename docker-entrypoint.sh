#!/bin/sh

echo "*** Startup $0 succeed now starting service using eval to expand CMD variables ***"

exec $(eval echo "$@")
