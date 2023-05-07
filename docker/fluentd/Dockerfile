# buildtrigger: 1
FROM fluent/fluentd:v1.16-debian-1

USER root
RUN fluent-gem install fluent-plugin-prometheus -v 2.0.3 && \
    fluent-gem install fluent-plugin-s3 -v 1.7.2 && \
    fluent-gem install fluent-plugin-cloudwatch-logs -v 0.14.3
