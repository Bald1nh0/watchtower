FROM --platform=$BUILDPLATFORM alpine:3.19.0 AS alpine

RUN apk add --no-cache \
    ca-certificates \
    tzdata

FROM scratch
LABEL "com.centurylinklabs.watchtower"="true"
LABEL org.opencontainers.image.description="A process for automating Docker container base image updates."
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.source="https://github.com/Bald1nh0/watchtower"
LABEL org.opencontainers.image.title="watchtower"
LABEL org.opencontainers.image.url="https://bald1nh0.github.io/watchtower/"

COPY --from=alpine \
    /etc/ssl/certs/ca-certificates.crt \
    /etc/ssl/certs/ca-certificates.crt
COPY --from=alpine \
    /usr/share/zoneinfo \
    /usr/share/zoneinfo

EXPOSE 8080

COPY watchtower /

HEALTHCHECK CMD [ "/watchtower", "--health-check"]

ENTRYPOINT ["/watchtower"]
