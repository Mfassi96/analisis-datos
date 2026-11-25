# =====================================================================
# 01_dim_provincia.R
# Tabla de provincias con su código INDEC de 2 dígitos (como texto).
#
# Entrada : 2__transformacion/estimaciones2020-2026.csv
# Salida  : 2__transformacion/dim_provincia.csv
#
# Se ejecuta completo (Source o Ctrl+A + Ctrl+Enter).
# =====================================================================

# ---- 1. Rutas ------------------------------------------------------
proyecto <- "/mnt/DiscoExtra/diplomatura_datos/proyecto_final/proyecto_analisis-trigo"
carpeta  <- file.path(proyecto, "2__transformacion")
archivo  <- file.path(carpeta, "estimaciones2020-2026.csv")

stopifnot(file.exists(archivo))

# ---- 2. Cargar -----------------------------------------------------
datos <- read.csv(archivo)
stopifnot(nrow(datos) == 20712)

# ---- 3. Provincias únicas (columnas 1 y 2, por posición) -----------
provincias <- unique(datos[, 1:2])
names(provincias) <- c("provincia_id", "provincia")
provincias <- provincias[order(provincias$provincia_id), ]
rownames(provincias) <- NULL

# Código de 2 dígitos como texto: 6 -> "06"
provincias$provincia_id <- sprintf("%02d", provincias$provincia_id)

# ---- 4. Controles --------------------------------------------------
stopifnot(nrow(provincias) == 15)
stopifnot(!anyDuplicated(provincias$provincia_id))

cat("\nControles OK.\n\n")
print(provincias, row.names = FALSE)

# ---- 5. Guardar ----------------------------------------------------
write.csv(provincias, file.path(carpeta, "dim_provincia.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")

cat("\nArchivo guardado en:", carpeta, "\n")
