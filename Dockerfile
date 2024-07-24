FROM alpine as builder

# Get migration tool
WORKDIR /
ARG GOOSE_VERSION="v3.6.1"
RUN arch=$(arch | sed s/aarch64/arm64/) && \
  wget -O ./goose https://github.com/pressly/goose/releases/download/${GOOSE_VERSION}/goose_linux_${arch}
RUN chmod +x ./goose

# app container
FROM alpine

WORKDIR /app

COPY --from=builder /goose goose
ADD scripts/startup_script.sh .
ADD db/migrations migrations

ENTRYPOINT ["/app/startup_script.sh"]
