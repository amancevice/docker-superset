stages           := build dist final
superset_version := 0.33.0rc1
build            := $(shell git describe --tags --always)
shells           := $(foreach stage,$(stages),shell@$(stage))

.PHONY: all clean push $(stages) $(shells)

all: .docker/$(build)

.docker:
	mkdir -p $@

.docker/$(build)@dist: .docker/$(build)@build
.docker/$(build)@final: .docker/$(build)@dist
.docker/$(build)@%: | .docker
	docker build \
	--build-arg SUPERSET_VERSION=$(superset_version) \
	--iidfile $@ \
	--tag amancevice/superset:$(build)-$* \
	--target $* .

.docker/$(build): .docker/$(build)@final
	docker tag $(shell cat $<) amancevice/superset:$(build)
	cp $< $@

clean:
	-docker image rm -f $(shell awk {print} .docker/*)
	-rm -rf .docker

demo: .docker/$(build)
	docker run --detach \
	--name superset-$(build) \
	--publish 8088:8088 \
	$(shell cat $<)
	docker exec -it superset-$(build) superset-demo
	docker logs -f superset-$(build)

$(stages): %: .docker/$(build)@%

$(shells): shell@%: .docker/$(build)@%
	docker run --rm -it --entrypoint /bin/bash $(shell cat $<)
