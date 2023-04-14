FROM public.ecr.aws/docker/library/golang:1.20-bullseye as build-exporter

RUN go install github.com/hanazuki/unbound_exporter@679dfa54debd24456ed458a7e72590101b560e2b

###

FROM public.ecr.aws/docker/library/debian:bookworm

RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends unbound dns-root-data dumb-init && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build-exporter /go/bin/unbound_exporter /usr/local/bin/

RUN /usr/libexec/unbound-helper root_trust_anchor_update

COPY entrypoint.sh /
RUN chmod +x entrypoint.sh

ENTRYPOINT ["dumb-init", "/entrypoint.sh"]
