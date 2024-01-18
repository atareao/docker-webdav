FROM alpine:3.19 AS builder
RUN apk add --update \
            --no-cache \
            pcre~=8.45 \
            libxml2~=2.11 \
            libxslt~=1.1 \
            gcc~=13.2 \
            make~=4.4 \
            libc-dev~=0.7 \
            pcre-dev~=8.45 \
            zlib-dev~=1.3 \
            libxml2-dev~=2.11 \
            libxslt-dev~=1.1 && \
    cd /tmp && \
    wget -q https://github.com/nginx/nginx/archive/master.zip -O nginx.zip && \
    unzip nginx.zip && \
    cd nginx-master && \
    ./auto/configure --prefix=/opt/nginx --with-http_dav_module && \
    make && \
    make install && \
    apk del gcc make libc-dev pcre-dev zlib-dev libxml2-dev libxslt-dev && \
    rm -rf /var/cache/apk

FROM alpine:3.19

RUN apk add --update \
            --no-cache \
            pcre~=8.45 \
            libxml2~=2.11 \
            libxslt~=1.1 \
            apache2-utils~=2.4 \
            su-exec~=0.2 \
            tzdata~=2023 && \
    rm -rf /var/cache/apk && \
    mkdir /share

COPY --from=builder /opt /opt

COPY nginx.conf /opt/nginx/conf/nginx.conf
COPY entrypoint.sh /

EXPOSE 8080


ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
CMD ["/opt/nginx/sbin/nginx", "-g", "daemon off;"]

