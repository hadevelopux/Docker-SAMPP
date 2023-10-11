# Docker SAMPP
Una distribución de **Apache** fácil de instalar que contiene **MySQL**, **PHP** y **phpMyAdmin**, simple de descargar y ejecutar. ¡Así de fácil!

### Iniciar el contenedor
```bash
  docker-compose up -d
```

### Vista previa
Alojamos nuestros archivos web en `htdocs` y navegamos en la siguiente dirección `http://127.0.0.1:8000/`.

### phpMyAdmin
Dirección por defecto `http://127.0.0.1:8080/`.

## Contenido de paquetes
| Paquete | Version |
| :----| :------ |
| Apache | **2.4.56** |
| MySQL | **8.0.33** |
| PHP | **8.1.19** |
| phpMyAdmin | **5.2.1** |

## Puertos por defecto
| Service | Ports |
| :------ | :--- |
| **Apache** | 8000:80 |
| **MySQL** | 3306:3306 |
| **phpMyAdmin** | 8080:80 |

## Credenciales por defecto
Modificables desde `docker-compose.yml`, los de **phpMyAdmin** desde `config.user.inc.php`

| Service | User | Pass |
| :------ | :--- | :--- |
| **MySQL** | root | root |
| **phpMyAdmin** | root | root |
