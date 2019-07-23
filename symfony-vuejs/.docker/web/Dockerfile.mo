FROM httpd:2.4.39
LABEL maintainer="Rémi Alvergnat <remi.alvergnat@gfi.fr>"
{{#DOCKER_DEVBOX_COPY_CA_CERTIFICATES}}

COPY .ca-certificates/* /usr/local/share/ca-certificates/
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/* \
&& update-ca-certificates
{{/DOCKER_DEVBOX_COPY_CA_CERTIFICATES}}

RUN mkdir -p /usr/local/apache2/conf/custom \
&& mkdir -p /var/www/html \
&& sed -i '/LoadModule proxy_module/s/^#//g' /usr/local/apache2/conf/httpd.conf \
&& sed -i '/LoadModule proxy_fcgi_module/s/^#//g' /usr/local/apache2/conf/httpd.conf \
&& echo >> /usr/local/apache2/conf/httpd.conf && echo 'IncludeOptional conf/custom/*.conf' >> /usr/local/apache2/conf/httpd.conf

RUN sed -i '/LoadModule proxy_module/s/^#//g' /usr/local/apache2/conf/httpd.conf

RUN sed -i '/LoadModule rewrite_module/s/^#//g' /usr/local/apache2/conf/httpd.conf
