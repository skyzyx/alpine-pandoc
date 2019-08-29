# https://hub.docker.com/r/portown/alpine-pandoc/~/dockerfile/
#
# We use:
# * Pandoc (Haskell) to convert all Markdown into either generated HTML or .rst files.
# * Sphinx (Python) to convert .rst files into generated HTML.
# * PlantUML (Java) to convert UML diagrams to SVG images.
#

FROM alpine:3.6

ENV BUILD_DEPS \
    alpine-sdk \
    coreutils \
    ghc \
    libffi \
    linux-headers \
    musl-dev \
    wget \
    zlib-dev
ENV PERSISTENT_DEPS \
    gmp \
    graphviz \
    openjdk8 \
    python \
    py2-pip \
    sed \
    ttf-droid \
    ttf-droid-nonlatin
ENV EDGE_DEPS cabal

ENV PLANTUML_VERSION 1.2017.18
ENV PLANTUML_DOWNLOAD_URL https://sourceforge.net/projects/plantuml/files/plantuml.$PLANTUML_VERSION.jar/download

ENV PANDOC_VERSION 2.7.3
ENV PANDOC_DOWNLOAD_URL https://hackage.haskell.org/package/pandoc-$PANDOC_VERSION/pandoc-$PANDOC_VERSION.tar.gz
ENV PANDOC_ROOT /usr/local/pandoc

ENV PATH $PATH:$PANDOC_ROOT/bin

# Create Pandoc build space
RUN mkdir -p /pandoc-build
WORKDIR /pandoc-build

# Install/Build Packages
RUN apk upgrade --update && \
    apk add --no-cache --virtual .build-deps $BUILD_DEPS && \
    apk add --no-cache --virtual .persistent-deps $PERSISTENT_DEPS && \
    curl -fsSL "$PLANTUML_DOWNLOAD_URL" -o /usr/local/plantuml.jar && \
    apk add --no-cache --virtual .edge-deps $EDGE_DEPS -X http://dl-cdn.alpinelinux.org/alpine/edge/community && \
    curl -fsSL "$PANDOC_DOWNLOAD_URL" | tar -xzf - && \
        ( cd pandoc-$PANDOC_VERSION && cabal update && cabal install --only-dependencies && \
        cabal configure --prefix=$PANDOC_ROOT && \
        cabal build && \
        cabal copy && \
        cd .. ) && \
    rm -Rf pandoc-$PANDOC_VERSION/ && \
    rm -Rf /root/.cabal/ /root/.ghc/ && \
    rmdir /pandoc-build && \
    set -x; \
    addgroup -g 82 -S www-data; \
    adduser -u 82 -D -S -G www-data www-data && \
    mkdir -p /var/docs && \
    apk del .build-deps .edge-deps

# Set to non root user
USER www-data

# Reset the work dir
WORKDIR /var/docs
