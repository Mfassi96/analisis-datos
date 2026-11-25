# =====================================================================
# 02_candeal_vs_total.R
# Trigo candeal vs. trigo total por provincia y campaña (preguntas 2 y 4)
#
# Entrada : 2__transformacion/estimaciones2020-2026.csv
# Salidas : 2__transformacion/trigo_candeal_vs_total_provincial.csv
#           2__transformacion/trigo_candeal_vs_total_nacional.csv
#
# Se ejecuta completo (Source o Ctrl+A + Ctrl+Enter). No depende de
# objetos creados antes en la sesión.
# =====================================================================

options(scipen = 999)   # evita notación científica

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

# ---- 3. Filtrar trigo: 28 = Trigo total, 29 = Trigo candeal --------
trigo <- datos[datos$cultivo_id %in% c(28, 29), ]
stopifnot(nrow(trigo) == 2200)

# ---- 4. Separar y unir por provincia + departamento + campaña ------
tot <- trigo[trigo$cultivo_id == 28,
             c("provincia_id", "provincia", "dep_id", "departamento",
               "campania", "produccion_tn")]
can <- trigo[trigo$cultivo_id == 29,
             c("provincia_id", "dep_id", "campania", "produccion_tn")]
names(tot)[6] <- "total_tn"
names(can)[4] <- "candeal_tn"

comp <- merge(tot, can, by = c("provincia_id", "dep_id", "campania"), all.x = TRUE)
comp$candeal_tn[is.na(comp$candeal_tn)] <- 0     # sin candeal = 0
comp$pan_tn <- comp$total_tn - comp$candeal_tn   # trigo pan derivado

# ---- 5. Resumen por provincia y campaña ----------------------------
por_prov <- aggregate(cbind(total_tn, candeal_tn, pan_tn) ~ provincia + campania,
                      data = comp, FUN = sum)
por_prov$pct_candeal <- round(por_prov$candeal_tn / por_prov$total_tn * 100, 1)

# ---- 6. Resumen nacional por campaña -------------------------------
nac_cand <- aggregate(cbind(total_tn, candeal_tn, pan_tn) ~ campania,
                      data = por_prov, FUN = sum)
nac_cand$pct_candeal <- round(nac_cand$candeal_tn / nac_cand$total_tn * 100, 2)

# ---- 7. Controles (el script se detiene si algo no coincide) -------
x <- por_prov[por_prov$campania == "2025/26", ]
stopifnot(sum(x$total_tn)   == 27886449)
stopifnot(sum(x$candeal_tn) == 411083)
stopifnot(sum(x$pan_tn)     == 27475366)

cat("\nControles OK.\n\nPor provincia, campaña 2025/26:\n")
print(x[order(-x$candeal_tn), ], row.names = FALSE)

cat("\nSerie nacional:\n")
print(nac_cand, row.names = FALSE)

# ---- 8. Guardar ----------------------------------------------------
write.csv(por_prov,
          file.path(carpeta, "trigo_candeal_vs_total_provincial.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
write.csv(nac_cand,
          file.path(carpeta, "trigo_candeal_vs_total_nacional.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")

cat("\nArchivos guardados en:", carpeta, "\n")
