FROM alpine:latest

MAINTAINER Jérôme Foray <moi@foray-jero.me>

ENV NGINX_VERSION nginx-1.9.11
ENV NCHAN_VERSION 0.99.5
ENV HEADERS_MORE_VERSION 0.29
ENV LUA_VERSION 0.10.1rc1
ENV NDK_VERSION 0.2.19

RUN apk --update add ca-certificates libatomic_ops-dev openssl-dev pcre-dev zlib-dev luajit-dev wget build-base && \
    update-ca-certificates && \
    mkdir -p /tmp/src /var/lib/nginx /var/log/nginx && \
    cd /tmp/src && \
    wget https://github.com/slact/nchan/archive/v${NCHAN_VERSION}.tar.gz && \
    tar -zxvf v${NCHAN_VERSION}.tar.gz && \
    wget https://github.com/simpl/ngx_devel_kit/archive/v${NDK_VERSION}.tar.gz && \
    tar -zxvf v${NDK_VERSION}.tar.gz && \
    wget https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERS_MORE_VERSION}.tar.gz && \
    tar -zxvf v${HEADERS_MORE_VERSION}.tar.gz && \
    wget https://github.com/openresty/lua-nginx-module/archive/v${LUA_VERSION}.tar.gz && \
    tar -zxvf v${LUA_VERSION}.tar.gz && \
    wget http://nginx.org/download/${NGINX_VERSION}.tar.gz && \
    tar -zxvf ${NGINX_VERSION}.tar.gz && \
    cd /tmp/src/${NGINX_VERSION} && \
    ./configure \
        --with-cc-opt="-Wno-maybe-uninitialized -Wno-pointer-sign" \
        --prefix=/etc/nginx \
        --sbin-path=/usr/local/sbin/nginx \
        --pid-path=/run/nginx.pid \
        --lock-path=/run/nginx.lock \
        --with-ipv6 \
        --with-libatomic \
        --with-pcre \
        --with-pcre-jit \
        --http-client-body-temp-path=/var/lib/nginx/client_body_temp \
        --http-proxy-temp-path=/var/lib/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/lib/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/lib/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/lib/nginx/scgi_temp \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --with-select_module \
        --with-poll_module \
        --with-http_v2_module \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_gzip_static_module \
        --with-http_realip_module \
        --with-http_sub_module \
        --with-http_secure_link_module \
        --with-http_auth_request_module \
        --add-module=/tmp/src/nchan-${NCHAN_VERSION} \
        --add-module=/tmp/src/ngx_devel_kit-${NDK_VERSION} \
        --add-module=/tmp/src/lua-nginx-module-${LUA_VERSION} \
        --add-module=/tmp/src/headers-more-nginx-module-${HEADERS_MORE_VERSION} && \
    make && \
    make install && \
    apk del build-base && \
    rm -rf /tmp/src && \
    rm -rf /var/cache/apk/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
