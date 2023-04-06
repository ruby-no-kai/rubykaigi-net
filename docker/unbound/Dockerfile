FROM public.ecr.aws/docker/library/golang:1.20-bullseye as build

RUN go install github.com/hanazuki/unbound_exporter@3cf4ae0d9684285dc49d6a2f31a0a0078601c6a0

###

FROM public.ecr.aws/ubuntu/ubuntu:jammy

RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends unbound dns-root-data dumb-init

COPY --from=build /go/bin/unbound_exporter /usr/local/bin/

RUN /usr/lib/unbound/package-helper root_trust_anchor_update
RUN rm /etc/unbound/unbound_*.key /etc/unbound/unbound_*.pem

COPY entrypoint.sh /
RUN chmod +x entrypoint.sh

ENTRYPOINT ["dumb-init", "/entrypoint.sh"]
