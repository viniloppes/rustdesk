FROM debian:bookworm-slim AS upstream
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*
RUN curl --fail --show-error --silent --location --retry 3 \
      https://github.com/rustdesk/rustdesk/releases/download/1.5.1/rustdesk-1.5.1-x86_64.exe \
      --output /rustdesk.exe \
    && echo "319206042390ebfcba934cf0baa2f612f34de463c78c843b7cb8c22097c4bf7b  /rustdesk.exe" | sha256sum --check

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends curl nginx-light nsis \
    && rm -rf /var/lib/apt/lists/* /etc/nginx/sites-enabled/default
WORKDIR /app
COPY --from=upstream /rustdesk.exe /app/rustdesk.exe
COPY launcher.nsi start-download.sh /app/
ENTRYPOINT ["/bin/sh", "/app/start-download.sh"]
