stages         := build install runtime
edge_version   := 0.33.0rc1
stable_version := 0.29.0rc7

.PHONY: all edge clean $(foreach stage,$(stages),edge@$(stage))

all: stable

.docker:
	mkdir -p $@

.docker/edge@install: .docker/edge@build
.docker/edge@runtime: .docker/edge@install
.docker/edge@%: | .docker
	docker build \
	--build-arg SUPERSET_VERSION=$(edge_version) \
	--file Dockerfile.edge \
	--iidfile $@ \
	--tag amancevice/superset:edge-$* \
	--target $* .

.docker/%: | .docker
	docker build \
	--build-arg SUPERSET_VERSION=$* \
	--iidfile $@ \
	--tag amancevice/superset:$* .

clean:
	-docker image rm -f $(shell awk {print} .docker/*)
	-rm -rf .docker

edge: .docker/edge@runtime
	docker tag $(shell cat $<) amancevice/superset:edge

edge@stage: edge@%: .docker/edge@%

stable: .docker/$(stable_version)
