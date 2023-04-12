FROM public.ecr.aws/docker/library/golang:1.20-bullseye as build

RUN go install github.com/hanazuki/unbound_exporter@679dfa54debd24456ed458a7e72590101b560e2b

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
