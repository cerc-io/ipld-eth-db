FROM golang:1.16-alpine as builder

RUN apk --update --no-cache add make git g++ linux-headers

ADD . /go/src/github.com/vulcanize/ipld-eth-db

# Build migration tool
WORKDIR /go/src/github.com/pressly
RUN git clone https://github.com/pressly/goose.git
WORKDIR /go/src/github.com/pressly/goose/cmd/goose
RUN GCO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-extldflags "-static"' -tags='no_sqlite3' -o goose .

# app container
FROM alpine

WORKDIR /app

COPY --from=builder /go/src/github.com/vulcanize/ipld-eth-db/scripts/startup_script.sh .

COPY --from=builder /go/src/github.com/pressly/goose/cmd/goose/goose goose
COPY --from=builder /go/src/github.com/vulcanize/ipld-eth-db/db/migrations migrations/vulcanizedb

ENTRYPOINT ["/app/startup_script.sh"]
