# Gestión de inventario

Sistema de gestión de inventario implementado en PostgreSQL.

Este proyecto contiene scripts organizados para la creación de estructura de base de datos, inserción de datos
iniciales, definición de funciones, triggers, y pruebas automatizadas para un sistema de control de inventario.

---

## 📦 Estructura del Proyecto

```
Inventory-management/
│
├── constraints/              # Restricciones (PK, FK, UK)
│   ├── fk.sql
│   ├── pk.sql
│   └── uk.sql
│
├── data/                     # Scripts de carga de datos iniciales
│   ├── categories.sql
│   ├── countries.sql
│   ├── departments.sql
│   ├── movements.sql
│   ├── movements_types.sql
│   ├── municipalities.sql
│   ├── products.sql
│   ├── products_types.sql
│   ├── users.sql
│   ├── warehouses.sql
│   ├── warehouses_statuses.sql
│   └── warehouses_stocks.sql
│
├── functions/
│   ├── get_inventory_report.sql
│   ├── register_movement.sql
│   │
│   ├── sources/
│   │   ├── register_log_entry.sql
│   │   ├── register_log_output.sql
│   │   └── trigger_update_stock_after_movement.sql
│   │
│   └── test/
│       ├── test_get_inventory_report.sql
│       └── test_register_movement.sql
│
├── all.bat                   # Script para ejecutar toda la configuración automáticamente
├── script.sql                # Script principal alternativo
└── README.md                 # Documentación del proyecto
```

---

## 🛠️ Requisitos

- PostgreSQL (recomendado: versión 14 o superior)
- Cliente `psql` configurado en tu terminal
- Sistema operativo Windows (para ejecutar el `.bat`)

---

## ⚙️ Instalación

### 1. Crear la base de datos

Primero, crea la base de datos `inventory` en tu servidor PostgreSQL:

```sql
CREATE DATABASE inventory;
```

### 2. Cambiar la contraseña del usuario postgres en el archivo all.bat

En el archivo all.bat hay una línea llamada set PGPASSWORD, al ubicarla colocar la contraseña del usuario postgres
después del igual:

```bash
set PGPASSWORD=<tu_contraseña>
```

### 3. Ejecutar los scripts automáticamente

Desde una terminal en Windows, navega hasta la carpeta raíz del proyecto y ejecuta:

```bash
.\all.bat
```

Este script cargará en orden:

- La estructura de tablas
- Las restricciones (PK, FK, UK)
- Los datos iniciales
- Los triggers y pruebas
- Las funciones PL/pgSQL

---

