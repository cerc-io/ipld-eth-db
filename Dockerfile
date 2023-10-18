FROM golang:1.18-alpine as builder

ADD . /go/src/github.com/cerc-io/ipld-eth-db

# Get migration tool
WORKDIR /
ARG GOOSE_VER="v3.6.1"
RUN arch=$(arch | sed s/aarch64/arm64/) && \
  wget -O ./goose https://github.com/pressly/goose/releases/download/${GOOSE_VER}/goose_linux_${arch}
RUN chmod +x ./goose

# app container
FROM alpine

WORKDIR /app

COPY --from=builder /go/src/github.com/cerc-io/ipld-eth-db/scripts/startup_script.sh .

COPY --from=builder /goose goose
COPY --from=builder /go/src/github.com/cerc-io/ipld-eth-db/db/migrations migrations

ENTRYPOINT ["/app/startup_script.sh"]
