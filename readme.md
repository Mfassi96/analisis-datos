## 5.1 Diccionario de datos

Descripción de los campos de cada archivo de `2__transformacion/`: qué contienen, cómo se
calculan y para qué se usan.

### Convenciones generales

| Convención | Detalle |
|---|---|
| Formato | CSV en UTF-8, separado por comas, con los textos entre comillas |
| Unidades | Producción en toneladas (`tn`), superficie en hectáreas (`ha`), rendimiento en kg/ha |
| Porcentajes | Escala de 0 a 100 (no fracciones): `2,7` significa 2,7% |
| `campania` | Campaña agrícola como texto: `2019/20` se siembra en 2019 y se cosecha hasta principios de 2020 |
| Nombres geográficos | En mayúsculas y sin tildes, tal como vienen en la fuente (por ejemplo `CORDOBA`) |
| Claves | `provincia_id` se guarda como texto con ceros iniciales (`06`). Al leerlo en R, indicar `colClasses = c(provincia_id = "character")` para no perder el cero |
| Trigo | `cultivo_id` 28 = Trigo total, 29 = Trigo candeal |

### Mapa de archivos

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

---

### `estimaciones2020-2026.csv` (datos de trabajo)

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

### `dim_provincia.csv`

Tabla de referencia de las provincias presentes en los datos.

| Campo | Tipo | Descripción | Ejemplo |
|---|---|---|---|
| `provincia_id` | texto | Código INDEC de 2 dígitos, con cero inicial | 06 |
| `provincia` | texto | Nombre de la provincia | BUENOS AIRES |

**Para qué sirve:** unir las tablas con capas de mapas (QGIS), que traen el código de
provincia, y asignarle un código a las tablas provinciales, que se unen por el campo
`provincia`.

---

### `trigo_candeal_vs_total_provincial.csv`

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

### `trigo_candeal_vs_total_nacional.csv`

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

### `trigo_sembrada_vs_cosechada_provincial.csv`

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

### `trigo_sembrada_vs_cosechada_campania.csv`

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

### `trigo_sembrada_vs_cosechada_nacional.csv`

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

### `trigo_total_departamental.csv`

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

### Aclaración sobre "no cosechada"

`no_cosechada_ha` y `pct_no_cosechado` son una diferencia entre dos columnas de la fuente.
**No indican la causa** de la diferencia (sequía, helada, granizo, uso del lote para pastoreo
u otros motivos), por lo que no deben leerse como pérdidas confirmadas.

### Relaciones entre archivos y controles

- La suma de `total_tn` de todas las provincias, por campaña, da el valor de
  `trigo_candeal_vs_total_nacional.csv`. En 2025/26: 27.886.449 t.
- La suma de `sup_sembrada_ha` del archivo provincial da 45.772.168 ha y la de
  `sup_cosechada_ha`, 43.869.667 ha (diferencia: 1.902.501 ha, 4,2%).
- Las 1.785 filas de `trigo_total_departamental.csv` equivalen a las filas de trigo total
  (`cultivo_id` 28) del archivo de trabajo, y su suma de `produccion_tn` por campaña coincide con
  `total_tn` del archivo nacional.
- Los archivos provinciales se unen entre sí por `provincia` (y `campania` cuando corresponde)
  y con `dim_provincia.csv` por `provincia`.
