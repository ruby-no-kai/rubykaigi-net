ARG MIBS_IMAGE=rk-snmp-exporter-config-generator

FROM $MIBS_IMAGE AS mibs

FROM public.ecr.aws/docker/library/rust:1-slim-trixie AS build

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends libsnmp-dev git ca-certificates

ARG TRAPBRIDGE_REV=a60c2437e8e8c7bd8c872d2365d26a1a6b6e959d
RUN cargo install --locked --root /opt/trapbridge --features mibs --git https://github.com/sorah/trapbridge --rev $TRAPBRIDGE_REV trapbridge

FROM public.ecr.aws/docker/library/debian:trixie-slim

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends libsnmp40t64 && \
    rm -rf /var/lib/apt/lists/*

# net-snmp announces creating these on stderr, which mib-dump counts as a parse error.
RUN mkdir -p /var/lib/snmp/cert_indexes /var/lib/snmp/mib_indexes

COPY --from=build /opt/trapbridge/bin/trapbridge /usr/local/bin/
COPY --from=mibs /usr/share/snmp/mibs/ /usr/share/snmp/mibs/
COPY --from=mibs /var/lib/mibs/ /var/lib/mibs/

# CISCO-LWAPP-AP-MIB and CISCO-LWAPP-DOT11-MIB import from each other, which net-snmp reports as a parse error.
# cldRegulatoryDomain only appears in a notification's OBJECTS, which mib-dump resolves by name anyway.
RUN sed -i -e '/^    cldRegulatoryDomain$/{N;/\n        FROM CISCO-LWAPP-DOT11-MIB$/d}' /usr/share/snmp/mibs/CISCO-LWAPP-AP-MIB && \
    ! grep -q 'FROM CISCO-LWAPP-DOT11-MIB' /usr/share/snmp/mibs/CISCO-LWAPP-AP-MIB

COPY --chmod=0755 ./entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
