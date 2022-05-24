FROM golang:1.18-buster AS builder
ENV CGO_ENABLED=0
ARG COMPILE_FLAGS
COPY go.mod /root/rp-indexer/go.mod
COPY go.sum /root/rp-indexer/go.sum
RUN go mod download
WORKDIR /root/rp-indexer
COPY . /root/rp-indexer
RUN go build -ldflags "${COMPILE_FLAGS}" -o rp-indexer ./cmd/rp-indexer

FROM debian:buster AS rp-indexer
RUN adduser --uid 1000 --disabled-password --gecos '' --home /srv/rp-indexer rp-indexer
RUN apt-get -yq update \
        && DEBIAN_FRONTEND=noninteractive apt-get install -y \
                unattended-upgrades \
        && rm -rf /var/lib/apt/lists/* \
        && apt-get clean
COPY --from=builder /root/rp-indexer/rp-indexer /usr/bin/
USER rp-indexer
ENTRYPOINT ["rp-indexer"]
