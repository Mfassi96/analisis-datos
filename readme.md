# Trigo en Argentina: producción, geografía y riesgo de abastecimiento

Proyecto final de la Diplomatura en Datos · Autor: Mauro [completar apellido]

Análisis de la producción de trigo (total y candeal) por provincia y departamento,
campañas 2019/20 a 2025/26, con foco en la materia prima de la harina y la panificación.

**Estado del proyecto:** en desarrollo. Hecho: preparación de datos, trigo candeal vs. total,
superficie sembrada vs. cosechada (nivel provincial), tabla departamental de trigo total y
candeal vs. total por departamento y tablas para el tablero. Pendiente: armado del tablero en
Looker Studio y preguntas 1 y 5 (ver sección 9). El mapa en QGIS queda pospuesto.

---

## 1. Objetivo y preguntas de negocio

**Pregunta central:** ¿qué tan estable y concentrada es la oferta de trigo en Argentina
y dónde está el riesgo?

Preguntas guía (sugeridas por el docente):

| # | Pregunta | Estado |
|---|---|---|
| 1 | ¿Cómo cambió el uso del suelo en cuanto a cultivos y trigo (por departamento)? | Pendiente |
| 2 | ¿Cómo se compara la producción de trigo candeal y trigo total por provincia y departamento? | Hecho (país, provincia y departamento) |
| 3 | ¿Qué relación hay entre superficie sembrada y cosechada? ¿Qué provincias aprovechan más lo sembrado? | Provincia: hecho. Departamento: tabla lista (`pct_no_cosechado`), análisis pendiente |
| 4 | ¿Cuánto se produce de trigo candeal frente al total, y por provincia? | Hecho |
| 5 | ¿Cómo es el rendimiento del trigo frente al del conjunto de cultivos y cuánto representa de la producción total? | Pendiente |

## 2. Fuente de datos

| Campo | Detalle |
|---|---|
| Dataset | "Agricultura - Estimaciones agrícolas" |
| Origen | Dirección de Estimaciones Agrícolas, Secretaría de Agricultura, Ganadería y Pesca (Argentina) |
| Publicación | datos.gob.ar, licencia CC-BY-4.0 |
| Archivo de partida | `Estimaciones.csv`, descargado del portal de la Dirección de Estimaciones Agrícolas (datosestimaciones.magyp.gob.ar) |
| Fecha de descarga | [completar] |
| Cobertura del original | campañas 1969/70 a 2025/26, por cultivo, provincia y departamento |
| Variables | superficie sembrada (ha), superficie cosechada (ha), producción (tn), rendimiento (kg/ha) |

Las campañas recientes son **estimaciones** y pueden ser revisadas por la fuente.

> La licencia CC-BY-4.0 figura en la página del dataset en datos.gob.ar. No se verificaron
> los términos de uso del portal de la Dirección de Estimaciones Agrícolas.

### Comparación entre las dos descargas

Se descargaron dos versiones y se compararon fila por fila:

| Archivo | Filas | Última campaña |
|---|---:|---|
| `estimaciones-agricolas-2026-03.csv` (datos.gob.ar, actualizado el 5/3/2026) | 160.499 | 2024/25 |
| `Estimaciones.csv` (portal de la Dirección de Estimaciones Agrícolas) | 163.760 | **2025/26** |

- En las 160.491 filas comunes, los valores de superficie sembrada, superficie cosechada,
  producción y rendimiento son **idénticos**.
- `Estimaciones.csv` tiene 82 filas más (sobre todo de yerba mate y té) y es el único que
  incluye la campaña 2025/26. Por eso se eligió como archivo de partida.
- La versión de datos.gob.ar trae 8 filas sin provincia ni departamento.

## 3. Registro de filas: cuántas se eliminaron y por qué

> Todos los conteos son filas de datos (sin contar el encabezado) y se verificaron
> comparando el archivo de trabajo contra el original, fila por fila.

### 3.1 Resumen

| Etapa | Filas | Diferencia |
|---|---:|---:|
| Archivo original (`Estimaciones.csv`) | 163.760 | |
| Archivo de trabajo (`estimaciones2020-2026.csv`) | 20.712 | **−143.048** (−87,4%) |
| Subconjunto de trigo usado en el análisis (filtrado en R) | 2.200 | −18.512 (no se borran, se filtran) |

Se conserva el **12,6%** de las filas del original. El original no se modifica y permanece
en `1_fuentes_datos/`.

### 3.2 Criterio de eliminación

Se aplicó **un solo criterio**: se eliminaron las campañas anteriores a 2019/20. Se conservan
las campañas que terminan en 2020 o después (2019/20 a 2025/26).

- Campañas en el original: **57**. Conservadas: **7**. Eliminadas: **50** (1969/70 a 2018/19).
- Ninguna fila de una campaña conservada fue eliminada: las 20.712 filas del original de
  2019/20 en adelante están todas en el archivo de trabajo.

### 3.3 Filas eliminadas por período

| Período (inicio de campaña) | Campañas eliminadas | Filas eliminadas |
|---|---:|---:|
| 1969 | 1 | 4.143 |
| 1970-1979 | 10 | 40.943 |
| 1980-1989 | 10 | 33.252 |
| 1990-1999 | 10 | 21.564 |
| 2000-2009 | 10 | 21.853 |
| 2010-2018 | 9 | 21.293 |
| **Total** | **50** | **143.048** |

### 3.4 Filas conservadas por campaña

| Campaña | Filas |
|---|---:|
| 2019/20 | 2.561 |
| 2020/21 | 2.740 |
| 2021/22 | 2.987 |
| 2022/23 | 3.004 |
| 2023/24 | 3.072 |
| 2024/25 | 3.161 |
| 2025/26 | 3.187 |
| **Total** | **20.712** |

### 3.5 Qué desaparece como consecuencia (no son eliminaciones adicionales)

Estas cifras **están incluidas** en las 143.048 filas, no se suman a ellas.

| Dimensión | Original | Trabajo | Desaparecen |
|---|---:|---:|---:|
| Provincias | 23 | 15 | 8 |
| Departamentos | 509 | 330 | 179 |
| Cultivos | 41 | 28 | 13 |

- **Provincias (8.483 filas):** Chubut, La Rioja, Mendoza, Neuquén, Río Negro, San Juan,
  Santa Cruz y Tierra del Fuego.
- **Cultivos (37.317 filas):** ajo, banana, caña de azúcar, cebada cervecera, cebada forrajera,
  cebolla, jojoba, limón, mandarina, naranja, papa, pomelo y tung. Su último dato es anterior
  a 2019/20.

### 3.6 Qué NO se eliminó

**No se eliminó ninguna fila por problemas de calidad.** El original tiene 0 valores nulos,
0 filas duplicadas (misma provincia, departamento, cultivo y campaña) y 0 valores negativos.
Los valores de las 20.712 filas conservadas son **idénticos** al original. No se editó
ningún número.

### 3.7 Filas con nombres dañados (conservadas, sin corregir todavía)

Al guardar desde LibreOffice, los caracteres con tilde quedaron grabados como `�`.
Afecta a **3.088 filas** de cultivos que no son trigo: Maíz (2.106), Maní (422),
Algodón (387), Té (106) y Cártamo (67). Los nombres se pueden restaurar a partir de
`cultivo_id` (2 = Algodón, 8 = Cártamo, 19 = Maní, 27 = Té, 32 = Maíz). **Esta corrección
todavía no se aplicó**, y no afecta a ningún resultado de trigo.

## 4. Pasos realizados

1. **Obtención de datos.** Descarga de las dos versiones del dataset (sección 2).
2. **Verificación de las fuentes.** Comparación de ambas versiones fila por fila y revisión de
   la página del dataset y su diccionario de datos (11 campos; coinciden con el CSV).
3. **Recorte temporal.** Filtrado manual en LibreOffice Calc: de 163.760 a 20.712 filas
   (campañas 2019/20 a 2025/26), guardado como `estimaciones2020-2026.csv`
   (separador coma, UTF-8) en `2__transformacion/`.
4. **Carga en R** con `read.csv()`. Control: 20.712 filas.
5. **Renombrado de columnas por posición**, para evitar los nombres deformados por las tildes
   (`provincia_id`, `provincia`, `dep_id`, `departamento`, `cultivo_id`, `cultivo`,
   `campania_id`, `campania`, `sup_sembrada_ha`, `sup_cosechada_ha`, `produccion_tn`,
   `rendimiento_kgha`).
6. **Tabla de provincias** (15 provincias con su código de 2 dígitos como texto, por ejemplo `06`).
7. **Filtro de trigo por `cultivo_id`** (28 = Trigo total, 29 = Trigo candeal): 2.200 filas
   (1.785 de trigo total y 415 de candeal).
8. **Serie nacional de trigo total** por campaña: producción, rendimiento, variación
   interanual y porcentaje de superficie no cosechada.
9. **Trigo candeal vs. total** por provincia y campaña, y trigo pan derivado
   (total − candeal). Controles: 27.886.449 t de total, 411.083 t de candeal y
   27.475.366 t de trigo pan en 2025/26.
10. **Superficie sembrada vs. cosechada** por provincia (acumulado de las 7 campañas) y por
    provincia y campaña.
11. **Tabla departamental de trigo total.** Se construyó el código INDEC `depto_id`
    (`provincia_id` × 1000 + `dep_id`, 5 dígitos, como texto) y se calcularon rendimiento y
    porcentaje no cosechado por departamento y campaña, con `NA` donde la superficie es 0
    para evitar divisiones por cero. Controles: 1.785 filas, 269 departamentos distintos,
    265 en 2025/26 y General López (Santa Fe) primero en 2025/26 con 1.212.287 t.
12. **Trigo candeal vs. total por departamento.** Se unieron el trigo total (28) y el candeal
    (29) por `depto_id` y campaña, y se calculó el trigo pan derivado y el porcentaje de
    candeal. Controles: 1.785 filas, 2.222.136 t de candeal en total, 415 filas con candeal,
    100 departamentos con candeal y el candeal nunca mayor al total.
13. **Tablas para el tablero.** Se generaron tres tablas por campaña (país, provincia y
    departamento) con medidas sumables, en `3_tablero/`. Controles: 7, 96 y 1.785 filas;
    269 departamentos; y los mismos totales en las tres (por ejemplo, 134.377.249 t de trigo
    total). El top 5 de provincias en 2025/26 es Buenos Aires, Santa Fe, Córdoba, Entre Ríos y
    Santiago del Estero, con el 93,4% de la producción.

Todos los resultados se compararon contra valores calculados de forma independiente y
coincidieron.

## 5. Archivos generados

Todos están en `2__transformacion/`, en UTF-8, con coma como separador. Se generan con los
scripts de `proceso/` (sección 8).

| Archivo | Qué contiene | Filas |
|---|---|---:|
| `estimaciones2020-2026.csv` | Datos de trabajo: todos los cultivos, campañas 2019/20 a 2025/26 | 20.712 |
| `dim_provincia.csv` | `provincia_id` (texto de 2 dígitos) y `provincia` | 15 |
| `trigo_candeal_vs_total_provincial.csv` | Por provincia y campaña: `total_tn`, `candeal_tn`, `pan_tn` y `pct_candeal`. Muestra cuánto del trigo de cada provincia es candeal | 96 |
| `trigo_candeal_vs_total_nacional.csv` | Por campaña: producción de trigo total, candeal, trigo pan y `pct_candeal` a nivel país | 7 |
| `trigo_sembrada_vs_cosechada_provincial.csv` | Por provincia, acumulado de las 7 campañas: `sup_sembrada_ha`, `sup_cosechada_ha`, `no_cosechada_ha` y `pct_no_cosechado` | 14 |
| `trigo_sembrada_vs_cosechada_campania.csv` | Por provincia y campaña: `sup_sembrada_ha`, `sup_cosechada_ha`, `no_cosechada_ha` y `pct_no_cosechado`. Muestra en qué años y provincias se dejó más superficie sin cosechar | 96 |
| `trigo_sembrada_vs_cosechada_nacional.csv` | Por campaña, a nivel país: `sup_sembrada_ha`, `sup_cosechada_ha`, `no_cosechada_ha` y `pct_no_cosechado` | 7 |
| `trigo_total_departamental.csv` | Trigo total por departamento y campaña, con `depto_id` (código INDEC de 5 dígitos): superficie sembrada y cosechada, producción, rendimiento y `pct_no_cosechado` | 1.785 |
| `trigo_candeal_vs_total_departamental.csv` | Por departamento y campaña: `total_tn`, `candeal_tn`, `pan_tn` y `pct_candeal`. Muestra dónde se concentra el candeal | 1.785 |

Notas:

- Los 96 registros son 14 provincias × 7 campañas, menos 2 (Formosa no tiene datos de trigo
  en 2019/20 ni en 2020/21).
- `pan_tn` = `total_tn` − `candeal_tn`. No es un dato de la fuente: es un cálculo derivado.
- En los archivos de `trigo_sembrada_vs_cosechada_*`, "no cosechada" es la diferencia entre
  sembrada y cosechada. Los datos no indican la causa (clima, pastoreo, abandono), así que
  no es una pérdida confirmada.

### 5.1 Diccionario de datos

Descripción de los campos de cada archivo de `2__transformacion/`: qué contienen, cómo se
calculan y para qué se usan.

#### Convenciones generales

| Convención | Detalle |
|---|---|
| Formato | CSV en UTF-8, separado por comas, con los textos entre comillas |
| Unidades | Producción en toneladas (`tn`), superficie en hectáreas (`ha`), rendimiento en kg/ha |
| Porcentajes | Escala de 0 a 100 (no fracciones): `2,7` significa 2,7% |
| `campania` | Campaña agrícola como texto: `2019/20` se siembra en 2019 y se cosecha hasta principios de 2020 |
| Nombres geográficos | En mayúsculas y sin tildes, tal como vienen en la fuente (por ejemplo `CORDOBA`) |
| Claves | `provincia_id` se guarda como texto con ceros iniciales (`06`). Al leerlo en R, indicar `colClasses = c(provincia_id = "character")` para no perder el cero |
| Trigo | `cultivo_id` 28 = Trigo total, 29 = Trigo candeal |

#### Mapa de archivos

| Archivo | Una fila representa | Filas | Responde a |
|---|---|---:|---|
| `estimaciones2020-2026.csv` | Un cultivo en un departamento y una campaña | 20.712 | Base de todo el análisis |
| `dim_provincia.csv` | Una provincia | 15 | Unión con mapas y otras tablas |
| `trigo_candeal_vs_total_provincial.csv` | Una provincia y una campaña | 96 | Preguntas 2 y 4 |
| `trigo_candeal_vs_total_nacional.csv` | Una campaña (país) | 7 | Preguntas 2 y 4 |
| `trigo_sembrada_vs_cosechada_provincial.csv` | Una provincia (7 campañas acumuladas) | 14 | Pregunta 3 |
| `trigo_sembrada_vs_cosechada_campania.csv` | Una provincia y una campaña | 96 | Pregunta 3 |
| `trigo_sembrada_vs_cosechada_nacional.csv` | Una campaña (país) | 7 | Pregunta 3 |
| `trigo_total_departamental.csv` | Un departamento y una campaña (solo trigo total) | 1.785 | Pregunta 3 y concentración, por departamento |
| `trigo_candeal_vs_total_departamental.csv` | Un departamento y una campaña (total, candeal y trigo pan) | 1.785 | Preguntas 2 y 4, por departamento |

---

#### `estimaciones2020-2026.csv` (datos de trabajo)

Es el archivo de partida, sin transformaciones de valores. Contiene todos los cultivos de las
campañas 2019/20 a 2025/26. Los demás archivos se calculan a partir de él.

| Campo | Tipo | Descripción | Ejemplo |
|---|---|---|---|
| `provincia_id` | entero | Código INDEC de la provincia | 82 |
| `provincia` | texto | Nombre de la provincia | SANTA FE |
| `dep_id` | entero | Código del departamento dentro de la provincia (3 dígitos). Para obtener el código INDEC completo de 5 dígitos: `provincia_id` × 1000 + `dep_id` | 42 |
| `departamento` | texto | Nombre del departamento | GENERAL LOPEZ |
| `cultivo_id` | entero | Código del cultivo | 28 |
| `cultivo` | texto | Nombre del cultivo | Trigo total |
| `campania_id` | entero | Identificador numérico de la campaña, interno de la fuente. En el análisis se usa `campania` | 59 |
| `campania` | texto | Campaña agrícola | 2025/26 |
| `sup_sembrada_ha` | entero | Superficie sembrada, en hectáreas | 212475 |
| `sup_cosechada_ha` | entero | Superficie cosechada, en hectáreas | 209015 |
| `produccion_tn` | entero | Producción, en toneladas | 1212287 |
| `rendimiento_kgha` | entero | Rendimiento, en kg por hectárea cosechada. Equivale a producción ÷ superficie cosechada × 1000 | 5800 |

Notas:

- En esta versión, el texto de los cultivos Algodón, Cártamo, Maní, Maíz y Té tiene
  caracteres dañados (`�`) por el guardado desde LibreOffice. No afecta al trigo.
- Cada combinación de provincia, departamento, cultivo y campaña aparece una sola vez.

---

#### `dim_provincia.csv`

Tabla de referencia de las provincias presentes en los datos.

| Campo | Tipo | Descripción | Ejemplo |
|---|---|---|---|
| `provincia_id` | texto | Código INDEC de 2 dígitos, con cero inicial | 06 |
| `provincia` | texto | Nombre de la provincia | BUENOS AIRES |

**Para qué sirve:** unir las tablas con capas de mapas (QGIS), que traen el código de
provincia, y asignarle un código a las tablas provinciales, que se unen por el campo
`provincia`.

---

#### `trigo_candeal_vs_total_provincial.csv`

Producción de trigo total, candeal y trigo pan por provincia y campaña. Se obtiene sumando
los departamentos de cada provincia. Clave: `provincia` + `campania`.

| Campo | Tipo | Descripción | Ejemplo |
|---|---|---|---|
| `provincia` | texto | Nombre de la provincia | SALTA |
| `campania` | texto | Campaña agrícola | 2019/20 |
| `total_tn` | entero | Producción de trigo total, en toneladas | 129701 |
| `candeal_tn` | entero | Producción de trigo candeal, en toneladas. Un `0` indica que no hay candeal registrado en esa provincia y campaña | 17131 |
| `pan_tn` | entero | Trigo pan derivado: `total_tn` − `candeal_tn`. Es un cálculo, no un dato de la fuente | 112570 |
| `pct_candeal` | decimal | Participación del candeal: `candeal_tn` ÷ `total_tn` × 100, con 1 decimal | 13.2 |

**Para qué sirve:** ver cuánto del trigo de cada provincia es candeal (pastas) y cuánto es
trigo pan, y comparar provincias. Permite un gráfico de barras apiladas o un mapa por provincia.

---

#### `trigo_candeal_vs_total_nacional.csv`

Los mismos indicadores a nivel país: suma de todas las provincias por campaña.
Clave: `campania`.

| Campo | Tipo | Descripción | Ejemplo |
|---|---|---|---|
| `campania` | texto | Campaña agrícola | 2025/26 |
| `total_tn` | entero | Producción nacional de trigo total, en toneladas | 27886449 |
| `candeal_tn` | entero | Producción nacional de trigo candeal, en toneladas | 411083 |
| `pan_tn` | entero | Trigo pan derivado: `total_tn` − `candeal_tn` | 27475366 |
| `pct_candeal` | decimal | `candeal_tn` ÷ `total_tn` × 100, con 2 decimales | 1.47 |

**Para qué sirve:** mostrar la evolución del peso del candeal en las 7 campañas (entre 0,79% y
2,70%) y la oferta total de trigo. Es el insumo para los indicadores y el gráfico de línea
del tablero.

---

#### `trigo_candeal_vs_total_departamental.csv`

Producción de trigo total, candeal y trigo pan por departamento y campaña. Clave:
`depto_id` + `campania`. Está ordenado por campaña y, dentro de cada una, de mayor a menor
`total_tn`.

| Campo | Tipo | Descripción | Ejemplo |
|---|---|---|---|
| `depto_id` | texto | Código INDEC del departamento, de 5 dígitos con ceros iniciales | 06189 |
| `provincia` | texto | Nombre de la provincia | BUENOS AIRES |
| `departamento` | texto | Nombre del departamento | CORONEL DORREGO |
| `campania` | texto | Campaña agrícola | 2025/26 |
| `total_tn` | entero | Producción de trigo total, en toneladas | 498171 |
| `candeal_tn` | entero | Producción de trigo candeal, en toneladas. Vale `0` donde no hay candeal registrado (1.370 de las 1.785 filas) | 73361 |
| `pan_tn` | entero | Trigo pan derivado: `total_tn` − `candeal_tn` | 424810 |
| `pct_candeal` | decimal | `candeal_tn` ÷ `total_tn` × 100, con 1 decimal. Queda vacío si `total_tn` es 0 (11 filas) | 14.7 |

**Para qué sirve:** comparar el candeal con el total por departamento (preguntas 2 y 4) y ver
su concentración. 100 de los 269 departamentos tuvieron candeal en alguna campaña; en 2025/26,
70. Los valores faltantes se guardan como celdas vacías.

---

#### `trigo_sembrada_vs_cosechada_provincial.csv`

Superficie de trigo total por provincia, acumulada en las 7 campañas.
Clave: `provincia`.

| Campo | Tipo | Descripción | Ejemplo |
|---|---|---|---|
| `provincia` | texto | Nombre de la provincia | BUENOS AIRES |
| `sup_sembrada_ha` | entero | Hectáreas sembradas, sumadas en las 7 campañas | 18081296 |
| `sup_cosechada_ha` | entero | Hectáreas cosechadas, sumadas en las 7 campañas | 17683285 |
| `no_cosechada_ha` | entero | `sup_sembrada_ha` − `sup_cosechada_ha` | 398011 |
| `pct_no_cosechado` | decimal | `no_cosechada_ha` ÷ `sup_sembrada_ha` × 100, con 1 decimal | 2.2 |

**Para qué sirve:** ranking de qué provincias aprovechan más lo sembrado. Conviene mostrar
`no_cosechada_ha` junto al porcentaje, porque las provincias con poca superficie tienen
porcentajes extremos con pocas hectáreas.

---

#### `trigo_sembrada_vs_cosechada_campania.csv`

La misma medición, desglosada por campaña. Clave: `provincia` + `campania`.

| Campo | Tipo | Descripción | Ejemplo |
|---|---|---|---|
| `provincia` | texto | Nombre de la provincia | CORDOBA |
| `campania` | texto | Campaña agrícola | 2019/20 |
| `sup_sembrada_ha` | entero | Hectáreas sembradas en esa campaña | 1448787 |
| `sup_cosechada_ha` | entero | Hectáreas cosechadas en esa campaña | 1368281 |
| `no_cosechada_ha` | entero | `sup_sembrada_ha` − `sup_cosechada_ha` | 80506 |
| `pct_no_cosechado` | decimal | `no_cosechada_ha` ÷ `sup_sembrada_ha` × 100, con 1 decimal | 5.6 |

**Para qué sirve:** ver en qué años y provincias quedó más superficie sin cosechar. Es la
base de un mapa de calor (provincia × campaña). Formosa no tiene datos en 2019/20 ni en
2020/21, por eso hay 96 filas y no 98.

---

#### `trigo_sembrada_vs_cosechada_nacional.csv`

Superficie de trigo total a nivel país por campaña. Clave: `campania`.

| Campo | Tipo | Descripción | Ejemplo |
|---|---|---|---|
| `campania` | texto | Campaña agrícola | 2022/23 |
| `sup_sembrada_ha` | entero | Hectáreas sembradas en el país | 5907287 |
| `sup_cosechada_ha` | entero | Hectáreas cosechadas en el país | 5488728 |
| `no_cosechada_ha` | entero | `sup_sembrada_ha` − `sup_cosechada_ha` | 418559 |
| `pct_no_cosechado` | decimal | `no_cosechada_ha` ÷ `sup_sembrada_ha` × 100, con 1 decimal | 7.1 |

**Para qué sirve:** comparar campañas a nivel país. 2022/23 fue la de mayor superficie no
cosechada (7,1%).

---

#### `trigo_total_departamental.csv`

Trigo total (`cultivo_id` 28) por departamento y campaña. Clave: `depto_id` + `campania`.
Está ordenado por campaña y, dentro de cada una, de mayor a menor producción.

| Campo | Tipo | Descripción | Ejemplo |
|---|---|---|---|
| `depto_id` | texto | Código INDEC del departamento, de 5 dígitos con ceros iniciales: `provincia_id` × 1000 + `dep_id` | 82042 |
| `provincia` | texto | Nombre de la provincia | SANTA FE |
| `departamento` | texto | Nombre del departamento | GENERAL LOPEZ |
| `campania` | texto | Campaña agrícola | 2025/26 |
| `sup_sembrada_ha` | entero | Hectáreas sembradas | 212475 |
| `sup_cosechada_ha` | entero | Hectáreas cosechadas | 209015 |
| `produccion_tn` | entero | Producción, en toneladas | 1212287 |
| `rendimiento_kgha` | entero | `produccion_tn` ÷ `sup_cosechada_ha` × 1000, redondeado. Vale `NA` si la superficie cosechada es 0 (6 filas) | 5800 |
| `pct_no_cosechado` | decimal | (`sup_sembrada_ha` − `sup_cosechada_ha`) ÷ `sup_sembrada_ha` × 100, con 1 decimal. Vale `NA` si la superficie sembrada es 0 (3 filas) | 1.6 |

**Para qué sirve:** rankings y concentración de la producción por departamento, y comparar
rendimiento y superficie no cosechada entre departamentos. Hay 269 departamentos distintos en
las 7 campañas y 265 con trigo en 2025/26. Los nombres de departamento pueden repetirse entre
provincias, por eso la clave es `depto_id` y no el nombre. Esta tabla **no incluye candeal**.

---

#### Aclaración sobre "no cosechada"

`no_cosechada_ha` y `pct_no_cosechado` son una diferencia entre dos columnas de la fuente.
**No indican la causa** de la diferencia (sequía, helada, granizo, uso del lote para pastoreo
u otros motivos), por lo que no deben leerse como pérdidas confirmadas.

#### Relaciones entre archivos y controles

- La suma de `total_tn` de todas las provincias, por campaña, da el valor de
  `trigo_candeal_vs_total_nacional.csv`. En 2025/26: 27.886.449 t.
- La suma de `sup_sembrada_ha` del archivo provincial da 45.772.168 ha y la de
  `sup_cosechada_ha`, 43.869.667 ha (diferencia: 1.902.501 ha, 4,2%).
- Las 1.785 filas de `trigo_total_departamental.csv` equivalen a las filas de trigo total
  (`cultivo_id` 28) del archivo de trabajo, y su suma de `produccion_tn` por campaña coincide con
  `total_tn` del archivo nacional.
- La suma de `candeal_tn` de `trigo_candeal_vs_total_departamental.csv` en las 7 campañas
  (2.222.136 t) coincide con la de los archivos provincial y nacional de candeal.
- Los archivos provinciales se unen entre sí por `provincia` (y `campania` cuando corresponde)
  y con `dim_provincia.csv` por `provincia`.

### 5.2 Tablas para el tablero (`3_tablero/`)

Tres tablas generadas por `06_preparar_tablero.R` para cargar en Looker Studio. Todas son
por campaña y tienen las mismas seis medidas **sumables**. No guardan porcentajes ni
rendimientos: se definen como campos calculados en Looker Studio para que se recalculen bien
al filtrar o agrupar (promediar porcentajes da resultados incorrectos).

| Archivo | Una fila representa | Filas |
|---|---|---:|
| `tablero_nacional_campania.csv` | Una campaña (país) | 7 |
| `tablero_provincial_campania.csv` | Una provincia y una campaña | 96 |
| `tablero_departamental_campania.csv` | Un departamento y una campaña | 1.785 |

| Campo | Tipo | Descripción | Presente en |
|---|---|---|---|
| `depto_id` | texto | Código INDEC de 5 dígitos, con ceros iniciales | Departamental |
| `provincia` | texto | Nombre de la provincia | Provincial y departamental |
| `departamento` | texto | Nombre del departamento | Departamental |
| `campania` | texto | Campaña agrícola | Las tres |
| `sup_sembrada_ha` | entero | Hectáreas sembradas de trigo total | Las tres |
| `sup_cosechada_ha` | entero | Hectáreas cosechadas | Las tres |
| `no_cosechada_ha` | entero | `sup_sembrada_ha` − `sup_cosechada_ha` | Las tres |
| `total_tn` | entero | Producción de trigo total, en toneladas | Las tres |
| `candeal_tn` | entero | Producción de trigo candeal, en toneladas (0 si no hay) | Las tres |
| `pan_tn` | entero | Trigo pan derivado: `total_tn` − `candeal_tn` | Las tres |

**Campos calculados en Looker Studio**

| Campo | Fórmula |
|---|---|
| Rendimiento (kg/ha) | `SUM(total_tn) / SUM(sup_cosechada_ha) * 1000` |
| % no cosechado | `SUM(no_cosechada_ha) / SUM(sup_sembrada_ha)` |
| % candeal | `SUM(candeal_tn) / SUM(total_tn)` |

**Controles:** las tres tablas suman lo mismo: 45.772.168 ha sembradas, 43.869.667 ha
cosechadas (1.902.501 ha no cosechadas), 134.377.249 t de trigo total, 2.222.136 t de candeal y
132.155.113 t de trigo pan. La tabla nacional es la suma de la provincial, y la provincial, la
suma de la departamental.

**Carga:** se suben como archivos CSV (UTF-8, encabezados con letras y guiones bajos). Los datos
subidos a un mismo conjunto se agregan y no se reemplazan: si se regeneran los archivos, hay que
crear un conjunto nuevo para no duplicar filas.

## 6. Resultados obtenidos

### 6.1 Serie nacional de trigo total

| Campaña | Sembrada (ha) | Producción (t) | Rendimiento (kg/ha) | Var. interanual | No cosechado |
|---|---:|---:|---:|---:|---:|
| 2019/20 | 6.951.171 | 19.776.942 | 2.938,7 | | 3,2% |
| 2020/21 | 6.729.898 | 17.644.277 | 2.759,5 | −10,8% | 5,0% |
| 2021/22 | 6.751.729 | 22.150.287 | 3.382,5 | +25,5% | 3,0% |
| 2022/23 | 5.907.287 | 12.555.860 | 2.287,6 | −43,3% | 7,1% |
| 2023/24 | 5.916.678 | 15.853.154 | 2.843,4 | +26,3% | 5,8% |
| 2024/25 | 6.550.169 | 18.510.280 | 2.919,0 | +16,8% | 3,2% |
| 2025/26 | 6.965.236 | 27.886.449 | 4.105,9 | +50,7% | 2,5% |

La superficie sembrada se mueve poco (entre 5,9 y 7,0 millones de hectáreas). La producción
oscila entre 12,6 y 27,9 millones de toneladas, así que la variación viene principalmente del
**rendimiento**. Esta tabla se calculó en la consola de R y no se guardó como archivo.

### 6.2 Trigo candeal vs. total

- El candeal es siempre marginal: entre **0,79% y 2,70%** del trigo total del país.

| Campaña | Candeal (t) | % del total |
|---|---:|---:|
| 2019/20 | 156.421 | 0,79 |
| 2020/21 | 477.129 | 2,70 |
| 2021/22 | 295.776 | 1,34 |
| 2022/23 | 228.803 | 1,82 |
| 2023/24 | 302.966 | 1,91 |
| 2024/25 | 349.958 | 1,89 |
| 2025/26 | 411.083 | 1,47 |

- En 2025/26, solo 9 provincias tienen candeal. **Buenos Aires concentra el 86,9%**
  (357.085 t), aunque es apenas el 3,2% de su propio trigo.
- **San Luis (45,8%) y Salta (10,9%)** tienen el mayor peso relativo del candeal, con poco
  volumen. Tucumán, 7,9%.
- Chaco, Corrientes, Formosa, Jujuy y Santa Fe no producen candeal.
- **Trigo pan derivado en 2025/26:** 27.475.366 t.

### 6.3 Superficie sembrada vs. cosechada

- En las 7 campañas se sembraron **45.772.168 ha** de trigo total y se cosecharon
  **43.869.667 ha**. Quedaron sin cosechar **1.902.501 ha (4,2%)**.
- **Mayor aprovechamiento entre las grandes productoras:** Buenos Aires (2,2% no cosechado)
  y Entre Ríos (2,6%). Santa Fe y La Pampa, 4,1%.
- **Menor aprovechamiento:** Córdoba (7,4%), Chaco (7,6%) y Santiago del Estero (9,2%).
  San Luis tiene el valor más alto (23,9%), con poca superficie.
- Formosa (0,0%), Jujuy (0,4%) y Salta (0,8%) tienen los porcentajes más bajos, pero con muy
  pocas hectáreas.
- **Por campaña:** el pico nacional de 2022/23 (7,1%) se explica sobre todo por Santiago del
  Estero (29,1%), Santa Fe (10,0%) y Buenos Aires (5,4%). Córdoba tuvo su peor campaña en
  2023/24 (11,4%) y nunca bajó de 4,5%.
- Hay valores extremos en provincias chicas (Chaco 40,8% y San Luis 49,6% en 2020/21;
  Corrientes 36,0% en 2019/20), por lo que conviene interpretarlos junto a las hectáreas.

### 6.4 Trigo total por departamento (campaña 2025/26)

| Departamento | Provincia | `depto_id` | Producción (t) | Rendimiento (kg/ha) | No cosechado |
|---|---|---|---:|---:|---:|
| General López | Santa Fe | 82042 | 1.212.287 | 5.800 | 1,6% |
| Unión | Córdoba | 14182 | 1.108.425 | 6.099 | 5,5% |
| San Justo | Córdoba | 14140 | 912.300 | 4.198 | 13,2% |
| Marcos Juárez | Córdoba | 14063 | 823.225 | 6.500 | 2,5% |
| Castellanos | Santa Fe | 82021 | 671.040 | 4.800 | 0,4% |

- La producción está **muy concentrada**: de los 265 departamentos con trigo, **30 suman la
  mitad** de la producción de 2025/26 y **77 suman el 80%**.
- Los cinco primeros pertenecen a Córdoba y Santa Fe.
- Entre ellos, San Justo tiene el rendimiento más bajo (4.198 kg/ha) y el mayor porcentaje
  de superficie no cosechada (13,2%).

### 6.5 Trigo candeal por departamento

| Departamento | Provincia | Candeal 2025/26 (t) | % del trigo del departamento |
|---|---|---:|---:|
| Coronel Dorrego | Buenos Aires | 73.361 | 14,7% |
| Tres Arroyos | Buenos Aires | 64.825 | 10,9% |
| Coronel Pringles | Buenos Aires | 50.559 | 14,5% |
| Adolfo Gonzales Chaves | Buenos Aires | 19.139 | 7,3% |
| Ayacucho | San Luis | 15.040 | 54,7% |

- El candeal está **muy localizado**: en 2025/26 solo 70 de los 265 departamentos con trigo
  lo producen. **4 departamentos suman la mitad** del candeal y **16 suman el 80%**.
- Coronel Dorrego fue el mayor productor en las 7 campañas (555.901 t acumuladas), seguido
  por Tres Arroyos (238.469 t) y Coronel Pringles (230.981 t). Anta (Salta, 104.371 t) es el
  único departamento no bonaerense entre los cinco primeros.
- En tres departamentos el candeal es la mitad o más de su trigo en 2025/26: Ayacucho (54,7%)
  y Junín (51,0%), en San Luis, y la capital de Salta (60,9%). Son volúmenes chicos: a nivel
  país casi no pesan.
- Se detectaron 100 departamentos con candeal en alguna campaña, de 269 con trigo.

## 7. Decisiones y supuestos

- **Trigo total como base.** No se suma con el candeal: los datos indican que el total ya lo
  incluye (las 415 filas de candeal tienen fila de total en el mismo departamento y campaña,
  y el candeal nunca la supera).
- **Trigo pan derivado = trigo total − trigo candeal.** El candeal (*Triticum durum*) se usa
  para pastas y sémola; el trigo pan (*Triticum aestivum*), para harina de pan. Criterio
  sugerido por el docente y coherente con los datos.
- **Claves como texto con ceros iniciales:** `provincia_id` de 2 dígitos y `depto_id` de
  5 dígitos (código INDEC), para unir con capas de QGIS.
- **Filtro por `cultivo_id` y no por nombre**, para no depender de las tildes.
- **Subtotales:** `Trigo candeal`, `Soja 1ra`, `Soja 2da`, `Poroto alubia`, `negro` y `otros`
  están contenidos en otros cultivos. Se excluyen al sumar la superficie de todos los
  cultivos (relevante para las preguntas 1 y 5).
- **"Localidad" se interpreta como departamento**, el nivel más fino del dataset.
- **`NA` en lugar de división por cero.** En la tabla departamental, el rendimiento (6 filas)
  y el porcentaje no cosechado (3 filas) quedan como `NA` cuando la superficie es 0.
- **Tablas del tablero con medidas sumables.** No incluyen porcentajes ni rendimientos; estos se
  calculan en Looker Studio (sección 5.2) para que se recalculen bien al filtrar.
- **Mapa en QGIS pospuesto.** Se decidió dejarlo fuera por ahora. La tabla departamental ya
  incluye `depto_id`, de modo que se podrá retomar sin rehacer datos.

## 8. Estructura del repositorio

```
proyecto_analisis-trigo/
├── 1_fuentes_datos/        archivos originales, sin modificar
│   ├── Estimaciones.csv
│   └── estimaciones-agricolas-2026-03.csv
├── 2__transformacion/      datos de trabajo y tablas generadas (sección 5)
│   ├── dim_provincia.csv
│   ├── estimaciones2020-2026.csv
│   ├── trigo_candeal_vs_total_departamental.csv
│   ├── trigo_candeal_vs_total_nacional.csv
│   ├── trigo_candeal_vs_total_provincial.csv
│   ├── trigo_sembrada_vs_cosechada_campania.csv
│   ├── trigo_sembrada_vs_cosechada_nacional.csv
│   ├── trigo_sembrada_vs_cosechada_provincial.csv
│   └── trigo_total_departamental.csv
├── 3_tablero/              tablas para Looker Studio (sección 5.2)
│   ├── tablero_departamental_campania.csv
│   ├── tablero_nacional_campania.csv
│   └── tablero_provincial_campania.csv
├── proceso/                código de R (se ejecuta en orden)
│   ├── 01_dim_provincia.R
│   ├── 02_candeal_vs_total.R
│   ├── 03_sembrada_vs_cosechada.R
│   ├── 04_trigo_departamental.R
│   ├── 05_candeal_departamental.R
│   └── 06_preparar_tablero.R
└── readme.md
```

**Código.** Los scripts de `proceso/` se ejecutan en orden, cada uno por separado y sin
depender de objetos previos en la sesión. Cada uno carga `estimaciones2020-2026.csv`,
comprueba controles (por ejemplo, 20.712 filas) y se detiene si algo no coincide.

| Script | Qué hace | Archivos que genera |
|---|---|---|
| `01_dim_provincia.R` | Lista las 15 provincias con su código de 2 dígitos | `dim_provincia.csv` |
| `02_candeal_vs_total.R` | Filtra trigo (28 y 29), calcula candeal, total y trigo pan por provincia y campaña | `trigo_candeal_vs_total_provincial.csv`, `trigo_candeal_vs_total_nacional.csv` |
| `03_sembrada_vs_cosechada.R` | Superficie sembrada vs. cosechada de trigo total: acumulado, por campaña y nacional | `trigo_sembrada_vs_cosechada_provincial.csv`, `..._campania.csv`, `..._nacional.csv` |
| `04_trigo_departamental.R` | Trigo total por departamento y campaña, con `depto_id` de 5 dígitos | `trigo_total_departamental.csv` |
| `05_candeal_departamental.R` | Candeal, total y trigo pan por departamento y campaña, con el porcentaje de candeal | `trigo_candeal_vs_total_departamental.csv` |
| `06_preparar_tablero.R` | Tablas por campaña con medidas sumables para Looker Studio (país, provincia y departamento) | `3_tablero/tablero_nacional_campania.csv`, `..._provincial_campania.csv`, `..._departamental_campania.csv` |

Las rutas se definen en la variable `proyecto`, al principio de cada script.

## 9. Pendiente

1. **Armar el tablero en Looker Studio** con las tablas de `3_tablero/` (sección 5.2) y agregar
   el enlace al README.
2. **Pregunta 1** (uso del suelo) y **pregunta 5** (rendimiento frente a otros cultivos), con
   exclusión de subtotales y restauración de las tildes de los cultivos.
3. **Pregunta 3 por departamento:** analizar `pct_no_cosechado` de la tabla departamental.
4. **Mapa en QGIS (pospuesto):** capa de departamentos unida por `depto_id`.
5. Completar los campos marcados con [completar] y las conclusiones finales.

## 10. Limitaciones

- **Serie corta:** 7 campañas. Sirve para describir el período reciente, pero no para
  afirmar tendencias de largo plazo. El cambio de uso del suelo se analizaría mejor con la
  serie completa del original.
- Los datos cubren solo el eslabón primario (qué se siembra y cosecha, y dónde). No incluyen
  consumo, precios ni panaderías.
- Las últimas campañas son estimaciones sujetas a revisión.
- La superficie no cosechada no explica sus causas.
- Cultivos y provincias sin datos desde 2019/20 no forman parte del análisis.

## 11. Licencia y atribución

Datos: Dirección de Estimaciones Agrícolas, Secretaría de Agricultura, Ganadería y Pesca
(Argentina), CC-BY-4.0. Las tablas de `2__transformacion/` son derivadas del original y fueron
modificadas por el autor.
