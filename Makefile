REPO             := amancevice/superset
PYTHON_VERSION   := 3.8
SUPERSET_VERSION := 2.0.0

build: requirements-dev.txt
	docker build \
	--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
	--build-arg SUPERSET_VERSION=$(SUPERSET_VERSION) \
	--tag $(REPO) \
	--tag $(REPO):$(SUPERSET_VERSION) \
	.

clean:
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
	touch .venv

.venv:
	mkdir -p $@
	pipenv --python $(PYTHON_VERSION)
