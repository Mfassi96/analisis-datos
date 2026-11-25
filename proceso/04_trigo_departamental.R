# =====================================================================
# 04_trigo_departamental.R
# Trigo total por departamento y campaña, con código INDEC (depto_id)
# listo para unir con la capa de departamentos en QGIS.
#
# Entrada : 2__transformacion/estimaciones2020-2026.csv
# Salida  : 2__transformacion/trigo_total_departamental.csv
#
# Se ejecuta completo (Source o Ctrl+A + Ctrl+Enter). No depende de
# objetos creados antes en la sesión.
# =====================================================================

options(scipen = 999)

# ---- 1. Rutas ------------------------------------------------------
proyecto <- "/mnt/DiscoExtra/diplomatura_datos/proyecto_final/proyecto_analisis-trigo"
carpeta  <- file.path(proyecto, "2__transformacion")
archivo  <- file.path(carpeta, "estimaciones2020-2026.csv")

stopifnot(file.exists(archivo))

# ---- 2. Cargar y renombrar columnas por posición -------------------
datos <- read.csv(archivo)
stopifnot(nrow(datos) == 20712)

names(datos) <- c("provincia_id", "provincia", "dep_id", "departamento",
                  "cultivo_id", "cultivo", "campania_id", "campania",
                  "sup_sembrada_ha", "sup_cosechada_ha",
                  "produccion_tn", "rendimiento_kgha")

# ---- 3. Trigo total (cultivo_id 28) --------------------------------
total <- datos[datos$cultivo_id == 28, ]
stopifnot(nrow(total) == 1785)

# ---- 4. Código INDEC de 5 dígitos, como texto ----------------------
# provincia_id * 1000 + dep_id  ->  ej.: 82 * 1000 + 42 = "82042"
total$depto_id <- sprintf("%05d",
                          as.integer(total$provincia_id) * 1000L + as.integer(total$dep_id))

# ---- 5. Tabla departamental por campaña ----------------------------
depto <- aggregate(cbind(sup_sembrada_ha, sup_cosechada_ha, produccion_tn) ~
                     depto_id + provincia + departamento + campania,
                   data = total, FUN = sum)

# Evita división por cero: hay filas con superficie cosechada o sembrada = 0
depto$rendimiento_kgha <- ifelse(depto$sup_cosechada_ha > 0,
                                 round(depto$produccion_tn / depto$sup_cosechada_ha * 1000),
                                 NA)
depto$pct_no_cosechado <- ifelse(depto$sup_sembrada_ha > 0,
                                 round((depto$sup_sembrada_ha - depto$sup_cosechada_ha) /
                                         depto$sup_sembrada_ha * 100, 1),
                                 NA)

depto <- depto[order(depto$campania, -depto$produccion_tn), ]
rownames(depto) <- NULL

# ---- 6. Controles (el script se detiene si algo no coincide) -------
stopifnot(nrow(depto) == 1785)
stopifnot(length(unique(depto$depto_id)) == 269)
stopifnot(sum(is.na(depto$rendimiento_kgha)) == 6)
stopifnot(sum(is.na(depto$pct_no_cosechado)) == 3)

u <- depto[depto$campania == "2025/26", ]
stopifnot(nrow(u) == 265)
stopifnot(u$departamento[1] == "GENERAL LOPEZ", u$produccion_tn[1] == 1212287)

cat("\nControles OK.\n")

cat("\nTop 5 departamentos, campaña 2025/26:\n")
print(head(u, 5), row.names = FALSE)

# Concentración 2025/26 (informativo; valores esperados: 30 y 77 de 265)
acum <- cumsum(u$produccion_tn) / sum(u$produccion_tn)
cat("\nDepartamentos que suman el 50% de la producción:", sum(acum < 0.5) + 1, "de", nrow(u), "\n")
cat("Departamentos que suman el 80% de la producción:", sum(acum < 0.8) + 1, "de", nrow(u), "\n")

# ---- 7. Guardar ----------------------------------------------------
# write.csv entrecomilla el texto, por lo que depto_id conserva el cero inicial.
# Al leerlo de nuevo: read.csv(..., colClasses = c(depto_id = "character"))
write.csv(depto, file.path(carpeta, "trigo_total_departamental.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")

cat("\nArchivo guardado en:", carpeta, "\n")
