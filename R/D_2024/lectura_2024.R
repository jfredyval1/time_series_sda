# Lectrua de hojas de datos en hoja de calculo 'Datos 2024'
# Abril 17 de 2025
# R 4.5.0  
# Librerías requeridas
library(readxl)
library(dplyr)
# Limpiar área de trabajo
rm(list = ls())
# Lectura de hojas en archivo de interés
hojas <- excel_sheets('/media/F/DISPOSITIVOS_USUARIOS_2025/DATOS 2024 DISPOSIVOS CONCESIONADOS.xlsx')
# Eliminar hoja sin datos
hojas <- hojas[!hojas == 'Hoja1']

# Definir númeor de filas a ignorar para correcta lectura de datos en cada hoja

row_del <-c(0,21,21,13,0,21,21,0,3,8,9,21,21,9,5,0,0,0,0,21,30,21,21,21,21,21,21,21,21,21,21,21,21)


datos_2024 <- list()
# Vector que guarda nombre de encabezados 
encabezado <- vector()
for (i in 1:length(hojas)) {
  datos_2024[[hojas[i]]] <- read_excel("/media/F/DISPOSITIVOS_USUARIOS_2025/DATOS 2024 DISPOSIVOS CONCESIONADOS.xlsx", 
                                                    sheet = hojas[i], skip = row_del[i])
  # Verifivador de lectura
  print(paste('Se ha leido la hoja: ',hojas[i]))
  # Unificar en un vector los nombres de los encabezados
  encabezado <- append(encabezado,names(datos_2024[[hojas[i]]]))
}
# Definir ecabezados unicos eliminando repeticiones
encabezado <- unique(encabezado)
#
# Organizar nombres de columna por tipo de variables
#
# Hora
hora <- c("Time","Hora","HORA","Fecha y Hora","Timestamp","T I M E",
          "Datetime \r\r\n[local time]\r\r\nUTC","TimeStamp")
# Marca temporal - Fecha
fecha <- c("Date","Fecha",
           "D A T E",
           "Datetime \r\r\n[UTC]","FECHA")
# Nivel
nivel <- c("LEVEL","Nivel [m]","Nivel de agua (metro ToC)","Nivel","N I V E L",
           "NIVEL","Nivel hidrodinámico (m)","WaterLevel (MTS)","Nivel hidrodinamico")
# Presión barométrica
presion <- c("Presión (mH2O)","P1 \r\r\n[bar]",
             "PBaro \r\r\n[bar]","TBaro \r\r\n[°C]","Pd (P1-PBaro) \r\r\n[bar]",
             "Presión total (mH2O)","Pressure (MH2O)","Pressure","mH20 (F) \r\r\n[m]")
# Temperatura
temp <- c("TEMPERATURE","Tempertura ºC (si aplica)","Temperatura (Celsius)",
          "Temperatura ºC (si aplica)", "Temperatura (ºC)",
          "Temperatura (°C)","Temperatura (Tº)","Temperature (C°)","Temperature",
          "TOB1 \r\r\n[°C]")
# Conductividad
cond <- c("Conductividad (µS/cm) - Si aplica","CONDUCTIVITY","Conductividad",
          "C O N D U C T I V I D A D","Conductivity Tc \r\r\n[mS/cm]",
          "Conductivity raw \r\r\n[mS/cm]","Conductividad (µS/cm) - \r\nSi aplica")
# Vector con nombres estandarizados
nomb_estandar <- c('hora'=0,'fecha'=1,'prof_nivel'=2,'temperatura'=3,'conductividad'=4,'presion'=5)
#
# renombrar cambos en df que presentan duplicidad en nombres
names(datos_2024[['pz-11-012']])[7] <- 'temp_baro'
# Cambiar por nombre estandar en lod df dentro de la lista
# Definir función para el renombrado
renombrado <- function(variable_nuevo, nombre_originales) {
  for (i in hojas) {
    # Encontrar más de un nombre por df que alude a una variable
    nombres_originales <- names(datos_2024[[i]])
    coinciden <- intersect(nombres_originales, nombre_originales)
    # Implementar renombrado condicional
    if (length(coinciden) == 1) {
      datos_2024[[i]] <<- datos_2024[[i]] |>
        # Renombrar columnas de la variable indicada
        rename(!!variable_nuevo := any_of(nombre_originales))
    } # En caso de duplicidad, indicar en donde se presenta 
    else if (length(coinciden) > 1) {
      warning(glue::glue("Hoja {i} tiene múltiples columnas que coinciden: {paste(coinciden, collapse = ', ')}"))
    }
  }
}
# Renombrar
renombrado(variable = 'hora',nombre_original = hora)
renombrado(variable = 'fecha',nombre_original = fecha)
renombrado(variable = 'profundidad_nivel',nombre_original = nivel)
renombrado(variable = 'presion_baro',nombre_original = presion)
renombrado(variable = 'temperatura',nombre_original = temp)
renombrado(variable = 'conductividad',nombre_original = cond)