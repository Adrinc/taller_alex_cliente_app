
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
| distribucion_id | UUID           | FK → distribucion.id               |

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

---

## 🧭 `distribucion`

| Columna      | Tipo de dato   | Descripción                          |
|--------------|----------------|--------------------------------------|
| id           | UUID           | PRIMARY KEY                          |
| negocio_id   | UUID           | FK → negocio.id                      |
| tipo         | TEXT           | 'MDF' o 'IDF'                         |
| nombre       | TEXT           | Nombre de la ubicación lógica        |
| descripcion  | TEXT           | Detalles adicionales (opcional)      |

---

## 🔗 `conexion_componente`

| Columna               | Tipo de dato   | Descripción                              |
|-----------------------|----------------|------------------------------------------|
| id                    | UUID           | PRIMARY KEY                              |
| componente_origen_id  | UUID           | FK → componente.id                       |
| componente_destino_id | UUID           | FK → componente.id                       |
| descripcion           | TEXT           | Descripción de la conexión (opcional)    |
| activo                | BOOLEAN        | Si la conexión está activa               |

---



## 👁️ `vista_negocios_con_coordenadas`

| Columna            | Tipo de dato | Descripción                                |
|--------------------|--------------|--------------------------------------------|
| negocio_id         | UUID         | ID del negocio                             |
| nombre_negocio     | TEXT         | Nombre del negocio                         |
| latitud            | DECIMAL      | Latitud del negocio                        |
| longitud           | DECIMAL      | Longitud del negocio                       |
| logo_negocio       | TEXT         | URL del logo del negocio                   |
| imagen_negocio     | TEXT         | URL de la imagen del negocio               |
| empresa_id         | UUID         | ID de la empresa                           |
| nombre_empresa     | TEXT         | Nombre de la empresa                       |
| logo_empresa       | TEXT         | URL del logo de la empresa                 |
| imagen_empresa     | TEXT         | URL de la imagen de la empresa             |

---

## 📋 `vista_inventario_por_negocio`

| Columna            | Tipo de dato | Descripción                                 |
|--------------------|--------------|---------------------------------------------|
| componente_id      | UUID         | ID del componente                           |
| nombre_componente  | TEXT         | Nombre del componente                       |
| categoria          | TEXT         | Categoría del componente                    |
| en_uso             | BOOLEAN      | Si está en uso                              |
| activo             | BOOLEAN      | Si está activo                              |
| ubicacion          | TEXT         | Ubicación física del componente             |
| imagen_componente  | TEXT         | Imagen asociada al componente               |
| negocio_id         | UUID         | ID del negocio                              |
| nombre_negocio     | TEXT         | Nombre del negocio                          |
| logo_negocio       | TEXT         | Logo del negocio                            |
| imagen_negocio     | TEXT         | Imagen del negocio                          |
| empresa_id         | UUID         | ID de la empresa                            |
| nombre_empresa     | TEXT         | Nombre de la empresa                        |
| logo_empresa       | TEXT         | Logo de la empresa                          |
| imagen_empresa     | TEXT         | Imagen de la empresa                        |

---

## 🧵 `vista_detalle_cables`

| Columna            | Tipo de dato | Descripción                                |
|--------------------|--------------|--------------------------------------------|
| componente_id      | UUID         | ID del componente                          |
| nombre             | TEXT         | Nombre del cable                           |
| tipo_cable         | TEXT         | Tipo de cable (UTP, fibra, etc.)           |
| color              | TEXT         | Color del cable                            |
| tamaño             | DECIMAL      | Longitud del cable                         |
| tipo_conector      | TEXT         | Tipo de conector (RJ45, LC, etc.)          |
| en_uso             | BOOLEAN      | Si está en uso                             |
| activo             | BOOLEAN      | Si está activo                             |
| ubicacion          | TEXT         | Ubicación física                           |
| imagen_componente  | TEXT         | Imagen del cable                           |
| nombre_negocio     | TEXT         | Nombre del negocio                         |
| logo_negocio       | TEXT         | Logo del negocio                           |
| nombre_empresa     | TEXT         | Nombre de la empresa                       |
| logo_empresa       | TEXT         | Logo de la empresa                         |

---

## 📊 `vista_resumen_componentes_activos`

| Columna          | Tipo de dato | Descripción                                  |
|------------------|--------------|----------------------------------------------|
| nombre_empresa   | TEXT         | Nombre de la empresa                         |
| nombre_negocio   | TEXT         | Nombre del negocio                           |
| categoria        | TEXT         | Categoría del componente                     |
| cantidad_activos | INTEGER      | Cantidad total de componentes activos        |

---

## 🔌 `vista_conexiones_por_negocio`

| Columna               | Tipo de dato | Descripción                              |
|-----------------------|--------------|------------------------------------------|
| id                    | UUID         | ID de la conexión                        |
| componente_origen_id  | UUID         | Componente origen                        |
| componente_destino_id | UUID         | Componente destino                       |
| descripcion           | TEXT         | Descripción de la conexión               |
| activo                | BOOLEAN      | Si la conexión está activa               |
"""
