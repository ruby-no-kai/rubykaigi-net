FROM --platform=$BUILDPLATFORM public.ecr.aws/docker/library/golang:1.20-bullseye as builder

ENV GOOS=linux
ENV GOARCH=arm64
ENV CGO_ENABLED=0
RUN go install github.com/bvantagelimited/freeradius_exporter@0ba8725aa1ab59e09f4f9f2a1a229ecb66b66d56

FROM gcr.io/distroless/base-debian11

COPY --from=builder /go/bin/linux_arm64/freeradius_exporter /usr/local/bin/
CMD /usr/local/bin/freeradius_exporter
