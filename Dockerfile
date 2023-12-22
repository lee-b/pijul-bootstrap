FROM rust as build

ARG PIJUL_VERSION
ENV PIJUL_VERSION $PIJUL_VERSION

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y libsodium-dev libc-dev

RUN cargo install pijul --version "~1.0.0-$PIJUL_VERSION" --root /usr/local --features git
RUN strip /usr/local/bin/pijul

#######################################################

FROM debian:stable-slim as production
RUN apt-get update && apt-get upgrade -y

COPY --from=build /usr/local/bin/pijul /usr/local/bin/

RUN apt-get update && apt-get install -y libsodium23 libssl3

RUN mkdir /workspace
WORKDIR /workspace

ENTRYPOINT [ "/usr/local/bin/pijul" ]

