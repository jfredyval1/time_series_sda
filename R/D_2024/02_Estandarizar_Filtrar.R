#
# Modulo de estandarización de nombres en columnas
#
# Renomrbados específicos
# renombrar cambios en df que presentan duplicidad en nombres

# Multiples df traen consigo desiguales número de columas
# y nombres, para estandarizar se ha propuesto identificar por grupos
#  aqueelos nombres de columnas que se refieren a una de las siguietnes temáticas:
# 1. Hora
# 2. Fecha
# 3. Profundidad del nivel
# 4. Temperatura
# 5. Conductividad eléctrica
# 6. Presión Total
# 7. Presión parcial

# Nombres extradios del libro de datos para 2024
hora <- c("Time","Hora","HORA","Fecha y Hora","Timestamp","T I M E",
          "Datetime \r\r\n[local time]\r\r\nUTC","TimeStamp")
# Marca temporal - Fecha
fecha <- c("Date","Fecha",
           "D A T E",
           "Datetime \r\r\n[UTC]","FECHA")
# Nivel
nivel <- c("LEVEL","Nivel [m]","Nivel de agua (metro ToC)","Nivel","N I V E L",
           "NIVEL","Nivel hidrodinámico (m)","WaterLevel (MTS)","Nivel hidrodinamico")
# Temperatura
temp <- c("TEMPERATURE","Tempertura ºC (si aplica)","Temperatura (Celsius)",
          "Temperatura ºC (si aplica)", "Temperatura (ºC)",
          "Temperatura (°C)","Temperatura (Tº)","Temperature (C°)","Temperature",
          "TOB1 \r\r\n[°C]")
# Conductividad
cond <- c("Conductividad (µS/cm) - Si aplica","CONDUCTIVITY","Conductividad",
          "C O N D U C T I V I D A D","Conductivity Tc \r\r\n[mS/cm]",
          "Conductivity raw \r\r\n[mS/cm]","Conductividad (µS/cm) - \r\nSi aplica")
# Presión barométrica MH20
presion_mh20 <- c("Presión (mH2O)","TBaro \r\r\n[°C]","Presión total (mH2O)","Pressure (MH2O)","Pressure","mH20 (F) \r\r\n[m]")
# Presion PBaro
presion_pb <- c("P1 \r\r\n[bar]","PBaro \r\r\n[bar]","Pd (P1-PBaro) \r\r\n[bar]")

# Nombres originales ordenados por temática
nombres_df <- list('hora'=hora,
                           'fecha'=fecha,
                           'nivel'=nivel,
                           'temp'=temp,
                           'cond'=cond,
                           'presion_mh20'=presion_mh20,
                           'presion_pb'=presion_pb)
# Nombres estandarizados
nom_estandar <- c('hora','fecha','profundidad_nivel','temperatura','conductividad','presion_total_mh20','presion_parcial_pb')
# Definir función de estandarización
# Función para renombrar columnas en múltiples dataframes
renombrado <- function(df, 
                       nombre_nueva_variable,
                       nombre_originales, 
                       nom_pozo) {
  # Se define la función para renombrar las columnas de los dataframes
  for (i in nom_pozo) {
    # Encontrar más de un nombre por df que alude a una variable
    nombres_columnas <- names(df[[i]])
    coinciden <- intersect(nombres_columnas, nombre_originales)
    
    # Implementar renombrado condicional
    if (length(coinciden) == 1) {
      # Renombrar la columna coincidente
      nombres_actuales <- names(df[[i]])
      posicion <- which(nombres_actuales == coinciden[1])
      names(df[[i]])[posicion] <- nombre_nueva_variable
    } 
    # En caso de duplicidad, indicar en donde se presenta 
    else if (length(coinciden) > 1) {
      warning(glue::glue("Hoja {i} tiene múltiples columnas que coinciden: {paste(coinciden, collapse = ', ')}"))
    }
  }
  # Retornar el dataframe modificado
  return(df)
}

# Función que aplica renombrado y luego filtra columnas
estandarizar <- function(df, nom_pozo, nombres_df, nom_estandar) {
  # Primero aplicamos el renombrado para cada categoría
  for (i in 1:length(nombres_df)) {
    variable <- nom_estandar[i]
    vec_origen <- unlist(nombres_df[i], recursive = TRUE, use.names = FALSE)
    
    # Aplicar renombrado para esta categoría
    df <- renombrado(
      df = df,
      nombre_nueva_variable = variable,
      nombre_originales = vec_origen,
      nom_pozo = nom_pozo
    )
  }
  
  # Una vez renombradas todas las columnas, filtramos y completamos
  for (i in nom_pozo) {
    # Seleccionar las columnas definidas
    df[[i]] <- df[[i]] %>% 
      dplyr::select(dplyr::any_of(nom_estandar))
    
    # Agregar las columnas que falten con valores NA
    faltantes <- setdiff(nom_estandar, names(df[[i]]))
    if (length(faltantes) > 0) {
      for (col in faltantes) {
        df[[i]][[col]] <- NA
      }
    }
    
    # Agregar nombre de pozo
    df[[i]]$id_pozo <- i
  }
  
  # Retornar todos los dataframes modificados
  return(df)
}
# # Ejemplo de uso:
# resultado <- estandarizar(
#   df = d_2024$datos,
#   nom_pozo = d_2024$hojas,
#   nombres_df = nombres_df,  # Lista de nombres originales por categoría
#   nom_estandar = nom_estandar  # Vector de nombres estandarizados
# )
