# Lectura de hojas de datos en hoja de calculo 'Datos 2024'
# Abril 17 de 2025
# R 4.5.0  
# Librerías requeridas
library(readxl)
library(dplyr)
library(lubridate)
library(ggplot2)
# Limpiar área de trabajo
rm(list = ls())
# Importar funciones
source('01_Lectura.R')
source('02_Estandarizar_Filtrar.R')
source('03_Fecha_Hora.R')
source('04_Variables.R')
# Lectura
d_2024<-lectura_excel(ruta_archivo ='/media/F/DISPOSITIVOS_USUARIOS_2025/DATOS 2024 DISPOSIVOS CONCESIONADOS.xlsx',
              hoja_ignorar = 'Hoja1',
              filas_a_ignorar = c(0,21,21,13,0,21,21,0,3,8,9,21,21,9,5,0,0,0,0,21,30,21,21,21,21,21,21,21,21,21,21,21,21))
# Casos especiales previa estandarización de datos
names(d_2024$datos[['pz-11-012']])[7] <- 'temp_baro'
names(d_2024$datos[['pz-11-012']])[10] <- 'conductividad_cruda_NA'
names(d_2024$datos[['pz-11-012']])[4] <- 'presion_b1_preguntar'
names(d_2024$datos[['pz-11-012']])[6] <- 'presion_b1_preguntar_2'
# Estandarizar y filtrar
d_2024$datos <- estandarizar(df = d_2024$datos,
             nom_estandar = nom_estandar, # Variable definida en modulo 02
             nombres_df = nombres_df, # Variable definida en modulo 02
             nom_pozo = d_2024$hojas)

# Asumiendo frecuencias horaria
# ¿ Cuantos días completos se han monitoreado en 2024 ?
#

# Conocer número total de días monitoreados en 2024
for (i in 1:length(d_2024$datos)) {
  dias <-round(dim(d_2024$datos[[i]])[1] / 24,1)
  print(paste('El pozo',names(d_2024$datos)[i], 'tuvo', dias, 'dias completos monitoreado'))
}

# Una vez estandarizadas y filtradas las variables de interés
# es necesario verificar y homogeneizar el tipo de dato y su estructura
# para cada una de las variables en cada uno de los pozos


#
# Estandarizar tipos de datos
#
# Casos especiales: usar la información de hora para la columna fecha
d_2024$datos[["pz-09-0059"]]$fecha <- d_2024$datos[["pz-09-0059"]]$hora
d_2024$datos[["pz-08-0023"]]$fecha <- d_2024$datos[["pz-08-0023"]]$hora
d_2024$datos[["pz-11-0096"]]$fecha <- d_2024$datos[["pz-11-0096"]]$hora
d_2024$datos[["pz-11-0222"]]$fecha <- d_2024$datos[["pz-11-0222"]]$hora

# Estandarizar formato de fecha
d_2024$datos<-estandarizar_fechas_simple(datos = d_2024$datos,
                            columna_fecha = "fecha",
                            formato_salida = "%Y-%m-%d",
                            con_hora = FALSE)
# Estandarizar formato de hora
d_2024$datos <- extraer_hora(datos = d_2024$datos,
                  columna_hora = 'hora',
                  formato_salida ="%H:%M:%S",#"%H:%M"
                  como_caracter = F)

# Estandarizar formato de variables temáticas
d_2024$datos <- variables_tematicas(datos =d_2024$datos,
                    pozo_nom =d_2024$hojas,
                    variable = nom_estandar[3:7])

#
# Finalizada la estandarización es posible reemplazar, eliminar variables temporales, y unificar
#

## Dividir valores de pozo pz-11-0140
d_2024$datos[["pz-11-0140"]]$profundidad_nivel <- d_2024$datos[["pz-11-0140"]]$profundidad_nivel/1000
d_2024$datos[["pz-11-0140"]]$temperatura <- d_2024$datos[["pz-11-0140"]]$temperatura/1000
d_2024$datos[["pz-11-0140"]]$presion_total_mh20 <- d_2024$datos[["pz-11-0140"]]$presion_total_mh20/1000

# Unificar todos los df en uno solo
d_2024$unificado <- do.call(rbind, d_2024$datos)
#
# Pruebas de unificación de formatos
#

# Agrupar por mes y pozo, calcular promedio
datos_mensuales <- d_2024$unificado %>%
  filter(!is.na(profundidad_nivel)) %>%
  mutate(mes = floor_date(fecha, "hour")) %>%
  group_by(id_pozo, mes) %>%
  summarise(profundidad_prom = mean(profundidad_nivel), .groups = "drop")

#datos_mensuales <- datos_mensuales[datos_mensuales$id_pozo == 'pz-11-0190',]
# Graficar
ggplot(datos_mensuales, aes(x = mes, y = profundidad_prom * -1)) +
  geom_line(color = "steelblue", size = 1) +
  facet_wrap(~ id_pozo, scales = "free_y") +  # un gráfico por pozo
  labs(
    title = "Variación Mensual del Nivel Freático por Pozo",
    x = "Mes",
    y = "Profundidad Promedio (m)"
  ) +
  scale_y_reverse() +  # profundidad hacia abajo
  theme_minimal() +
  theme(
    strip.text = element_text(face = "bold"),  # título de cada faceta en negrita
    legend.position = "none"
  )
