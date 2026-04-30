#!/bin/bash

# Cargar variables de entorno
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

if [ "$DOMAIN" == "localhost" ] || [ -z "$DOMAIN" ]; then
    echo "Error: Debes configurar un DOMINIO real en el archivo .env (actualmente es localhost)"
    exit 1
fi

if [ -z "$SSL_EMAIL" ]; then
    echo "Error: Debes configurar SSL_EMAIL en el archivo .env"
    exit 1
fi

echo "--- Iniciando proceso de Let's Encrypt para: $DOMAIN ---"

# 1. Detener el proxy para liberar el puerto 80
echo "Deteniendo proxy temporalmente..."
docker compose stop sampp_proxy

# 2. Obtener certificado usando Certbot en modo standalone
echo "Solicitando certificado a Let's Encrypt..."
docker run --rm -it --name certbot \
    -v "$(pwd)/docker/certs/letsencrypt:/etc/letsencrypt" \
    -v "$(pwd)/docker/certs/letsencrypt/lib:/var/lib/letsencrypt" \
    -p 80:80 \
    certbot/certbot certonly --standalone \
    -d $DOMAIN --non-interactive --agree-tos --email $SSL_EMAIL

# 3. Verificar si se creó el certificado y vincularlo
if [ -f "docker/certs/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "Certificado obtenido con éxito."
    
    # Hacer backup de los antiguos si existen
    mv docker/certs/SAMPP.crt docker/certs/SAMPP.crt.bak 2>/dev/null
    mv docker/certs/SAMPP.key docker/certs/SAMPP.key.bak 2>/dev/null

    # Crear enlaces simbólicos o copiar
    cp docker/certs/letsencrypt/live/$DOMAIN/fullchain.pem docker/certs/SAMPP.crt
    cp docker/certs/letsencrypt/live/$DOMAIN/privkey.pem docker/certs/SAMPP.key
    
    echo "Certificados instalados en docker/certs/ como SAMPP.crt/key"
else
    echo "Error: No se pudo obtener el certificado."
fi

# 4. Iniciar el proxy de nuevo
echo "Reiniciando proxy..."
docker compose start sampp_proxy

echo "--- Proceso finalizado ---"
