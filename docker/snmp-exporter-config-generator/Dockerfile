FROM ubuntu:jammy AS build

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential golang libsnmp-dev p7zip-full unzip git curl ca-certificates snmp-mibs-downloader

WORKDIR /build
RUN git init && \
    git remote add origin https://github.com/prometheus/snmp_exporter && \
    git fetch origin 58b902ede4f6bee7a150566ac7fae05ef0a4b1fb && \
    git checkout FETCH_HEAD

WORKDIR /build/generator

RUN make mibs
RUN make generator
RUN download-mibs

FROM ubuntu:jammy

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends libsnmp40 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /build/generator/generator /opt/snmp-exporter/bin/
COPY --from=build /build/generator/mibs/ /usr/share/snmp/mibs/
COPY --from=build /usr/share/snmp/mibs/ /usr/share/snmp/mibs/
COPY --from=build /var/lib/mibs/ /var/lib/mibs/

COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
