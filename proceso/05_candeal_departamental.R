# =====================================================================
# 05_candeal_departamental.R
# Trigo candeal vs. trigo total por departamento y campaña (pregunta 2)
#
# Entrada : 2__transformacion/estimaciones2020-2026.csv
# Salida  : 2__transformacion/trigo_candeal_vs_total_departamental.csv
#
# Se ejecuta completo (Source o Ctrl+A + Ctrl+Enter). No depende de
# objetos creados antes en la sesión.
#
# Supuestos: el trigo total incluye al candeal, por lo que
#   pan_tn = total_tn - candeal_tn (trigo pan derivado).
#   Donde no hay fila de candeal, candeal_tn = 0.
#   pct_candeal queda vacío cuando total_tn = 0 (evita dividir por cero).
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

# ---- 3. Trigo total (28) y trigo candeal (29) ----------------------
total <- datos[datos$cultivo_id == 28, ]
cand  <- datos[datos$cultivo_id == 29, ]
stopifnot(nrow(total) == 1785, nrow(cand) == 415)

# Código INDEC de 5 dígitos, como texto: provincia_id * 1000 + dep_id
codigo <- function(d) sprintf("%05d", as.integer(d$provincia_id) * 1000L + as.integer(d$dep_id))
total$depto_id <- codigo(total)
cand$depto_id  <- codigo(cand)

# ---- 4. Unir total y candeal por departamento y campaña ------------
dep <- aggregate(produccion_tn ~ depto_id + provincia + departamento + campania,
                 data = total, FUN = sum)
names(dep)[names(dep) == "produccion_tn"] <- "total_tn"

cdep <- aggregate(produccion_tn ~ depto_id + campania, data = cand, FUN = sum)
names(cdep)[names(cdep) == "produccion_tn"] <- "candeal_tn"

dep <- merge(dep, cdep, by = c("depto_id", "campania"), all.x = TRUE)
dep$candeal_tn[is.na(dep$candeal_tn)] <- 0
dep$pan_tn      <- dep$total_tn - dep$candeal_tn
dep$pct_candeal <- ifelse(dep$total_tn > 0,
                          round(dep$candeal_tn / dep$total_tn * 100, 1),
                          NA)

dep <- dep[, c("depto_id", "provincia", "departamento", "campania",
               "total_tn", "candeal_tn", "pan_tn", "pct_candeal")]
dep <- dep[order(dep$campania, -dep$total_tn), ]
rownames(dep) <- NULL

# ---- 5. Controles (el script se detiene si algo no coincide) -------
stopifnot(nrow(dep) == 1785)
stopifnot(sum(dep$total_tn)   == 134377249)
stopifnot(sum(dep$candeal_tn) == 2222136)
stopifnot(sum(dep$pan_tn)     == 132155113)
stopifnot(sum(dep$candeal_tn > 0) == 415)          # filas depto-campaña con candeal
stopifnot(all(dep$candeal_tn <= dep$total_tn))     # el candeal nunca supera al total
stopifnot(sum(is.na(dep$pct_candeal)) == 11)       # filas con total_tn = 0
stopifnot(length(unique(dep$depto_id[dep$candeal_tn > 0])) == 100)

cat("\nControles OK.\n")

# ---- 6. Lectura rápida de resultados -------------------------------
cat("\nDepartamentos con candeal por campaña",
    "(esperado: 31, 57, 59, 67, 63, 68, 70):\n")
print(table(dep$campania[dep$candeal_tn > 0]))

u  <- dep[dep$campania == "2025/26", ]
uc <- u[order(-u$candeal_tn), ]

cat("\nTop 5 departamentos por candeal, 2025/26:\n")
print(head(uc, 5), row.names = FALSE)
# Esperado: CORONEL DORREGO 73361 (14.7%), TRES ARROYOS 64825 (10.9%),
#           CORONEL PRINGLES 50559 (14.5%), ADOLFO GONZALES CHAVES 19139 (7.3%),
#           AYACUCHO (San Luis) 15040 (54.7%)

uc <- uc[uc$candeal_tn > 0, ]
acum <- cumsum(uc$candeal_tn) / sum(uc$candeal_tn)
cat("\nDepartamentos con candeal en 2025/26:", nrow(uc), "(esperado: 70)\n")
cat("Suman el 50% del candeal:", sum(acum < 0.5) + 1, "(esperado: 4)\n")
cat("Suman el 80% del candeal:", sum(acum < 0.8) + 1, "(esperado: 16)\n")

cat("\nDepartamentos donde el candeal es el 50% o más del trigo, 2025/26",
    "(esperado: AYACUCHO, JUNIN y CAPITAL de Salta):\n")
print(u[!is.na(u$pct_candeal) & u$pct_candeal >= 50,
        c("provincia", "departamento", "total_tn", "candeal_tn", "pct_candeal")],
      row.names = FALSE)

ac <- aggregate(candeal_tn ~ depto_id + provincia + departamento, data = dep, FUN = sum)
ac <- ac[order(-ac$candeal_tn), ]
cat("\nTop 5 departamentos por candeal, 7 campañas acumuladas:\n")
print(head(ac, 5), row.names = FALSE)
# Esperado: CORONEL DORREGO 555901, TRES ARROYOS 238469, CORONEL PRINGLES 230981,
#           ANTA (Salta) 104371, TANDIL 81778

# ---- 7. Guardar ----------------------------------------------------
# na = "" deja vacío pct_candeal donde total_tn = 0
write.csv(dep, file.path(carpeta, "trigo_candeal_vs_total_departamental.csv"),
          row.names = FALSE, na = "", fileEncoding = "UTF-8")

cat("\nArchivo guardado en:", carpeta, "\n")