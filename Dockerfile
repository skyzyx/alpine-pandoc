# https://hub.docker.com/r/portown/alpine-pandoc/~/dockerfile/
#
# We use:
# * Pandoc (Haskell) to convert all Markdown into either generated HTML or .rst files.
# * Sphinx (Python) to convert .rst files into generated HTML.
# * PlantUML (Java) to convert UML diagrams to SVG images.
#

FROM alpine:3.10

ENV BUILD_DEPS \
    alpine-sdk \
    cabal \
    coreutils \
    ghc \
    libffi \
    musl-dev \
    zlib-dev
ENV PERSISTENT_DEPS \
    gmp \
    graphviz \
    openjdk11-jre \
    python \
    py2-pip \
    sed \
    ttf-droid \
    ttf-droid-nonlatin

ENV PLANTUML_VERSION 1.2019.8
ENV PLANTUML_DOWNLOAD_URL https://sourceforge.net/projects/plantuml/files/plantuml.$PLANTUML_VERSION.jar/download

ENV PANDOC_VERSION 2.7.3
ENV PANDOC_DOWNLOAD_URL https://hackage.haskell.org/package/pandoc-$PANDOC_VERSION/pandoc-$PANDOC_VERSION.tar.gz
ENV PANDOC_ROOT /usr/local/pandoc

ENV PATH $PATH:$PANDOC_ROOT/bin

# Install/Build Packages
RUN apk upgrade --update && \
    apk add --virtual .build-deps $BUILD_DEPS && \
    apk add --virtual .persistent-deps $PERSISTENT_DEPS && \
    curl -fsSL "$PLANTUML_DOWNLOAD_URL" -o /usr/local/plantuml.jar && \
    chmod a+r /usr/local/plantuml.jar && \
    mkdir -p /pandoc-build \
             /var/docs && \
    cd /pandoc-build && \
    curl -fsSL "$PANDOC_DOWNLOAD_URL" | tar -xzf - && \
    cd pandoc-$PANDOC_VERSION && \
    cabal update && \
    cabal install --only-dependencies && \
    cabal configure --prefix=$PANDOC_ROOT && \
    cabal build && \
    cabal copy && \
    cd / && \
    rm -Rf /pandoc-build \
           /root/.cabal \
           /root/.ghc && \
    set -x && \
    addgroup -g 82 -S pandoc && \
    adduser -u 82 -D -S -G pandoc pandoc && \
    apk del .build-deps

# Set to non root user
USER pandoc

# Reset the work dir
WORKDIR /var/docs
