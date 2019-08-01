stages           := build install runtime
superset_version := 0.33.0rc1
build            := $(shell git describe --tags --always)
shells           := $(foreach stage,$(stages),shell@$(stage))

.PHONY: all clean push $(stages) $(shells)

all: .docker/$(build)

.docker:
	mkdir -p $@

.docker/$(build)@install: .docker/$(build)@build
.docker/$(build)@runtime: .docker/$(build)@install
.docker/$(build)@%: | .docker
	docker build \
	--build-arg SUPERSET_VERSION=$(superset_version) \
	--iidfile $@ \
	--tag amancevice/superset:$(build)-$* \
	--target $* .

.docker/$(build): .docker/$(build)@runtime
	docker tag $(shell cat $<) amancevice/superset:$(superset_version)
	docker tag $(shell cat $<) amancevice/superset:latest

clean:
	-docker image rm -f $(shell awk {print} .docker/*)
	-rm -rf .docker

push:
	docker push amancevice/superset:$(build) amancevice/superset:latest

$(stages): %: .docker/$(build)@%

$(shells): shell@%: .docker/$(build)@%
	docker run --rm -it --entrypoint /bin/bash $(shell cat $<)
