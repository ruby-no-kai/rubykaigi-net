FROM public.ecr.aws/ubuntu/ubuntu:22.04 as config
RUN apt-get update && apt-get install -y jsonnet
WORKDIR /app
COPY kea-ctrl-agent.jsonnet /tmp/
RUN jsonnet /tmp/kea-ctrl-agent.jsonnet > /app/kea-ctrl-agent.json

FROM public.ecr.aws/ubuntu/ubuntu:22.04

RUN mkdir -p /run/kea /app
VOLUME /run/kea

RUN apt-get update && apt-get install -y \
      ca-certificates \
      dumb-init \
      ruby3.0 \
      iproute2 \
      curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ARG KEA_VERSION=2.0.2-1
RUN apt-get update && apt-get install -y --no-install-recommends \
      kea-dhcp4-server=${KEA_VERSION} \
      kea-admin=${KEA_VERSION} \
      kea-ctrl-agent=${KEA_VERSION} \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -Ssf -o /tmp/stork.deb 'https://sorah-pkg.s3.dualstack.ap-northeast-1.amazonaws.com/misc/isc-stork-agent_1.5.0.220824140136_arm64.deb' \
 && ( echo '1e8b67f2afe4404ea3091cbef14e93a23186633a3d571f9cb141d162350d2fe6235d7679e89bed5c2235433f203d706d /tmp/stork.deb' | sha384sum -c --strict ) \
 && dpkg -i /tmp/stork.deb && rm /tmp/stork.deb
COPY healthz/target/aarch64-unknown-linux-gnu/release/healthz /app/healthzd

COPY run.sh /app/run.sh
COPY choose_dhcp_server_id.rb /app/choose_dhcp_server_id.rb
COPY --from=config /app/kea-ctrl-agent.json /app/kea-ctrl-agent.json

RUN kea-ctrl-agent -t /app/kea-ctrl-agent.json 

CMD /app/run.sh
