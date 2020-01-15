IMAGE     := amancevice/superset
STAGES    := build dist final
CLEANS    := $(foreach STAGE,$(STAGES),clean@$(STAGE))
IMAGES    := $(foreach STAGE,$(STAGES),image@$(STAGE))
SHELLS    := $(foreach STAGE,$(STAGES),shell@$(STAGE))
TIMESTAMP := $(shell date +%s)

NODE_VERSION     := latest
PYTHON_VERSION   := 3.6
SUPERSET_VERSION := 0.35.2

.PHONY: all clean clobber edge latest $(IMAGES) $(SHELLS)

default: latest

.docker:
	mkdir -p $@

.docker/$(SUPERSET_VERSION)-dist:  .docker/$(SUPERSET_VERSION)-build
.docker/$(SUPERSET_VERSION)-final: .docker/$(SUPERSET_VERSION)-dist
.docker/$(SUPERSET_VERSION)-%:   | .docker
	docker build \
	--build-arg NODE_VERSION=$(NODE_VERSION) \
	--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
	--build-arg SUPERSET_VERSION=$(SUPERSET_VERSION) \
	--iidfile $@@$(TIMESTAMP) \
	--tag $(IMAGE):$(SUPERSET_VERSION)-$* \
	--target $* \
	.
	cp $@@$(TIMESTAMP) $@


.docker/edge-dist:  .docker/edge-build
.docker/edge-final: .docker/edge-dist
.docker/edge-%:   | .docker
	docker build \
	--build-arg NODE_VERSION=$(NODE_VERSION) \
	--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
	--build-arg SUPERSET_VERSION=master \
	--iidfile $@@$(TIMESTAMP) \
	--tag $(IMAGE):edge-$* \
	--target $* \
	.
	cp $@@$(TIMESTAMP) $@

.docker/edge: .docker/edge-final
.docker/latest .docker/$(SUPERSET_VERSION): .docker/$(SUPERSET_VERSION)-final
.docker/%:
	docker tag $(shell cat $<) $(IMAGE):$*
	cp $< $@

clean:
	-find .docker -name '$(SUPERSET_VERSION)-*' -not -name '*@*' | xargs rm

clobber:
	-awk {print} .docker/* 2> /dev/null | uniq | xargs docker image rm --force
	-rm -rf .docker

demo: .docker/$(SUPERSET_VERSION)
	docker run --detach \
	--name superset-$(SUPERSET_VERSION) \
	--publish 8088:8088 \
	$(shell cat $<)
	docker exec -it superset-$(SUPERSET_VERSION) superset-demo
	docker logs -f superset-$(SUPERSET_VERSION)

edge: .docker/edge

latest: .docker/latest .docker/$(SUPERSET_VERSION)

$(IMAGES): image@%: .docker/$(SUPERSET_VERSION)-%

$(SHELLS): shell@%: .docker/$(SUPERSET_VERSION)-%
	docker run --rm -it --entrypoint /bin/bash $(shell cat $<)
