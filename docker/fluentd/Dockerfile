FROM fluent/fluentd:v1.15-debian-1

USER root
RUN fluent-gem install fluent-plugin-prometheus -v 2.0.3 && \
    fluent-gem install fluent-plugin-s3 -v 1.7.1
