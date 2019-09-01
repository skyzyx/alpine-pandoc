# alpine-pandoc

![MicroBadger Size (tag)](https://img.shields.io/microbadger/image-size/skyzyx/alpine-pandoc/1.2.0?style=for-the-badge)
![MicroBadger Layers (tag)](https://img.shields.io/microbadger/layers/skyzyx/alpine-pandoc/1.2.0?style=for-the-badge)
![Docker Pulls](https://img.shields.io/docker/pulls/skyzyx/alpine-pandoc?style=for-the-badge)
![Docker Stars](https://img.shields.io/docker/stars/skyzyx/alpine-pandoc?style=for-the-badge)

This is the source code which builds a Docker container comprised of Alpine Linux, [Pandoc], and [PlantUML].
It is intended to provide an environment which is optimized for generating documentation.

We use:

* [Pandoc] (Haskell) to convert [Markdown] into HTML, [reStructuredText] or PDF.
* [PlantUML] (Java) to convert UML diagrams to SVG or PNG images.

## Building the Container

```bash
make
```

## Consuming the Container

The short version is `FROM skyzyx/alpine-pandoc:1.2.0`.

1. Compiling Pandoc takes some time, so using this container saves you that time.
1. Build your own container with your own specific dependencies using `RUN` commands.
1. Use something like [Docker Compose] to mount your documentation source to `/var/docs`.
1. Add your documentation-building task as an `ENTRYPOINT`.

`docker-compose up` the first time (or with `--build`) will build your custom container, then run your `ENTRYPOINT` task.
Subsequent runs of `docker-compose up` will only execute your `ENTRYPOINT` task.

### Sample `Dockerfile`

#### Using [Sphinx]

```Dockerfile
FROM skyzyx/alpine-pandoc:1.2.0

ENV PERSISTENT_DEPS wget git mercurial make openssh sphinx
ENV SPHINXBUILD /usr/bin/sphinx-build
ENV SPHINXOPTS -T

# Copy Source code and set working directory
COPY src /var/docs
WORKDIR /var/docs

USER root

RUN apk add --no-cache --virtual .persistent-deps $PERSISTENT_DEPS
RUN pip install -r requirements.txt

ENTRYPOINT ["make", "docs"]
```

#### Using [XeTeX] and [pandoc-plantuml-filter]

```Dockerfile
FROM skyzyx/alpine-pandoc:1.2.0

USER root
ENV DEPS \
    make \
    texlive-xetex
RUN apk add --no-cache $DEPS && \
    pip install pandoc-plantuml-filter

USER pandoc
ENTRYPOINT ["make", "docs"]

# make ultimately calls:
#  pandoc --filter=pandoc-plantuml
#         --output=out.pdf
#         --from=markdown
#         *.md
```

### Sample `docker-compose.yml`

```yaml
version: "3"
services:
    documentation-builder:
        build: .
        volumes:
            - ./src:/var/docs
```

[Docker Compose]: https://docs.docker.com/compose/
[Markdown]: http://commonmark.org
[Pandoc]: http://pandoc.org
[pandoc-plantuml-filter]: https://github.com/timofurrer/pandoc-plantuml-filter
[PlantUML]: http://plantuml.com
[reStructuredText]: http://docutils.sourceforge.net/rst.html
[Sphinx]: http://www.sphinx-doc.org
[XeTeX]: http://xetex.sourceforge.net/
