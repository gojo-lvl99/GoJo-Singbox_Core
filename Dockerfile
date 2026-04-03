# ── Stage 1: Alpine (build-only — hindi kasama sa final image)
FROM alpine:3.19 AS downloader

RUN apk add --no-cache wget ca-certificates \
    && LATEST=$(wget -qO- "https://api.github.com/repos/SagerNet/sing-box/releases/latest" \
               | grep '"tag_name"' | cut -d'"' -f4) \
    && VER=${LATEST#v} \
    && wget -q "https://github.com/SagerNet/sing-box/releases/download/${LATEST}/sing-box-${VER}-linux-amd64.tar.gz" \
    && tar xzf "sing-box-${VER}-linux-amd64.tar.gz" \
    && mv "sing-box-${VER}-linux-amd64/sing-box" /sing-box \
    && chmod +x /sing-box

# ── Stage 2: Distroless (Google-maintained, walang shell, walang package manager)
FROM gcr.io/distroless/base-debian12

COPY --from=downloader /sing-box /sing-box
COPY --from=downloader /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY config.json /etc/sing-box/config.json

EXPOSE 8080

ENTRYPOINT ["/sing-box", "run", "-c", "/etc/sing-box/config.json"]
