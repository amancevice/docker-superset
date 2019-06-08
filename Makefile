version = $(shell grep 'ARG SUPERSET_VERSION' Dockerfile | sed 's/.*=//')

.PHONY: all clean

all: .docker/$(version)

.docker:
	mkdir -p $@

.docker/%: | .docker
	docker build \
	--build-arg SUPERSET_VERSION=$* \
	--iidfile $@ \
	--tag amancevice/superset:$* .

clean:
	-docker image rm -f $(shell sed G .docker/*)
	-rm -rf .docker
