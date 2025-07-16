# 📘 Estructura de Base de Datos — NETHIVE (Esquema: `nethive`)

---

## 🏢 `empresa`

| Columna         | Tipo de dato   | Descripción                       |
|-----------------|----------------|-----------------------------------|
| id              | UUID           | PRIMARY KEY                       |
| nombre          | TEXT           | Nombre de la empresa              |
| rfc             | TEXT           | Registro fiscal                   |
| direccion       | TEXT           | Dirección                         |
| telefono        | TEXT           | Teléfono de contacto              |
| email           | TEXT           | Correo electrónico                |
| fecha_creacion  | TIMESTAMP      | Fecha de creación (default: now) |
| logo_url        | TEXT           | URL del logo                     |
| imagen_url      | TEXT           | URL de imagen principal          |

---

## 🏪 `negocio`

| Columna         | Tipo de dato   | Descripción                       |
|-----------------|----------------|-----------------------------------|
| id              | UUID           | PRIMARY KEY                       |
| empresa_id      | UUID           | FK → empresa.id                   |
| nombre          | TEXT           | Nombre del negocio                |
| direccion       | TEXT           | Dirección                         |
| latitud         | DECIMAL(9,6)   | Latitud geográfica                |
| longitud        | DECIMAL(9,6)   | Longitud geográfica               |
| tipo_local      | TEXT           | Tipo de local (Sucursal, etc.)    |
| fecha_creacion  | TIMESTAMP      | Default: now()                    |
| logo_url        | TEXT           | Logo del negocio                  |
| imagen_url      | TEXT           | Imagen del negocio                |

---

## 🧾 `categoria_componente`

| Columna | Tipo de dato | Descripción             |
|---------|--------------|--------------------------|
| id      | SERIAL       | PRIMARY KEY              |
| nombre  | TEXT         | Nombre único de categoría|

---

## 📦 `componente`

| Columna         | Tipo de dato   | Descripción                        |
|-----------------|----------------|------------------------------------|
| id              | UUID           | PRIMARY KEY                        |
| negocio_id      | UUID           | FK → negocio.id                    |
| categoria_id    | INT            | FK → categoria_componente.id       |
| nombre          | TEXT           | Nombre del componente              |
| descripcion     | TEXT           | Descripción general                |
| en_uso          | BOOLEAN        | Si está en uso                     |
| activo          | BOOLEAN        | Si está activo                     |
| ubicacion       | TEXT           | Ubicación física (rack, bandeja)   |
| imagen_url      | TEXT           | URL de imagen                      |
| fecha_registro  | TIMESTAMP      | Default: now()                     |

---

## 🔌 `detalle_cable`

| Columna        | Tipo de dato   |
|----------------|----------------|
| componente_id  | UUID (PK, FK)  |
| tipo_cable     | TEXT           |
| color          | TEXT           |
| tamaño         | DECIMAL(5,2)   |
| tipo_conector  | TEXT           |

---

## 📶 `detalle_switch`

| Columna              | Tipo de dato   |
|----------------------|----------------|
| componente_id        | UUID (PK, FK)  |
| marca                | TEXT           |
| modelo               | TEXT           |
| numero_serie         | TEXT           |
| administrable        | BOOLEAN        |
| poe                  | BOOLEAN        |
| cantidad_puertos     | INT            |
| velocidad_puertos    | TEXT           |
| tipo_puertos         | TEXT           |
| ubicacion_en_rack    | TEXT           |
| direccion_ip         | TEXT           |
| firmware             | TEXT           |

---

## 🧱 `detalle_patch_panel`

| Columna             | Tipo de dato   |
|---------------------|----------------|
| componente_id       | UUID (PK, FK)  |
| tipo_conector       | TEXT           |
| numero_puertos      | INT            |
| categoria           | TEXT           |
| tipo_montaje        | TEXT           |
| numeracion_frontal  | BOOLEAN        |
| panel_ciego         | BOOLEAN        |

---

## 🗄 `detalle_rack`

| Columna                | Tipo de dato   |
|------------------------|----------------|
| componente_id          | UUID (PK, FK)  |
| tipo                   | TEXT           |
| altura_u               | INT            |
| profundidad_cm         | INT            |
| ancho_cm               | INT            |
| ventilacion_integrada  | BOOLEAN        |
| puertas_con_llave      | BOOLEAN        |
| ruedas                 | BOOLEAN        |
| color                  | TEXT           |

---

## 🧰 `detalle_organizador`

| Columna      | Tipo de dato   |
|--------------|----------------|
| componente_id| UUID (PK, FK)  |
| tipo         | TEXT           |
| material     | TEXT           |
| tamaño       | TEXT           |
| color        | TEXT           |

---

## ⚡ `detalle_ups`

| Columna            | Tipo de dato   |
|--------------------|----------------|
| componente_id      | UUID (PK, FK)  |
| tipo               | TEXT           |
| marca              | TEXT           |
| modelo             | TEXT           |
| voltaje_entrada    | TEXT           |
| voltaje_salida     | TEXT           |
| capacidad_va       | INT            |
| autonomia_minutos  | INT            |
| cantidad_tomas     | INT            |
| rackeable          | BOOLEAN        |

---

## 🔐 `detalle_router_firewall`

| Columna                  | Tipo de dato   |
|--------------------------|----------------|
| componente_id            | UUID (PK, FK)  |
| tipo                     | TEXT           |
| marca                    | TEXT           |
| modelo                   | TEXT           |
| numero_serie             | TEXT           |
| interfaces               | TEXT           |
| capacidad_routing_gbps   | DECIMAL(5,2)   |
| direccion_ip             | TEXT           |
| firmware                 | TEXT           |
| licencias                | TEXT           |

---

## 🧿 `detalle_equipo_activo`

| Columna           | Tipo de dato   |
|-------------------|----------------|
| componente_id     | UUID (PK, FK)  |
| tipo              | TEXT           |
| marca             | TEXT           |
| modelo            | TEXT           |
| numero_serie      | TEXT           |
| especificaciones  | TEXT           |
| direccion_ip      | TEXT           |
| firmware          | TEXT           |
