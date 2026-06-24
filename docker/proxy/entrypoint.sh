#!/bin/bash

# Función para limpieza de logs cada 24 horas
log_cleanup_loop() {
    while true; do
        echo "Running log cleanup (7 days policy)..."
        find /var/log/nginx -type f -mtime +7 -delete
        sleep 86400
    done
}

# Iniciar el bucle de limpieza en segundo plano
log_cleanup_loop &

# Iniciar Fail2ban en segundo plano
echo "Starting Fail2ban..."
service fail2ban start

# Iniciar Nginx en primer plano
echo "Starting Nginx with ModSecurity airween 2025..."
nginx -g "daemon off;"
