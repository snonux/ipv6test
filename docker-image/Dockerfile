# Apache httpd 2.4.70 base, built by `just base` from the official
# docker-library/httpd Dockerfile at a pinned commit (it verifies the Apache
# tarball SHA-256 and GPG signature). The official Docker Hub image newest at
# 2026-11-08 is httpd:2.4.69-alpine3.24, whose mod_cgid answers 503 to any
# request header over 4096 bytes (fixed in 2.4.70, PR 70270). Once an official
# httpd:2.4.70-alpine (or newer) image is published, switch back to
# FROM httpd:<version>-alpine<release>@sha256:<index digest>. Always build
# under a NEW image tag (see Justfile VERSION).
ARG HTTPD_BASE
FROM ${HTTPD_BASE}

# apk upgrade pulls Alpine security fixes published after the base image was
# built (e.g. zlib 1.4-r0 for CVE-2026-4738 on 2026-11-06); the immutable
# image tag freezes the resulting package set.
RUN apk upgrade --no-cache && apk add --no-cache \
    perl \
    bind-tools

# Enable CGI and remoteip modules, configure for non-root
RUN sed -i 's/#LoadModule cgid_module/LoadModule cgid_module/' /usr/local/apache2/conf/httpd.conf && \
    sed -i 's/#LoadModule cgi_module/LoadModule cgi_module/' /usr/local/apache2/conf/httpd.conf && \
    sed -i 's/#LoadModule remoteip_module/LoadModule remoteip_module/' /usr/local/apache2/conf/httpd.conf && \
    sed -i 's/^User .*/User app/' /usr/local/apache2/conf/httpd.conf && \
    sed -i 's/^Group .*/Group app/' /usr/local/apache2/conf/httpd.conf && \
    sed -i 's/^Listen 80$/Listen 8080/' /usr/local/apache2/conf/httpd.conf && \
    sed -i 's|^ErrorLog .*|ErrorLog /var/log/apache2/error.log|' /usr/local/apache2/conf/httpd.conf && \
    sed -i 's|^CustomLog .*|CustomLog /var/log/apache2/access.log combined|' /usr/local/apache2/conf/httpd.conf && \
    # Add PidFile directive right after ServerRoot (must be early in config)
    sed -i '/^ServerRoot/a PidFile "/var/run/apache2/httpd.pid"' /usr/local/apache2/conf/httpd.conf && \
    # Configure cgid ScriptSock right after the module is loaded
    sed -i '/#Scriptsock cgisock/c\    Scriptsock /var/run/apache2/cgisock' /usr/local/apache2/conf/httpd.conf && \
    echo 'ScriptAlias /cgi-bin/ "/usr/local/apache2/cgi-bin/"' >> /usr/local/apache2/conf/httpd.conf && \
    echo '<Directory "/usr/local/apache2/cgi-bin">' >> /usr/local/apache2/conf/httpd.conf && \
    echo '    AllowOverride None' >> /usr/local/apache2/conf/httpd.conf && \
    echo '    Options +ExecCGI' >> /usr/local/apache2/conf/httpd.conf && \
    echo '    Require all granted' >> /usr/local/apache2/conf/httpd.conf && \
    echo '</Directory>' >> /usr/local/apache2/conf/httpd.conf && \
    echo 'DirectoryIndex index.pl index.html' >> /usr/local/apache2/conf/httpd.conf && \
    echo 'AddHandler cgi-script .pl' >> /usr/local/apache2/conf/httpd.conf && \
    echo 'RemoteIPHeader X-Forwarded-For' >> /usr/local/apache2/conf/httpd.conf && \
    echo 'RemoteIPInternalProxy 10.0.0.0/8' >> /usr/local/apache2/conf/httpd.conf && \
    echo 'RemoteIPInternalProxy 192.168.0.0/16' >> /usr/local/apache2/conf/httpd.conf && \
    echo 'RemoteIPInternalProxy 172.16.0.0/12' >> /usr/local/apache2/conf/httpd.conf

# Copy the CGI script
COPY index.pl /usr/local/apache2/cgi-bin/index.pl
RUN chmod 755 /usr/local/apache2/cgi-bin/index.pl

# Run as non-root
RUN addgroup -S -g 1000 app && adduser -S -D -H -u 1000 -G app app && \
    chown -R app:app /usr/local/apache2/htdocs /usr/local/apache2/cgi-bin /usr/local/apache2/conf /usr/local/apache2/logs && \
    mkdir -p /var/run/apache2 /var/log/apache2 && \
    chown -R app:app /var/run/apache2 /var/log/apache2
USER app

# Create a redirect from / to /cgi-bin/index.pl
RUN echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta http-equiv="refresh" content="0; url=/cgi-bin/index.pl"><title>Redirecting...</title></head><body><p>Redirecting to <a href="/cgi-bin/index.pl">IPv6 Test</a>...</p></body></html>' > /usr/local/apache2/htdocs/index.html

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget -qO- http://127.0.0.1:8080/ || exit 1
