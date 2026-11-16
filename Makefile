DOCKER_IMAGE ?= hipv-anvil
export HIPV_DOCKER_IMAGE := $(DOCKER_IMAGE)

.PHONY: all html pdf preview render clean check publish


all: render

# Render every configured format (html + pdf, per _quarto.yml)
render:
	quarto render

# Render HTML only
html:
	quarto render --to html

# Render PDF only (uses tectonic, see _quarto.yml)
pdf:
	quarto render --to pdf

# Live-reloading local preview server
preview:
	quarto preview

# Verify Quarto + engines + dependencies are correctly installed
check:
	quarto check

# Remove rendered output
clean:
	rm -rf _book .quarto index_files site_libs chapters/*_files

# Publish the rendered book to the gh-pages branch
# First run needs interactive GitHub authentication, see README/CLAUDE.md
publish:
	quarto publish gh-pages


docker-build:
	docker build --platform linux/amd64 \
	    --build-arg HOST_UID=$(shell id -u) --build-arg HOST_GID=$(shell id -g) \
	    -t $(DOCKER_IMAGE) docker

docker-shell:
	docker/run.sh

# docker-<target>: run `make <target>` inside the container
docker-%:
	docker/run.sh make $* APP=$(APP)