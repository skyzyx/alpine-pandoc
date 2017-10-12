# alpine-pandoc

This is the source code which builds a Docker container comprised of Alpine Linux, [Pandoc], [PlantUML], and [Sphinx]. It is intended to provide an environment which is optimized for generating documentation.

We use:

* [Pandoc] (Haskell) to convert all [Markdown] into either generated HTML or [reStructuredText] files.
* [Sphinx] (Python) to convert [reStructuredText] files into generated HTML.
* [PlantUML] (Java) to convert UML diagrams to SVG images.

## Building the Container

```bash
make
```

## Consuming the Container

The short version is `FROM skyzyx/alpine-pandoc:1.0.0`.

1. Compiling Pandoc takes some time, so using this container saves you that time.
1. Build your own container with your own specific dependencies using `RUN` commands.
1. Use something like [Docker Compose] to mount your documentation source to `/var/docs`.
1. Add your documentation-building task as an `ENTRYPOINT`.

`docker-compose up` the first time (or with `--build`) will build your custom container, then run your `ENTRYPOINT` task. Subsequent runs of `docker-compose up` will only execute your `ENTRYPOINT` task.

```Dockerfile
FROM skyzyx/alpine-pandoc:1.0.0

ENV PERSISTENT_DEPS wget git mercurial make gmp openssh
ENV SPHINXBUILD /usr/bin/sphinx-build
ENV SPHINXOPTS -T

# Copy Source code and set working directory
COPY src /var/docs
WORKDIR /var/docs

USER root

RUN apk add --no-cache --virtual .persistent-deps $PERSISTENT_DEPS && \
    pip install -r requirements.txt

ENTRYPOINT ["make", "docs"]
```

```yaml
version: "3"
services:
    documentation-builder:
        build:
            context: .
            dockerfile: Dockerfile
        volumes:
            - ./src:/var/docs
```

  [Docker Compose]: https://docs.docker.com/compose/
  [Markdown]: http://commonmark.org
  [Pandoc]: http://pandoc.org
  [PlantUML]: http://plantuml.com
  [reStructuredText]: http://docutils.sourceforge.net/rst.html
  [Sphinx]: http://www.sphinx-doc.org
