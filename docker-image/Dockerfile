# Official Docker Hub httpd image (Apache httpd 2.4.71 on Alpine 3.24), pinned
# by its multi-arch OCI index digest so a re-pushed tag cannot change the base;
# 2.4.71-alpine and 2.4.71-alpine3.24 name the same index (checked 2026-11-13).
# The official 2.4.69 image was skipped because its mod_cgid answered 503 to
# any request header over 4096 bytes (fixed in 2.4.70, PR 70270); 2.4.71 was
# re-tested with a 5000-byte header before use. To update, resolve the new
# tag's index digest (`skopeo inspect --raw docker://httpd:<tag> | sha256sum`)
# and build under a NEW image tag (see Justfile VERSION).
FROM docker.io/library/httpd:2.4.71-alpine3.24@sha256:0dd40f744444e37271d28c0b63c4e9fe8bcb8dee6fadb1a16a851ca311a39e88

# apk upgrade pulls Alpine security fixes published after the pinned base
# image was built (it upgraded nothing on 2026-11-13, but the base digest
# stays fixed while Alpine keeps patching); the immutable image tag freezes
# the resulting package set.
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
