image  := amancevice/superset
stages := build dist final
shells := $(foreach stage,$(stages),shell@$(stage))

node_version     := latest
python_version   := 3.6
superset_version := 0.35.0

.PHONY: all clean demo edge push $(stages) $(shells)

all: latest

.docker:
	mkdir -p $@

.docker/$(superset_version)@dist:  .docker/$(superset_version)@build
.docker/$(superset_version)@final: .docker/$(superset_version)@dist
.docker/$(superset_version)@%:   | .docker
	docker build \
	--build-arg NODE_VERSION=$(node_version) \
	--build-arg PYTHON_VERSION=$(python_version) \
	--build-arg SUPERSET_VERSION=$(superset_version) \
	--iidfile $@ \
	--tag $(image):$(superset_version)-$* \
	--target $* .

.docker/edge@dist:  .docker/edge@build
.docker/edge@final: .docker/edge@dist
.docker/edge@%:   | .docker
	docker build \
	--build-arg NODE_VERSION=$(node_version) \
	--build-arg PYTHON_VERSION=$(python_version) \
	--build-arg SUPERSET_VERSION=master \
	--iidfile $@ \
	--tag $(image):edge-$* \
	--target $* .

.docker/edge: .docker/edge@final
.docker/latest .docker/$(superset_version): .docker/$(superset_version)@final
.docker/%:
	docker tag $(shell cat $<) $(image):$*
	cp $< $@

clean:
	-docker image rm -f $(shell awk {print} .docker/*)
	-rm -rf .docker

demo: .docker/$(superset_version)
	docker run --detach \
	--name superset-$(superset_version) \
	--publish 8088:8088 \
	$(shell cat $<)
	docker exec -it superset-$(superset_version) superset-demo
	docker logs -f superset-$(superset_version)

edge: .docker/edge

latest: .docker/latest .docker/$(superset_version)

push: .docker/latest .docker/$(superset_version)
	docker push $(image):$(superset_version)
	docker push $(image):latest

$(stages): %: .docker/$(superset_version)@%

$(shells): shell@%: .docker/$(superset_version)@%
	docker run --rm -it --entrypoint /bin/bash $(shell cat $<)
