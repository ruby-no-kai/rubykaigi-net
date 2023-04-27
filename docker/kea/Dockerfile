# syntax=docker/dockerfile:1

ARG BASE=public.ecr.aws/ubuntu/ubuntu:22.04

# `~` is mangled as `.`
ARG KEA_VERSION=2.3.6-1.rk1.jammy

###

FROM --platform=$BUILDPLATFORM public.ecr.aws/docker/library/rust:1.69-slim-bullseye as build-healthz
RUN rustup target add aarch64-unknown-linux-gnu
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      gcc-aarch64-linux-gnu

WORKDIR /build/healthz
COPY healthz/ ./

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/build/healthz/target \
    CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc \
    cargo install --path . --root /app --locked --target=aarch64-unknown-linux-gnu

###

FROM --platform=$BUILDPLATFORM $BASE as build-stork

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git rake build-essential wget unzip

WORKDIR /build
RUN git clone --depth=1 https://gitlab.isc.org/isc-projects/stork -b v1.10.0

WORKDIR /build/stork/backend
ENV GOPATH=/build/go

RUN --mount=type=cache,dst=/build/stork/tools \
    rake build:agent

ENV GOOS=linux
ENV GOARCH=arm64
ENV CGO_ENABLED=0

RUN --mount=type=cache,dst=/build/stork/tools \
    ../tools/golang/go/bin/go install ./cmd/stork-agent

###

FROM --platform=$BUILDPLATFORM $BASE as config
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y jsonnet
WORKDIR /app
COPY kea-ctrl-agent.jsonnet /tmp/
RUN jsonnet /tmp/kea-ctrl-agent.jsonnet > /app/kea-ctrl-agent.json

###

FROM --platform=$BUILDPLATFORM $BASE as download

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      curl \
      ca-certificates

ARG KEA_VERSION

WORKDIR /download
RUN curl -SsfL --remote-name-all \
    https://github.com/hanazuki/isc-kea.deb/releases/download/debian%2F2.3.6-1_rk1_jammy/{kea-admin_${KEA_VERSION}_arm64.deb,kea-common_${KEA_VERSION}_arm64.deb,kea-ctrl-agent_${KEA_VERSION}_arm64.deb,kea-dhcp4-server_${KEA_VERSION}_arm64.deb}

RUN sha384sum -c --strict <<EOF
3da15d37c3edbaf670400c4221a7d116ebc306c4c573d3f3a6b8ace2ec1fb3782194b118c37a803b6696aa0340f45b17  kea-admin_2.3.6-1.rk1.jammy_arm64.deb
8d4fadc507ce3a98199dceefd71f2da689cab40aa97753bdfb0f2facff0f5c734b968d86809c666dea5f01ec35eb04ac  kea-common_2.3.6-1.rk1.jammy_arm64.deb
a735a6e6102defd5fadb20900fb92bbd769368c5c211be3f0f0e9ccab29d2d6e69ad65dd46fed22a016ed0b5a2e74c90  kea-ctrl-agent_2.3.6-1.rk1.jammy_arm64.deb
525e1ba2c96929ce32385d4c240a43ce7c4daf96023810d167b9204ba680517e8557896d40ab1d387de996fce7a84e68  kea-dhcp4-server_2.3.6-1.rk1.jammy_arm64.deb
EOF

###

FROM $BASE

RUN mkdir -p /run/kea /app
VOLUME /run/kea

ARG KEA_VERSION

RUN --mount=type=bind,from=download,src=/download,dst=/download \
    apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      ca-certificates \
      dumb-init \
      ruby3.0 \
      iproute2 \
      /download/*.deb \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=build-healthz /app/bin/healthz /app/healthzd
COPY --from=build-stork /build/go/bin/linux_arm64/stork-agent /app/stork-agent
COPY run.sh /app/run.sh
COPY choose_dhcp_server_id.rb /app/choose_dhcp_server_id.rb
COPY --from=config /app/kea-ctrl-agent.json /app/kea-ctrl-agent.json

RUN kea-ctrl-agent -t /app/kea-ctrl-agent.json

CMD /app/run.sh
