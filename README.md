# Docker SAMPP

Una distribución de **Apache** fácil de instalar que contiene **MySQL**, **PHP** y **phpMyAdmin**, simple de descargar y ejecutar. ¡Así de fácil!

## Iniciar el contenedor

```bash
  docker-compose up -d
```

## Contenido de paquetes

| Paquete | Version |
| :----| :------ |
| Apache | **2.4** |
| MySQL | **8.0** |
| PHP | **8.2** |
| phpMyAdmin | **5.2** |

## Puertos por defecto

| Service | Ports |
| :------ | :--- |
| **Apache** | 8000:80 |
| **MySQL** | 33060:3306 |
| **phpMyAdmin** | 8080:80 |

## Credenciales por defecto

Modificables desde `docker-compose.yml`, los de **phpMyAdmin** desde `config.user.inc.php`

| Service | User | Pass |
| :------ | :--- | :--- |
| **MySQL** | root | root |
| **phpMyAdmin** | root | root |