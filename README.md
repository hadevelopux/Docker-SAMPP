# Docker SAMPP
Una distribución de **Apache** fácil de instalar que contiene **MySQL**, **PHP** y **phpMyAdmin**, simple de descargar y ejecutar. ¡Así de fácil!

### Iniciar el contenedor
```bash
  docker compose up --build -d
```

### Vista previa
Alojamos nuestros archivos web en `www` y navegamos en la siguiente dirección `http://127.0.0.1:8000/`

### phpMyAdmin
Dirección por defecto `http://127.0.0.1:8080/`

### Credenciales por defecto
Modificables desde `.env`, todas las credenciales de **phpMyAdmin**, **MySQL** y puertos

| Service | User | Pass |
| :------ | :--- | :--- |
| **MySQL** | root | root |
| **phpMyAdmin** | root | root |

## Contenido de paquetes
| Paquete | Version |
| :----| :------ |
| Apache | **2.4.xx** |
| MySQL | **8.2.xx** |
| PHP | **8.2.xx** |
| phpMyAdmin | **5.2.x** |

## Puertos por defecto
| Service | Ports |
| :------ | :--- |
| **Apache** | 8000:80 |
| **MySQL** | 33066:3306 |
| **phpMyAdmin** | 8080:80 |
