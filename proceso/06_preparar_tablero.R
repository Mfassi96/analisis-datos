# =====================================================================
# 06_preparar_tablero.R
# Prepara tres tablas para Looker Studio (nacional, provincial y
# departamental), todas por campaña y con medidas SUMABLES:
#
#   sup_sembrada_ha, sup_cosechada_ha, no_cosechada_ha,
#   total_tn (trigo total), candeal_tn, pan_tn (total - candeal)
#
# Los cocientes (rendimiento, % no cosechado, % candeal) NO se guardan:
# en Looker Studio se definen como campos calculados, para que se
# recalculen bien al filtrar o agrupar (promediar porcentajes da mal).
#
# Entrada : 2__transformacion/estimaciones2020-2026.csv
# Salidas : 3_tablero/tablero_nacional_campania.csv
#           3_tablero/tablero_provincial_campania.csv
#           3_tablero/tablero_departamental_campania.csv
#
# Se ejecuta completo (Source o Ctrl+A + Ctrl+Enter). No depende de
# objetos creados antes en la sesión.
# =====================================================================

options(scipen = 999)

# ---- 1. Rutas ------------------------------------------------------
proyecto <- "/mnt/DiscoExtra/diplomatura_datos/proyecto_final/proyecto_analisis-trigo"
archivo  <- file.path(proyecto, "2__transformacion", "estimaciones2020-2026.csv")
salida   <- file.path(proyecto, "3_tablero")

stopifnot(file.exists(archivo))
dir.create(salida, showWarnings = FALSE)

# ---- 2. Cargar y renombrar columnas por posición -------------------
datos <- read.csv(archivo)
stopifnot(nrow(datos) == 20712)

names(datos) <- c("provincia_id", "provincia", "dep_id", "departamento",
                  "cultivo_id", "cultivo", "campania_id", "campania",
                  "sup_sembrada_ha", "sup_cosechada_ha",
                  "produccion_tn", "rendimiento_kgha")

# ---- 3. Trigo total (28) y candeal (29), con código INDEC ----------
total <- datos[datos$cultivo_id == 28, ]
cand  <- datos[datos$cultivo_id == 29, ]
stopifnot(nrow(total) == 1785, nrow(cand) == 415)

codigo <- function(d) sprintf("%05d", as.integer(d$provincia_id) * 1000L + as.integer(d$dep_id))
total$depto_id <- codigo(total)
cand$depto_id  <- codigo(cand)

# ---- 4. Tabla departamental ----------------------------------------
dep <- aggregate(cbind(sup_sembrada_ha, sup_cosechada_ha, produccion_tn) ~
                   depto_id + provincia + departamento + campania,
                 data = total, FUN = sum)
names(dep)[names(dep) == "produccion_tn"] <- "total_tn"

cdep <- aggregate(produccion_tn ~ depto_id + campania, data = cand, FUN = sum)
names(cdep)[names(cdep) == "produccion_tn"] <- "candeal_tn"

dep <- merge(dep, cdep, by = c("depto_id", "campania"), all.x = TRUE)
dep$candeal_tn[is.na(dep$candeal_tn)] <- 0       # sin candeal = 0
dep$pan_tn          <- dep$total_tn - dep$candeal_tn
dep$no_cosechada_ha <- dep$sup_sembrada_ha - dep$sup_cosechada_ha

medidas <- c("sup_sembrada_ha", "sup_cosechada_ha", "no_cosechada_ha",
             "total_tn", "candeal_tn", "pan_tn")

dep <- dep[, c("depto_id", "provincia", "departamento", "campania", medidas)]
dep <- dep[order(dep$campania, -dep$total_tn), ]
rownames(dep) <- NULL

# ---- 5. Tabla provincial y nacional (suman la departamental) -------
prov <- aggregate(dep[, medidas], by = list(provincia = dep$provincia,
                                            campania  = dep$campania), FUN = sum)
prov <- prov[order(prov$campania, -prov$total_tn), ]
rownames(prov) <- NULL

nac <- aggregate(prov[, medidas], by = list(campania = prov$campania), FUN = sum)
nac <- nac[order(nac$campania), ]
rownames(nac) <- NULL

# ---- 6. Controles (el script se detiene si algo no coincide) -------
stopifnot(nrow(nac) == 7, nrow(prov) == 96, nrow(dep) == 1785)
stopifnot(length(unique(dep$depto_id)) == 269)

for (tab in list(nac, prov, dep)) {
  stopifnot(sum(tab$sup_sembrada_ha)  == 45772168)
  stopifnot(sum(tab$sup_cosechada_ha) == 43869667)
  stopifnot(sum(tab$no_cosechada_ha)  == 1902501)
  stopifnot(sum(tab$total_tn)         == 134377249)
  stopifnot(sum(tab$candeal_tn)       == 2222136)
  stopifnot(sum(tab$pan_tn)           == 132155113)
}

u <- prov[prov$campania == "2025/26", ]
stopifnot(sum(u$total_tn) == 27886449)
top5 <- head(u$provincia, 5)
stopifnot(identical(top5, c("BUENOS AIRES", "SANTA FE", "CORDOBA",
                            "ENTRE RIOS", "SANTIAGO DEL ESTERO")))

cat("\nControles OK.\n")

cat("\nTop 5 provincias por producción de trigo total, 2025/26:\n")
print(u[1:5, c("provincia", "total_tn")], row.names = FALSE)
cat("Participación del top 5 en 2025/26:",
    round(sum(u$total_tn[1:5]) / sum(u$total_tn) * 100, 1), "% (esperado: 93,4)\n")

cat("\nNacional por campaña:\n")
print(nac, row.names = FALSE)

# ---- 7. Guardar ----------------------------------------------------
write.csv(nac,  file.path(salida, "tablero_nacional_campania.csv"),
          row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.csv(prov, file.path(salida, "tablero_provincial_campania.csv"),
          row.names = FALSE, na = "", fileEncoding = "UTF-8")
write.csv(dep,  file.path(salida, "tablero_departamental_campania.csv"),
          row.names = FALSE, na = "", fileEncoding = "UTF-8")

cat("\nArchivos guardados en:", salida, "\n")