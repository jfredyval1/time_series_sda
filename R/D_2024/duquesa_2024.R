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
h <- excel_sheets('/media/disk1//DISPOSITIVOS_USUARIOS_2025/DUQUESA 24.xlsx')
duquesa <- lectura_excel(ruta_archivo = '/media/disk1//DISPOSITIVOS_USUARIOS_2025/DUQUESA 24.xlsx',
                        filas_a_ignorar = c(rep(5,12)),
                        hoja_ignorar =h[!grepl('Datos', h)]) 
# Eliminar vector h
rm(h)
# Casos especiales previa estandarización de datos

# names(d_2024$datos[['pz-11-012']])[7] <- 'temp_baro'
# names(d_2024$datos[['pz-11-012']])[10] <- 'conductividad_cruda_NA'
# names(d_2024$datos[['pz-11-012']])[4] <- 'presion_b1_preguntar'
# names(d_2024$datos[['pz-11-012']])[6] <- 'presion_b1_preguntar_2'
# Estandarizar y filtrar
duquesa$datos <- estandarizar(df = duquesa$datos,
             nom_estandar = nom_estandar, # Variable definida en modulo 02
             nombres_df = nombres_df, # Variable definida en modulo 02
             nom_pozo = duquesa$hojas) 
# Asumiendo frecuencias horaria
# ¿ Cuantos días completos se han monitoreado en 2024 ?
#

# Conocer número total de días monitoreados en 2024
for (i in 1:length(duquesa$datos)) {
  dias <-round(dim(duquesa$datos[[i]])[1] / 24,1)
  print(paste('El pozo',names(duquesa$datos)[i], 'tuvo', dias, 'dias completos monitoreado'))
}

# Una vez estandarizadas y filtradas las variables de interés
# es necesario verificar y homogeneizar el tipo de dato y su estructura
# para cada una de las variables en cada uno de los pozos

#
# Estandarizar tipos de datos
#

# Casos especiales: usar la información de hora para la columna fecha
# Usar dato de hora en fecha
duquesa$datos <- lapply(duquesa$datos, function(df) {
  df$fecha <- df$hora
  return(df)  # Aquí sí necesitas return porque es dentro de una función
})

# Estandarizar formato de fecha
duquesa$datos<-estandarizar_fechas_simple(datos = duquesa$datos,
                            columna_fecha = "fecha",
                            formato_salida = "%Y-%m-%d",
                            con_hora = FALSE)
# Estandarizar formato de hora
duquesa$datos <- extraer_hora(datos = duquesa$datos,
                  columna_hora = 'hora',
                  formato_salida ="%H:%M:%S",#"%H:%M"
                  como_caracter = F)

# Estandarizar formato de variables temáticas
duquesa$datos <- variables_tematicas(datos =duquesa$datos,
                    pozo_nom =duquesa$hojas,
                    variable = nom_estandar[3:7])

#
# Finalizada la estandarización es posible reemplazar, eliminar variables temporales, y unificar
#


# Unificar todos los df en uno solo
duquesa$unificado <- do.call(rbind, duquesa$datos)
duquesa$unificado$id_pozo <- 'pz 009-017'
#
# Pruebas de unificación de formatos
#

# Agrupar por mes y pozo, calcular promedio
datos_mensuales <- duquesa$unificado %>%
  filter(!is.na(profundidad_nivel)) %>%
  mutate(mes = floor_date(fecha, "week")) %>%
  group_by(id_pozo, mes) %>%
  summarise(profundidad_prom = mean(profundidad_nivel), .groups = "drop")

#datos_mensuales <- datos_mensuales[datos_mensuales$id_pozo == 'pz-11-0190',]
# Graficar
ggplot(datos_mensuales, aes(x = mes, y = profundidad_prom * -1)) +
  geom_line(color = "steelblue", linewidth = 1) +
  facet_wrap(~ id_pozo, scales = "free_y") +  # un gráfico por pozo
  labs(
    title = "Variación Mensual del Nivel Freático por Pozo",
    x = "Mes",
    y = "Profundidad Promedio (m)"
  ) +
  #scale_y_reverse() +  # profundidad hacia abajo
  theme_minimal() +
  theme(
    strip.text = element_text(face = "bold"),  # título de cada faceta en negrita
    legend.position = "none"
  )
