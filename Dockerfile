FROM alpine:3.20 AS builder
RUN apk add --update \
            --no-cache \
            git~=2.45 \
            pcre~=8.45 \
            libxml2~=2.12 \
            libxslt~=1.1 \
            gcc~=13.2 \
            make~=4.4 \
            musl-dev~=1.2 \
            pcre-dev~=8.45 \
            zlib-dev~=1.3 \
            libxml2-dev~=2.12 \
            libxslt-dev~=1.1 && \
    cd /tmp && \
    git clone https://github.com/arut/nginx-dav-ext-module.git && \
    git clone https://github.com/aperezdc/ngx-fancyindex.git && \
    git clone https://github.com/openresty/headers-more-nginx-module.git && \
    wget -q https://github.com/nginx/nginx/archive/master.zip -O nginx.zip && \
    unzip nginx.zip && \
    cd nginx-master && \
    ./auto/configure --prefix=/opt/nginx \
                     --with-http_dav_module \
                     --add-module=/tmp/nginx-dav-ext-module \
                     --add-module=/tmp/ngx-fancyindex \
                     --add-module=/tmp/headers-more-nginx-module && \
    make modules && \
    make && \
    make install && \
    apk del gcc make libc-dev pcre-dev zlib-dev libxml2-dev libxslt-dev && \
    rm -rf /var/cache/apk

FROM alpine:3.20

RUN apk add --update \
            --no-cache \
            pcre~=8.45 \
            libxml2~=2.12 \
            libxslt~=1.1 \
            apache2-utils~=2.4 \
            tzdata~=2024 && \
    rm -rf /var/cache/apk && \
    mkdir /share

COPY --from=builder /opt /opt
COPY nginx.conf /opt/nginx/conf/nginx.conf
COPY ./html /opt/nginx/html/

# Create the user
ENV USERNAME=dockerus \
    UID=1000

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/${USERNAME}" \
    --shell "/sbin/nologin" \
    --uid "${UID}" \
    "$USERNAME" && \
    chown -R "${USERNAME}:${USERNAME}" /opt /share

EXPOSE 8080
USER "$USERNAME"

CMD ["/opt/nginx/sbin/nginx", "-g", "daemon off;"]
