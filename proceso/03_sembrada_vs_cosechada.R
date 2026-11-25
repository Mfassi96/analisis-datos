# =====================================================================
# 03_sembrada_vs_cosechada.R
# Superficie sembrada vs. cosechada de trigo total (pregunta 3)
#
# Entrada : 2__transformacion/estimaciones2020-2026.csv
# Salidas : 2__transformacion/trigo_sembrada_vs_cosechada_provincial.csv
#           2__transformacion/trigo_sembrada_vs_cosechada_campania.csv
#           2__transformacion/trigo_sembrada_vs_cosechada_nacional.csv
#
# Se ejecuta completo (Source o Ctrl+A + Ctrl+Enter). No depende de
# objetos creados antes en la sesión.
#
# Nota: "no cosechada" es la diferencia sembrada - cosechada. El dato no
# indica la causa (clima, pastoreo, abandono): no es una pérdida confirmada.
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

# ---- 4. Acumulado de las 7 campañas por provincia ------------------
acum <- aggregate(cbind(sup_sembrada_ha, sup_cosechada_ha) ~ provincia,
                  data = total, FUN = sum)
acum$no_cosechada_ha  <- acum$sup_sembrada_ha - acum$sup_cosechada_ha
acum$pct_no_cosechado <- round(acum$no_cosechada_ha / acum$sup_sembrada_ha * 100, 1)

# ---- 5. Por provincia y campaña ------------------------------------
camp <- aggregate(cbind(sup_sembrada_ha, sup_cosechada_ha) ~ provincia + campania,
                  data = total, FUN = sum)
camp$no_cosechada_ha  <- camp$sup_sembrada_ha - camp$sup_cosechada_ha
camp$pct_no_cosechado <- round(camp$no_cosechada_ha / camp$sup_sembrada_ha * 100, 1)

# ---- 6. Nacional por campaña ---------------------------------------
nac <- aggregate(cbind(sup_sembrada_ha, sup_cosechada_ha) ~ campania,
                 data = total, FUN = sum)
nac$no_cosechada_ha  <- nac$sup_sembrada_ha - nac$sup_cosechada_ha
nac$pct_no_cosechado <- round(nac$no_cosechada_ha / nac$sup_sembrada_ha * 100, 1)

# ---- 7. Controles (el script se detiene si algo no coincide) -------
stopifnot(sum(acum$sup_sembrada_ha)  == 45772168)
stopifnot(sum(acum$sup_cosechada_ha) == 43869667)
stopifnot(nrow(acum) == 14)
stopifnot(nrow(camp) == 96)    # 14 provincias x 7 campañas, menos 2 (Formosa sin datos en 2019/20 y 2020/21)

cat("\nControles OK.\n")

cat("\nAcumulado 7 campañas, por provincia (de menor a mayor % no cosechado):\n")
print(acum[order(acum$pct_no_cosechado), ], row.names = FALSE)

cat("\nNacional por campaña:\n")
print(nac, row.names = FALSE)

# Tabla ancha: filas = provincia, columnas = campaña (% no cosechado)
ancha <- reshape(camp[, c("provincia", "campania", "pct_no_cosechado")],
                 idvar = "provincia", timevar = "campania", direction = "wide")
names(ancha) <- sub("pct_no_cosechado\\.", "", names(ancha))
cat("\n% no cosechado por provincia y campaña:\n")
print(ancha, row.names = FALSE)

# ---- 8. Guardar ----------------------------------------------------
write.csv(acum, file.path(carpeta, "trigo_sembrada_vs_cosechada_provincial.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
write.csv(camp, file.path(carpeta, "trigo_sembrada_vs_cosechada_campania.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
write.csv(nac,  file.path(carpeta, "trigo_sembrada_vs_cosechada_nacional.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")

cat("\nArchivos guardados en:", carpeta, "\n")
