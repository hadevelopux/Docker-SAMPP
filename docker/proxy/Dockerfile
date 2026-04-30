# --- Etapa 1: Compilación ---
FROM debian:12-slim AS builder

# Instalar dependencias de compilación
RUN apt-get update && apt-get install -y \
    apt-utils autoconf automake build-essential git \
    bison flex \
    libcurl4-openssl-dev libgeoip-dev liblmdb-dev \
    libpcre2-dev libtool libxml2-dev libyajl-dev \
    pkgconf wget zlib1g-dev

# 1. Compilar libmodsecurity (Fork de airween)
WORKDIR /opt
RUN git clone --depth 1 -b v3/master https://github.com/airween/ModSecurity.git && \
    cd ModSecurity && \
    git submodule update --init --recursive && \
    ./build.sh && \
    ./configure && \
    make -j$(nproc) && \
    make install

# 2. Descargar Nginx y el conector
WORKDIR /opt
RUN export NGINX_VERSION=1.27.4 && \
    wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar zxvf nginx-${NGINX_VERSION}.tar.gz && \
    git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git

# 3. Compilar el módulo dinámico para Nginx
RUN cd nginx-* && \
    ./configure --with-compat --add-dynamic-module=../ModSecurity-nginx && \
    make modules

# 4. Descargar OWASP CRS
WORKDIR /opt
RUN git clone --depth 1 https://github.com/coreruleset/coreruleset.git owasp-crs

# --- Etapa 2: Imagen Final ---
FROM nginx:1.27.4-bookworm

# Instalar dependencias de ejecución y Fail2ban
RUN apt-get update && apt-get install -y \
    libcurl4 libxml2 libyajl2 libpcre2-8-0 liblmdb0 libgeoip1 \
    fail2ban iptables \
    && rm -rf /var/lib/apt/lists/*

# Copiar binarios de ModSecurity
COPY --from=builder /usr/local/modsecurity /usr/local/modsecurity
COPY --from=builder /usr/local/lib/libmodsecurity.so* /usr/local/lib/
COPY --from=builder /opt/nginx-*/objs/ngx_http_modsecurity_module.so /usr/lib/nginx/modules/

# Configurar Nginx globalmente
RUN sed -i '1i load_module modules/ngx_http_modsecurity_module.so;' /etc/nginx/nginx.conf

# Preparar reglas ModSecurity y CRS
RUN mkdir -p /etc/nginx/modsecurity.d/owasp-crs
COPY --from=builder /opt/owasp-crs /etc/nginx/modsecurity.d/owasp-crs
COPY --from=builder /opt/ModSecurity/modsecurity.conf-recommended /etc/nginx/modsecurity.d/modsecurity.conf
COPY --from=builder /opt/ModSecurity/unicode.mapping /etc/nginx/modsecurity.d/unicode.mapping

RUN cp /etc/nginx/modsecurity.d/owasp-crs/crs-setup.conf.example /etc/nginx/modsecurity.d/owasp-crs/crs-setup.conf && \
    echo "include /etc/nginx/modsecurity.d/modsecurity.conf" > /etc/nginx/modsecurity.d/include.conf && \
    echo "include /etc/nginx/modsecurity.d/owasp-crs/crs-setup.conf" >> /etc/nginx/modsecurity.d/include.conf && \
    echo "include /etc/nginx/modsecurity.d/owasp-crs/rules/*.conf" >> /etc/nginx/modsecurity.d/include.conf

RUN sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsecurity.d/modsecurity.conf && \
    sed -i 's|SecUnicodeMapFile unicode.mapping 20127|SecUnicodeMapFile /etc/nginx/modsecurity.d/unicode.mapping 20127|' /etc/nginx/modsecurity.d/modsecurity.conf

# Configuración de Fail2ban dentro del contenedor
# Limpiamos las cárceles por defecto para evitar conflictos
RUN rm -f /etc/fail2ban/jail.d/*

# Script de entrada
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN ldconfig
EXPOSE 80 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
