# 🏗️ Arquitectura y Documentación de Docker-SAMPP

Este documento explica detalladamente el funcionamiento y la estructura de la infraestructura basada en Docker para el proyecto **Docker-SAMPP**.

---

## 📂 Estructura de Directorios

La carpeta `docker/` contiene la lógica de aprovisionamiento, configuración y seguridad de cada servicio.

### 1. 🛡️ `docker/proxy/` (El Guardián)
Este es el componente más complejo y vital. Actúa como un **Proxy Inverso**, **WAF (Web Application Firewall)** e **IPS (Intrusion Prevention System)**.

*   **`Dockerfile`**: Realiza una compilación multi-etapa.
    *   Compila `libmodsecurity` (fork de **airween**) desde la fuente para máxima estabilidad.
    *   Compila el conector de Nginx para ModSecurity.
    *   Integra las reglas **OWASP CRS v4** para bloquear ataques comunes (SQLi, XSS, etc.).
*   **`nginx.conf`**: Configura Nginx para actuar como puerta de enlace, gestionando el tráfico SSL (443) y redirigiéndolo internamente a los servicios correspondientes.
*   **`entrypoint.sh`**: Script que inicia Fail2ban y Nginx, además de ejecutar un bucle de limpieza de logs cada 24 horas (retención de 7 días).
*   **`fail2ban/`**: Configuración del sistema de baneo.
    *   `jail.local`: Define las "cárceles" activas (Nginx, WordPress, Vaultwarden, etc.).
    *   `filter.d/`: Filtros de búsqueda (regex) que detectan patrones maliciosos en los logs.

### 2. 🚀 `docker/php/` (La Cápsula Universal)
Contiene el entorno de ejecución para las aplicaciones web.

*   **`Dockerfile`**: Basado en una imagen de PHP con Apache. Instala extensiones críticas como `gd`, `zip`, `intl`, `pdo_mysql` y activa el módulo `rewrite`.
*   **`php.ini`**: Configuraciones de rendimiento y límites (memoria, tamaño de subida) que se pueden sobreescribir mediante variables de entorno en el `.env`.
*   **`remoteip.conf`**: Configura Apache para que reconozca la IP real del cliente enviada por el Proxy (vía `X-Forwarded-For`), evitando que todos los usuarios parezcan venir de la IP interna del proxy.

### 3. 🗄️ `docker/mariadb/` (Base de Datos)
Configuración endurecida para MariaDB 11.8.

*   **`ssl.cnf`**: Configura el servidor de base de datos para requerir o soportar conexiones cifradas SSL/TLS.
*   **`mariadb_data/`**: (Ubicado en la raíz) Es el volumen donde se almacenan físicamente los datos para que no se pierdan al reiniciar contenedores.

### 4. 💎 `docker/phpmyadmin/` (Gestión de BD)
*   **`config.user.inc.php`**: Personalizaciones para la interfaz de phpMyAdmin.
*   **`phpmyadmin.sql`**: Script de inicialización automática que crea las tablas necesarias para las funciones avanzadas de phpMyAdmin en el primer arranque.

### 5. 🔑 `docker/certs/` (Seguridad SSL)
Este directorio centraliza los certificados y llaves privadas.
*   `SAMPP.key` y `SAMPP.crt`: Certificados (pueden ser auto-firmados para desarrollo o reales para producción).
*   Se comparten entre el Proxy (para HTTPS) y MariaDB (para conexiones de datos seguras).

---

## 🔄 Flujos de Operación Críticos

### 🛡️ Sinergia WAF + IPS (Detección y Baneo)
1.  Un atacante intenta un **SQL Injection**.
2.  **ModSecurity** (dentro del Proxy) detecta el patrón y bloquea la petición (403 Forbidden), escribiendo el evento en el log de errores de Nginx.
3.  **Fail2ban** monitorea ese log constantemente. Al detectar X intentos bloqueados por el WAF desde la misma IP, ejecuta una regla de **iptables** dentro del contenedor para banear esa IP por 7 días.

### 🔐 Ciclo de Vida SSL con `setup-ssl.sh`
El script `setup-ssl.sh` en la raíz del proyecto automatiza todo:
1.  Detiene temporalmente el Proxy (si es necesario) o usa el modo standalone de Certbot.
2.  Obtiene los certificados reales de **Let's Encrypt**.
3.  Los coloca en `docker/certs/`.
4.  Reinicia los servicios para aplicar los nuevos certificados.

---

## 🌐 Red Interna (`sampp_network`)
Todos los contenedores están en una red privada tipo **bridge**.
*   **Aislamiento**: Solo el Proxy expone puertos al mundo exterior (80, 443).
*   **Comunicación**: Los contenedores se hablan entre sí usando sus nombres de servicio (ej: `sampp_www` contacta a `sampp_mysql` en el puerto 3306 internamente).

---

> [!TIP]
> **Mantenimiento**: Para ver qué está pasando en tiempo real, puedes usar `docker compose logs -f sampp_proxy`.
