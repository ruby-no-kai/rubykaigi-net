FROM public.ecr.aws/docker/library/golang:1.19-bullseye as build

RUN go install github.com/hanazuki/unbound_exporter@f275b66dd1eff4b7f225455c22cfae31fc9c95fc

###

FROM public.ecr.aws/debian/debian:bullseye-slim

RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends unbound dns-root-data dumb-init

COPY --from=build /go/bin/unbound_exporter /usr/local/bin/

RUN /usr/lib/unbound/package-helper root_trust_anchor_update
RUN rm /etc/unbound/unbound_*.key /etc/unbound/unbound_*.pem

COPY entrypoint.sh /
RUN chmod +x entrypoint.sh

ENTRYPOINT ["dumb-init", "/entrypoint.sh"]
