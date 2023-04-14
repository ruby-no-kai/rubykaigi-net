FROM public.ecr.aws/ubuntu/ubuntu:jammy as build-unbound

RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git git-buildpackage

WORKDIR /build/unbound
RUN git clone --no-single-branch -b debian/1.17.1-2 --filter=tree:0 https://salsa.debian.org/dns-team/unbound.git .
RUN apt-get build-dep -y .
RUN gbp buildpackage -b -uc -us -j"$(nproc)" --git-ignore-branch --git-no-pristine-tar

###

FROM public.ecr.aws/docker/library/golang:1.20-bullseye as build-exporter

RUN go install github.com/hanazuki/unbound_exporter@679dfa54debd24456ed458a7e72590101b560e2b

###

FROM public.ecr.aws/ubuntu/ubuntu:jammy

RUN --mount=type=bind,from=build-unbound,src=/build,dst=/build \
    apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends /build/unbound_*.deb dns-root-data dumb-init && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build-exporter /go/bin/unbound_exporter /usr/local/bin/

RUN /usr/libexec/unbound-helper root_trust_anchor_update

COPY entrypoint.sh /
RUN chmod +x entrypoint.sh

ENTRYPOINT ["dumb-init", "/entrypoint.sh"]
