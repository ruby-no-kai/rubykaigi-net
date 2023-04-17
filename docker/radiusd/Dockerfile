FROM public.ecr.aws/ubuntu/ubuntu:22.04

ARG FR_VERSION=3.0.26~dfsg~git20220223.1.00ed0241fa-0ubuntu3.1

RUN mkdir -p /etc/freeradius/3.0/certs && touch /etc/freeradius/3.0/certs/dh
RUN apt-get update && apt-get install -y --no-install-recommends --no-install-suggests \
      freeradius=${FR_VERSION} \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN rm /etc/freeradius/3.0/sites-enabled/*
COPY raddb/ /etc/freeradius/3.0/
COPY run.sh /run.sh

RUN ls -la /etc/freeradius/3.0/sites-* /etc/freeradius/3.0/mods-*

COPY --chown=freerad:freerad dummycert /secrets/tls-cert
RUN ls -la /secrets/tls-cert

USER freerad
RUN /usr/sbin/freeradius -f -Cx -lstdout

USER root
RUN rm -rf /secrets

USER freerad
EXPOSE 1812/tcp 1812/udp
EXPOSE 18121/tcp 18121/udp
CMD ["/run.sh"]
