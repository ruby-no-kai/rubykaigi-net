FROM public.ecr.aws/ubuntu/ubuntu:jammy AS build

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential golang libsnmp-dev p7zip-full unzip git curl ca-certificates snmp-mibs-downloader rename

WORKDIR /build
RUN git init && \
    git remote add origin https://github.com/prometheus/snmp_exporter && \
    git fetch --depth=1 origin 4b68fe9f8155d81bdaf3e2ef018532da545aa969 && \
    git checkout FETCH_HEAD

WORKDIR /build/generator

RUN make mibs
RUN make generator
RUN download-mibs

WORKDIR /build/generator/cisco
RUN git init && \
    git remote add origin https://github.com/cisco/cisco-mibs && \
    git fetch --depth=1 origin 2d465cce2de4e67a3561d8e41e4c99b597558d4b && \
    git checkout FETCH_HEAD

RUN file-rename -- 's/\.my$//' v2/*.my

WORKDIR /build/generator/juniper
RUN curl -LO 'https://www.juniper.net/documentation/software/junos/junos194/juniper-mibs-19.4R3.11.tgz' && \
    tar xf juniper-mibs-*.tgz

RUN file-rename -- 's/\.txt$//' JuniperMibs/*.txt

FROM public.ecr.aws/ubuntu/ubuntu:jammy

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends libsnmp40 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /build/generator/generator /opt/snmp-exporter/bin/
COPY --from=build /build/generator/mibs/ /usr/share/snmp/mibs/
COPY --from=build /build/generator/cisco/v2/ /usr/share/snmp/mibs/
COPY --from=build /build/generator/juniper/JuniperMibs/ /usr/share/snmp/mibs/
COPY --from=build /usr/share/snmp/mibs/ /usr/share/snmp/mibs/
COPY --from=build /var/lib/mibs/ /var/lib/mibs/

COPY --chmod=0755 ./entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
