# Autor: John Fredy Valbuena Lozano
# Fecha: Abril 12 de 2025
# Versión R: 4.4.3 - Trophy Case
#
# Librerias
library(sf)
library(leaflet)
library(readr)
# Limpiar área de trabajo
rm(list = ls())
pozos_sda <- read_delim("/media/disk1/TS_SDA_Wells/XLS/pozos_sda.csv", 
                        delim = "|", escape_double = FALSE, trim_ws = TRUE)
# Filtrar campos para contrucción de tabla
pozos_sda <- pozos_sda[,c(1:4,7:8,18,20,22:24,29,30)]
# Normalizar nombres
nombre_cols <- c('id_punto','nombre_predio','nombre_captacion','identificador_alterno',
                 'nombre_organizacion','nit','prof_captacion','acuifero','direccion',
                 'localidad','barrio','norte','este')
names(pozos_sda) <- nombre_cols
# Espacializar
# Convertir a numérico
pozos_sda$este <- as.numeric(gsub(',','.',pozos_sda$este))
pozos_sda$norte <- as.numeric(gsub(',','.',pozos_sda$norte))
# Eliminar vacios
pozos_sda<-pozos_sda[!is.na(pozos_sda$norte),]
# Convertir ne objeto sf
pozos_sda <- st_as_sf(pozos_sda,coords = c('este','norte'),crs=6247)
# Indexar coordenadas como atributos
pozos_sda <- cbind(pozos_sda,st_coordinates(pozos_sda))
pozos_sda$crs <- 'SRID:6247'
# Transformar a MAGNA-SIRGAS
pozos_sda <- st_transform(pozos_sda,st_crs(4686))
# Filtrar puntos cuya ubicación es errada
filtrar <- c('pe-10-0061','isabel.sierra@sanfo.com','pz-11-0222','pz-01-0101')
pozos_sda <- pozos_sda[!pozos_sda$id_punto %in% filtrar,]
# Corregir profundidad de captaciones a numérico
pozos_sda$prof_captacion <- as.numeric(pozos_sda$prof_captacion)

# Visualizar
leaflet() |> addTiles() |> addCircleMarkers(data = pozos_sda,label = pozos_sda$id_punto,popup = pozos_sda$direccion)

