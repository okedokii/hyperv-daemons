FROM ghcr.io/void-linux/void-glibc-full
RUN xbps-install -Suy xbps && xbps-install -uy && xbps-install -y openssl python3
