REPO             := amancevice/superset
STAGES           := build dist final
NODE_VERSION     := 12
PYTHON_VERSION   := 3.6
SUPERSET_VERSION := 0.36.0

.PHONY: default clean clobber edge latest push

default: latest

.docker:
	mkdir -p $@

.docker/$(SUPERSET_VERSION)-dist: .docker/$(SUPERSET_VERSION)-build
.docker/$(SUPERSET_VERSION)-final: .docker/$(SUPERSET_VERSION)-dist
.docker/$(SUPERSET_VERSION)-%: | .docker
	docker build \
	--build-arg NODE_VERSION=$(NODE_VERSION) \
	--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
	--build-arg SUPERSET_VERSION=$(SUPERSET_VERSION) \
	--iidfile $@ \
	--tag $(REPO):$(SUPERSET_VERSION)-$* \
	--target $* \
	.


.docker/edge-dist: .docker/edge-build
.docker/edge-final: .docker/edge-dist
.docker/edge-%: | .docker
	docker build \
	--build-arg NODE_VERSION=$(NODE_VERSION) \
	--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
	--build-arg SUPERSET_VERSION=master \
	--iidfile $@ \
	--tag $(REPO):edge-$* \
	--target $* \
	.

.docker/edge: .docker/edge-final
.docker/latest .docker/$(SUPERSET_VERSION): .docker/$(SUPERSET_VERSION)-final
.docker/%:
	docker tag $$(cat $<) $(REPO):$*
	cp $< $@

clean:
	rm -rf .docker

clobber: clean
	docker image ls $(REPO) --quiet | uniq | xargs docker image rm --force

demo: .docker/$(SUPERSET_VERSION)
	docker run --detach \
	--name superset-$(SUPERSET_VERSION) \
	--publish 8088:8088 \
	$$(cat $<)
	docker exec -it superset-$(SUPERSET_VERSION) superset-demo
	docker logs -f superset-$(SUPERSET_VERSION)

edge: .docker/edge

latest: .docker/latest .docker/$(SUPERSET_VERSION)

push:
	-docker push $(REPO):$(SUPERSET_VERSION)
	-docker push $(REPO):latest
	-docker push $(REPO):edge
