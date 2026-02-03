FROM httpd:2.4-alpine

RUN apk update && apk add --no-cache \
    perl \
    bind-tools \
    && rm -rf /var/cache/apk/*

# Enable CGI and remoteip modules
RUN sed -i 's/#LoadModule cgid_module/LoadModule cgid_module/' /usr/local/apache2/conf/httpd.conf && \
    sed -i 's/#LoadModule cgi_module/LoadModule cgi_module/' /usr/local/apache2/conf/httpd.conf && \
    sed -i 's/#LoadModule remoteip_module/LoadModule remoteip_module/' /usr/local/apache2/conf/httpd.conf && \
    sed -i 's/^Listen 80$/Listen 8080/' /usr/local/apache2/conf/httpd.conf && \
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
RUN addgroup -S app && adduser -S -G app app && \
    chown -R app:app /usr/local/apache2/logs /usr/local/apache2/htdocs /usr/local/apache2/cgi-bin /usr/local/apache2/conf
USER app

# Create a redirect from / to /cgi-bin/index.pl
RUN echo '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta http-equiv="refresh" content="0; url=/cgi-bin/index.pl"><title>Redirecting...</title></head><body><p>Redirecting to <a href="/cgi-bin/index.pl">IPv6 Test</a>...</p></body></html>' > /usr/local/apache2/htdocs/index.html

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget -qO- http://127.0.0.1:8080/ || exit 1
