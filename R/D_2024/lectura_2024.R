# Lectrua de hojas de datos en hoja de calculo 'Datos 2024'
# Abril 17 de 2025
# R 4.5.0  
# Librerías requeridas
library(readxl)
library(dplyr)
library(lubridate)
# Limpiar área de trabajo
rm(list = ls())
# Lectura de hojas en archivo de interés
path_datos <- '/media/F/DISPOSITIVOS_USUARIOS_2025/DATOS 2024 DISPOSIVOS CONCESIONADOS.xlsx'
hojas <- excel_sheets(path_datos)
# Eliminar hoja sin datos
hojas <- hojas[!hojas == 'Hoja1']

# Definir númeor de filas a ignorar para correcta lectura de datos en cada hoja

row_del <-c(0,21,21,13,0,21,21,0,3,8,9,21,21,9,5,0,0,0,0,21,30,21,21,21,21,21,21,21,21,21,21,21,21)

# Crear lista vacia para almacenar los datos
datos_2024 <- list()
# Vector que guarda nombre de encabezados 
encabezado <- vector()
for (i in 1:length(hojas)) {
  # Estandarizar nombres de df
  name = gsub(' ', '', hojas[i])
  datos_2024[[name]] <- read_excel(path_datos,
                                   sheet = hojas[i], 
                                   skip = row_del[i])
  
  # Reemplazar ',' por '.' en todas las columnas
  datos_2024[[name]] <- datos_2024[[name]] |> 
    mutate(across(everything(), ~ {
      if (is.character(.x)) gsub(",", ".", .x)
      else if (is.factor(.x)) gsub(",", ".", as.character(.x))
      else .x
    }))
  
  # Verificador de lectura
  print(paste('Se ha leído la hoja: ', name))
  
  # Unificar en un vector los nombres de los encabezados
  encabezado <- append(encabezado, names(datos_2024[[name]]))
}
# Reemplazar hojojas por nombres estandarizados
hojas <- names(datos_2024)
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
# Presión barométrica MH20
presion_mh20 <- c("Presión (mH2O)","TBaro \r\r\n[°C]","Presión total (mH2O)","Pressure (MH2O)","Pressure","mH20 (F) \r\r\n[m]")
# Presion PBaro
presion_pb <- c("P1 \r\r\n[bar]","PBaro \r\r\n[bar]","Pd (P1-PBaro) \r\r\n[bar]")
# Temperatura
temp <- c("TEMPERATURE","Tempertura ºC (si aplica)","Temperatura (Celsius)",
          "Temperatura ºC (si aplica)", "Temperatura (ºC)",
          "Temperatura (°C)","Temperatura (Tº)","Temperature (C°)","Temperature",
          "TOB1 \r\r\n[°C]")
# Conductividad
cond <- c("Conductividad (µS/cm) - Si aplica","CONDUCTIVITY","Conductividad",
          "C O N D U C T I V I D A D","Conductivity Tc \r\r\n[mS/cm]",
          "Conductivity raw \r\r\n[mS/cm]","Conductividad (µS/cm) - \r\nSi aplica")
nombres_originales <- list('hora'=hora,
                           'fecha'=fecha,
                           'nivel'=nivel,
                           'temp'=temp,
                           'cond'=cond,
                           'presion_mh20'=presion_mh20,
                           'presion_pb'=presion_pb)
#
# renombrar cambos en df que presentan duplicidad en nombres
names(datos_2024[['pz-11-012']])[7] <- 'temp_baro'
names(datos_2024[['pz-11-012']])[10] <- 'conductividad_cruda_NA'
names(datos_2024[['pz-11-012']])[4] <- 'presion_b1_preguntar'
names(datos_2024[['pz-11-012']])[6] <- 'presion_b1_preguntar_2'
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
# Vector con nombres estandarizados
nomb_estandar <- c('hora','fecha','profundidad_nivel','temperatura','conductividad','presion_total_mh20','presion_parcial_pb')

#renombrado(variable_nuevo = 'hora',nombre_originales = nombres_originales[]])

for (i in 1:length(nombres_originales)) {
  variable <-nomb_estandar[i]
  vec_origen <- unlist(nombres_originales[i],recursive = T,use.names = F)
  renombrado(variable_nuevo =  variable,nombre_original = vec_origen)
}
#
# Filtrar y completar
# Filtrar solo las columnas que están en noms_est
for (i in names(datos_2024)) {
  # Seleccionar las columnas definidicas
  datos_2024[[i]] <-  datos_2024[[i]] %>% select(any_of(nomb_estandar))
  # Agregar las columnas que falten con valores NA
  faltantes <- setdiff(nomb_estandar, names(datos_2024[[i]]))
  datos_2024[[i]][faltantes] <- NA
  # Agregar nombre de pozo
  datos_2024[[i]]$id_pozo <- i
  
}

# Conocer número total de días monitoreoados en 2024

for (i in 1:length(datos_2024)) {
  dias <-round(dim(datos_2024[[i]])[1] / 24,1)
  print(paste('El pozo',names(datos_2024)[i], 'tuvo', dias, 'dias completos monitoreado'))
}
#
# Estandarizar tipos de datos
#

# Hora
# Aplicar conversión a fehca en datos de pozos en particular
datos_2024[["pz-11-0140"]]$hora <- parse_date_time(datos_2024[["pz-11-0140"]]$hora, "I:M:S p")
# Pozo 10-0027
# Reemplazar "a. m"/"p. m" por "AM"/"PM" para que lubridate lo entienda
hora_texto <- gsub("a\\. m", "AM", datos_2024[["pz-10-0027"]]$hora)
hora_texto <- gsub("p\\. m", "PM", hora_texto)
# Parsear la hora
datos_2024[["pz-10-0027"]]$hora <- parse_date_time(hora_texto, orders = "I:M:S p")
# Estandarizar fecha en ymd
datos_2024[["pz-10-0027"]]$fecha <- dmy(datos_2024[["pz-10-0027"]]$fecha)
# Modificación al pozo pz-08-0023
parsear_hora_colombiana <- function(fechas) {
  # Reemplazar espacios invisibles, si los hubiera
  fechas <- gsub("[\u00a0\u202f]", " ", fechas)
  
  # Reemplazar "a. m." y "p. m." por "AM"/"PM"
  fechas <- gsub("a\\. m\\.", "AM", fechas, ignore.case = TRUE)
  fechas <- gsub("p\\. m\\.", "PM", fechas, ignore.case = TRUE)
  
  # Parsear con lubridate
  parse_date_time(fechas, orders = "d/m/Y I:M:S p")
}
datos_2024[["pz-08-0023"]]$hora<-parsear_hora_colombiana(datos_2024[["pz-08-0023"]]$hora)
#
# Estandar Hora: 0 a 24
#
for (pozo in hojas) {
  # Incorporar defenza en caso de eror de formato para convertir la hora
  tryCatch({
    # Intentar la conversión directamente
    datos_2024[[pozo]]$hora_1 <- hour(datos_2024[[pozo]]$hora)
    
  }, error = function(e) {
    # Si ocurre el error de formato, asignar NA y continuar
    if (grepl("formato estándar inequívoco", e$message)) {
      warning(paste("Error de formato de fecha/hora en pozo", pozo, "- Usando NA"))
      datos_2024[[pozo]]$hora_1 <- NA  # Asignar NA y continuar
    }
  })
  # Verificar horas estandarizadas
  print(paste("Horas en pozo", pozo, ":", max(datos_2024[[pozo]]$hora_1)))
}
#
# Estandar Fecha
# 
for (pozo in hojas) {
  # Se fecha está vacio NA, llenarlo con hora
  if (all(is.na(datos_2024[[pozo]]$fecha))) {
    datos_2024[[pozo]]$fecha <- datos_2024[[pozo]]$hora
  }
  # Incorporar defenza en caso de eror de formato para convertir la hora
  tryCatch({
    # Intentar la conversión directamente
    datos_2024[[pozo]]$fecha_1 <- date(datos_2024[[pozo]]$fecha)
    
  }, error = function(e) {
    # Si ocurre el error de formato, asignar NA y continuar
    if (grepl("formato estándar inequívoco", e$message)) {
      warning(paste("Error de formato de fecha/hora en pozo", pozo, "- Usando NA"))
      datos_2024[[pozo]]$fecha_1 <- NA  # Asignar NA y continuar
    }
  })
  # Verificar imprimiendo algunas fechas
  print(paste("Fechas en pozo", pozo, ":", min(datos_2024[[pozo]]$fecha_1)))
}
#Corregir error en 11-0217
#
datos_2024[["pz-11-0217"]]$fecha_1 <- date(datos_2024[["pz-11-0217"]]$fecha_1)
# Estandarizar temperatura
for (pozo in hojas) {
  # Reemplazar ',' por '.' en caso de ser tipo caracter
  if (!is.na(datos_2024[[pozo]]$temperatura[1])) {
    datos_2024[[pozo]]$temperatura <- gsub(",", ".", datos_2024[[pozo]]$temperatura)
  }
  tryCatch({
    # Intentar la conversión directamente
    datos_2024[[pozo]]$temperatura_1 <- as.numeric(datos_2024[[pozo]]$temperatura)
    
  }, error = function(e) {
    # Si ocurre el error de formato, asignar NA y continuar
    if (grepl("formato estándar inequívoco", e$message)) {
      warning(paste("Error de formato de fecha/hora en pozo", pozo, "- Usando NA"))
      datos_2024[[pozo]]$temperatura_1 <- NA  # Asignar NA y continuar
    }
  })
  # Verificar imprimiendo algunas fechas
  print(paste("Temperaturas en pozo", pozo, ":", head(datos_2024[[pozo]]$temperatura_1,1)))
}
# Estandarizar nivel
for (pozo in hojas) {
  # Reemplazar ',' por '.' en caso de ser tipo caracter
  if (!is.na(datos_2024[[pozo]]$profundidad_nivel[1])) {
    datos_2024[[pozo]]$profundidad_nivel <- gsub(",", ".", datos_2024[[pozo]]$profundidad_nivel)
  }
  # Incorporar defenza en caso de eror de formato para convertir la hora
  tryCatch({
    # Intentar la conversión directamente
    datos_2024[[pozo]]$profundidad_nivel_1 <- as.numeric(datos_2024[[pozo]]$profundidad_nivel)
    
  }, error = function(e) {
    # Si ocurre el error de formato, asignar NA y continuar
    if (grepl("formato estándar inequívoco", e$message)) {
      warning(paste("Error de formato de fecha/hora en pozo", pozo, "- Usando NA"))
      datos_2024[[pozo]]$profundidad_nivel_1 <- NA  # Asignar NA y continuar
    }
  })
  # Verificar imprimiendo algunas fechas
  print(paste("Niveles en pozo", pozo, ":", median(datos_2024[[pozo]]$profundidad_nivel_1)))
}
# Estandarizar conductividad
for (pozo in hojas) {
  # Reemplazar ',' por '.' en caso de ser tipo caracter
  if (!is.na(datos_2024[[pozo]]$conductividad[1])) {
    datos_2024[[pozo]]$conductividad <- gsub(",", ".", datos_2024[[pozo]]$conductividad)
  }
  # Incorporar defenza en caso de eror de formato para convertir la hora
  tryCatch({
    # Intentar la conversión directamente
    datos_2024[[pozo]]$conductividad_1 <- as.numeric(datos_2024[[pozo]]$conductividad)
    
  }, error = function(e) {
    # Si ocurre el error de formato, asignar NA y continuar
    if (grepl("formato estándar inequívoco", e$message)) {
      warning(paste("Error de formato de fecha/hora en pozo", pozo, "- Usando NA"))
      datos_2024[[pozo]]$conductividad_1 <- NA  # Asignar NA y continuar
    }
  })
  # Verificar imprimiendo algunas fechas
  print(paste("Conductividades en pozo", pozo, ":", head(datos_2024[[pozo]]$conductividad_1,1)))
}
# Estandarizar presion_mh20
for (pozo in hojas) {
  # Reemplazar ',' por '.' en caso de ser tipo caracter
  if (!is.na(datos_2024[[pozo]]$presion_total_mh20[1])) {
    datos_2024[[pozo]]$presion_total_mh20 <- gsub(",", ".", datos_2024[[pozo]]$presion_total_mh20)
  }
  # Incorporar defenza en caso de eror de formato para convertir la hora
  tryCatch({
    # Intentar la conversión directamente
    datos_2024[[pozo]]$presion_total_mh20_1 <- as.numeric(datos_2024[[pozo]]$presion_total_mh20)
    
  }, error = function(e) {
    # Si ocurre el error de formato, asignar NA y continuar
    if (grepl("formato estándar inequívoco", e$message)) {
      warning(paste("Error de formato de fecha/hora en pozo", pozo, "- Usando NA"))
      datos_2024[[pozo]]$presion_total_mh20_1 <- NA  # Asignar NA y continuar
    }
  })
  # Verificar imprimiendo algunas fechas
  print(paste("Presiones mh20 en pozo", pozo, ":", head(datos_2024[[pozo]]$presion_total_mh20_1,1)))
}
# Estandarizar presion_pb
for (pozo in hojas) {
  # Reemplazar ',' por '.' en caso de ser tipo caracter
  if (!is.na(datos_2024[[pozo]]$presion_parcial_pb[1])) {
    datos_2024[[pozo]]$presion_parcial_pb <- gsub(",", ".", datos_2024[[pozo]]$presion_parcial_pb)
  }
  # Incorporar defenza en caso de eror de formato para convertir la hora
  tryCatch({
    # Intentar la conversión directamente
    datos_2024[[pozo]]$presion_parcial_pb_1 <- as.numeric(datos_2024[[pozo]]$presion_parcial_pb)
    
  }, error = function(e) {
    # Si ocurre el error de formato, asignar NA y continuar
    if (grepl("formato estándar inequívoco", e$message)) {
      warning(paste("Error de formato de fecha/hora en pozo", pozo, "- Usando NA"))
      datos_2024[[pozo]]$presion_parcial_pb_1 <- NA  # Asignar NA y continuar
    }
  })
  # Verificar imprimiendo algunas fechas
  print(paste("Presiones pb en pozo", pozo, ":", head(datos_2024[[pozo]]$presion_parcial_pb_1,1)))
}
#
# Finalizada la estandarización es posible reemplazar, eliminar variables temporales, y unificar
#
for (pozo in hojas) {
  # Reemplazar variables temporales por estandarizadas
  datos_2024[[pozo]]$hora <- datos_2024[[pozo]]$hora_1
  datos_2024[[pozo]]$fecha <- datos_2024[[pozo]]$fecha_1
  datos_2024[[pozo]]$temperatura <- datos_2024[[pozo]]$temperatura_1
  datos_2024[[pozo]]$profundidad_nivel <- datos_2024[[pozo]]$profundidad_nivel_1
  datos_2024[[pozo]]$conductividad <- datos_2024[[pozo]]$conductividad_1
  datos_2024[[pozo]]$presion_total_mh20 <- datos_2024[[pozo]]$presion_total_mh20_1
  datos_2024[[pozo]]$presion_parcial_pb <- datos_2024[[pozo]]$presion_parcial_pb_1
  # Eliminar variables temporales
  datos_2024[[pozo]] <- select(datos_2024[[pozo]], -ends_with("_1"))
}
## Dividir valores de pozo pz-11-0140
datos_2024[["pz-11-0140"]]$profundidad_nivel <- datos_2024[["pz-11-0140"]]$profundidad_nivel/1000
datos_2024[["pz-11-0140"]]$temperatura <- datos_2024[["pz-11-0140"]]$temperatura/1000
datos_2024[["pz-11-0140"]]$presion_total_mh20 <- datos_2024[["pz-11-0140"]]$presion_total_mh20/1000

# Unificar todos los df en uno solo
datos_2024_unificado <- do.call(rbind, datos_2024)
# Filtrar
datos_2024_unificado<-datos_2024_unificado[datos_2024_unificado$fecha >2023,]
datos_2024_unificado<-datos_2024_unificado[datos_2024_unificado$id_pozo != 'pz-01-0004',]
summary(datos_2024_unificado)

#
# Pruebas de unificación de formatos
#

# Agrupar por mes y pozo, calcular promedio
datos_mensuales <- datos_2024_unificado %>%
  filter(!is.na(profundidad_nivel)) %>%
  mutate(mes = floor_date(fecha, "week")) %>%
  group_by(id_pozo, mes) %>%
  summarise(profundidad_prom = mean(profundidad_nivel), .groups = "drop")

datos_mensuales <- datos_mensuales[datos_mensuales$id_pozo == 'pz-11-0190',]
# Graficar
ggplot(datos_mensuales, aes(x = mes, y = profundidad_prom *-1, color = id_pozo)) +
  geom_line(size = 1) +
  labs(
    title = "Variación Mensual del Nivel Freático por Pozo",
    x = "Mes",
    y = "Profundidad Promedio (m)",
    color = "Pozo"
  ) +
  scale_y_reverse() +  # profundidad hacia abajo
  theme_minimal() +
  theme(legend.position = "bottom")
