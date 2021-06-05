FROM ghcr.io/linuxserver/baseimage-alpine:3.13

ARG DUPLICACY_VERSION=2.7.2

ENV BACKUP_SCHEDULE='@hourly'
ENV PRUNE_SCHEDULE='@daily'
ENV HC_PING_ID=''
ENV DUPLICACY_BACKUP_OPTIONS=''
ENV DUPLICACY_PRUNE_OPTIONS='-keep 60:360 -keep 30:180 -keep 7:30 -keep 2:14 -keep 1:7'

RUN apk --no-cache add ca-certificates curl && update-ca-certificates

RUN wget https://github.com/gilbertchen/duplicacy/releases/download/v${DUPLICACY_VERSION}/duplicacy_linux_x64_${DUPLICACY_VERSION} -O /usr/bin/duplicacy && \
    chmod +x /usr/bin/duplicacy

COPY root /

WORKDIR /data
VOLUME ["/data"]
