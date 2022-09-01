FROM fluent/fluentd:v1.15-debian-1

USER root
RUN fluent-gem install fluent-plugin-prometheus -v 2.0.3

USER fluent

EXPOSE 24231