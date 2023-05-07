FROM --platform=$BUILDPLATFORM public.ecr.aws/docker/library/golang:1.20-bullseye as builder

ENV GOOS=linux
ENV GOARCH=arm64
ENV CGO_ENABLED=0
COPY . /work/s3tftpd-healthz
WORKDIR /work/s3tftpd-healthz
RUN go build -o /healthz .

FROM gcr.io/distroless/base-debian11

COPY --from=builder /healthz /usr/local/bin/
CMD /usr/local/bin/healthz
