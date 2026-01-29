FROM httpd:2.4-alpine

RUN apk update && apk add --no-cache \
    perl \
    bind-tools \
    && rm -rf /var/cache/apk/*

# Enable CGI module
RUN sed -i 's/#LoadModule cgid_module/LoadModule cgid_module/' /usr/local/apache2/conf/httpd.conf && \
    sed -i 's/#LoadModule cgi_module/LoadModule cgi_module/' /usr/local/apache2/conf/httpd.conf && \
    echo 'ScriptAlias /cgi-bin/ "/usr/local/apache2/cgi-bin/"' >> /usr/local/apache2/conf/httpd.conf && \
    echo '<Directory "/usr/local/apache2/cgi-bin">' >> /usr/local/apache2/conf/httpd.conf && \
    echo '    AllowOverride None' >> /usr/local/apache2/conf/httpd.conf && \
    echo '    Options +ExecCGI' >> /usr/local/apache2/conf/httpd.conf && \
    echo '    Require all granted' >> /usr/local/apache2/conf/httpd.conf && \
    echo '</Directory>' >> /usr/local/apache2/conf/httpd.conf && \
    echo 'DirectoryIndex index.pl index.html' >> /usr/local/apache2/conf/httpd.conf && \
    echo 'AddHandler cgi-script .pl' >> /usr/local/apache2/conf/httpd.conf

# Copy the CGI script
COPY index.pl /usr/local/apache2/cgi-bin/index.pl
RUN chmod 755 /usr/local/apache2/cgi-bin/index.pl

# Create a redirect from / to /cgi-bin/index.pl
RUN echo '<meta http-equiv="refresh" content="0;url=/cgi-bin/index.pl">' > /usr/local/apache2/htdocs/index.html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget -qO- http://127.0.0.1:80/ || exit 1
