REPO             := amancevice/superset
PYTHON_VERSION   := $(shell python --version | grep -Eo '[0-9.]+')
SUPERSET_VERSION := $(shell grep apache-superset Pipfile | grep -Eo '[0-9.]+')

build: requirements-dev.txt
	docker buildx build \
	--platform linux/amd64 \
	--tag $(REPO) \
	--tag $(REPO):$(SUPERSET_VERSION) \
	.

clean:
	pipenv --rm
	docker image ls --quiet $(REPO) | uniq | xargs docker image rm --force

edge: requirements-dev.txt
	docker build \
	--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
	--build-arg SUPERSET_VERSION=master \
	--file Dockerfile.edge \
	--tag $(REPO):edge \
	.

push:
	docker push --all-tags $(REPO)

.PHONY: build clean demo edge push

requirements-dev.txt: requirements.txt
	pipenv requirements --dev > $@

requirements.txt: Pipfile.lock
	pipenv requirements > $@

Pipfile.lock: Pipfile | .venv
	pipenv lock

.venv:
	rm -rf $@
	mkdir -p $@
	pipenv --python $(PYTHON_VERSION)
	touch $@
