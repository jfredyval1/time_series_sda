#' Estandarizar fechas de manera simple
#'
#' Función que convierte diferentes formatos de fecha a un formato estándar
#' e informa sobre columnas que solo contienen NA
#'
#' @param datos Lista de dataframes a procesar
#' @param columna_fecha Nombre de la columna de fecha (por defecto: "fecha")
#' @param formato_salida Formato de salida deseado (por defecto: "%Y-%m-%d")
#' @param con_hora Si es TRUE, mantiene información de hora (por defecto: FALSE)
#'
#' @return Lista de dataframes con fechas estandarizadas
estandarizar_fechas_simple <- function(datos, 
                                       columna_fecha = "fecha",
                                       formato_salida = "%Y-%m-%d",
                                       con_hora = FALSE) {
  # Para seguimiento de columnas con NA
  columnas_na <- c()
  
  # Para cada dataframe en la lista
  for (nombre_df in names(datos)) {
    # Eliminar datos NA en columna fecha del df
    datos[[nombre_df]] <- datos[[nombre_df]][!is.na(datos[[nombre_df]][[columna_fecha]]), ]
    # Verificar si existe la columna fecha
    if (!columna_fecha %in% names(datos[[nombre_df]])) {
      message(paste("El dataframe", nombre_df, "no tiene columna", columna_fecha))
      next
    }
    
    # Verificar si la columna tiene solo NAs
    if (all(is.na(datos[[nombre_df]][[columna_fecha]]))) {
      columnas_na <- c(columnas_na, nombre_df)
      message(paste("AVISO: El dataframe", nombre_df, "tiene solo NAs en columna fecha"))
      next
    }
    
    # Obtener clase de la columna fecha
    clase_fecha <- class(datos[[nombre_df]][[columna_fecha]])[1]
    
    # Procesar según el tipo de datos
    if (clase_fecha == "POSIXct" || clase_fecha == "POSIXlt") {
      # Ya es formato fecha, solo estandarizar formato
      if (con_hora) {
        datos[[nombre_df]][[columna_fecha]] <- as.POSIXct(
          format(datos[[nombre_df]][[columna_fecha]], "%Y-%m-%d %H:%M:%S"),
          format = "%Y-%m-%d %H:%M:%S"
        )
      } else {
        # Convertir a solo fecha
        datos[[nombre_df]][[columna_fecha]] <- as.Date(datos[[nombre_df]][[columna_fecha]])
      }
    } else if (clase_fecha == "character") {
      # Intentar varios formatos comunes
      fecha_temp <- NULL
      
      # Verificar formatos comunes
      if (any(grepl("/", datos[[nombre_df]][[columna_fecha]], fixed = TRUE))) {
        # Probar formato d/m/Y
        tryCatch({
          fecha_temp <- as.Date(datos[[nombre_df]][[columna_fecha]], format = "%d/%m/%Y")
        }, error = function(e) {
          # Probar formato Y/m/d
          tryCatch({
            fecha_temp <- as.Date(datos[[nombre_df]][[columna_fecha]], format = "%Y/%m/%d")
          }, error = function(e) {
            fecha_temp <- NULL
          })
        })
      } else {
        # Probar formato ISO estándar
        tryCatch({
          fecha_temp <- as.Date(datos[[nombre_df]][[columna_fecha]])
        }, error = function(e) {
          fecha_temp <- NULL
        })
      }
      
      # Si no se pudo convertir, reportar error
      if (is.null(fecha_temp)) {
        message(paste("ERROR: No se pudo convertir fecha en", nombre_df, 
                      "- formato no reconocido"))
      } else {
        # Asignar fecha convertida
        if (con_hora) {
          # Convertir a POSIXct con hora 00:00:00
          datos[[nombre_df]][[columna_fecha]] <- as.POSIXct(as.character(fecha_temp))
        } else {
          # Mantener como Date
          datos[[nombre_df]][[columna_fecha]] <- fecha_temp
        }
      }
    } else {
      message(paste("AVISO: Tipo de datos no reconocido en", nombre_df, 
                    "-", clase_fecha))
    }
  }
  
  # Mostrar resumen
  if (length(columnas_na) > 0) {
    message("\nResumen: Dataframes con columnas NA:")
    message(paste(columnas_na, collapse = ", "))
  }
  
  return(datos)
}
#
# Extracción de hora
#
#' Extraer solo la hora de diferentes formatos
#'
#' Esta función extrae solo la parte de hora de columnas en diferentes formatos
#' y la devuelve en un formato consistente.
#'
#' @param datos Lista de dataframes a procesar
#' @param columna_hora Nombre de la columna con la hora (por defecto: "hora")
#' @param formato_salida Formato de salida para la hora (por defecto: "%H:%M:%S")
#' @param como_caracter Si es TRUE, devuelve la hora como caracter en vez de POSIXct
#'
#' @return Lista de dataframes con solo la hora extraída
extraer_hora <- function(datos, 
                         columna_hora = "hora",
                         formato_salida = "%H:%M:%S",
                         como_caracter = FALSE) {
  
  # Para cada dataframe en la lista
  for (nombre_df in names(datos)) {
    # Verificar si existe la columna hora
    if (!columna_hora %in% names(datos[[nombre_df]])) {
      message(paste("El dataframe", nombre_df, "no tiene columna", columna_hora))
      next
    }
    
    # Verificar si la columna tiene solo NAs
    if (all(is.na(datos[[nombre_df]][[columna_hora]]))) {
      message(paste("AVISO: El dataframe", nombre_df, "tiene solo NAs en columna hora"))
      next
    }
    
    # Obtener clase de la columna hora
    clase_hora <- class(datos[[nombre_df]][[columna_hora]])[1]
    
    # Procesar según el tipo de datos
    if (clase_hora == "POSIXct" || clase_hora == "POSIXlt") {
      # Extraer solo la hora de objetos POSIXct/POSIXlt
      hora_formateada <- format(datos[[nombre_df]][[columna_hora]], format = formato_salida)
      
      # Si no queremos como caracter, convertir a POSIXct con fecha ficticia
      if (!como_caracter) {
        fecha_ficticia <- as.Date("1970-01-01")
        hora_formateada <- as.POSIXct(paste(fecha_ficticia, hora_formateada), format = "%Y-%m-%d %H:%M:%S")
      }
      
      # Asignar hora extraída
      datos[[nombre_df]][[columna_hora]] <- hora_formateada
      
    } else if (clase_hora == "character") {
      # Intentar extraer solo la hora de cadenas de texto
      valores_hora <- datos[[nombre_df]][[columna_hora]]
      hora_extraida <- rep(NA, length(valores_hora))
      
      # Procesar cada valor
      for (i in seq_along(valores_hora)) {
        if (is.na(valores_hora[i])) next
        
        valor <- valores_hora[i]
        
        # Verificar si contiene fecha+hora (con /)
        if (grepl("/", valor)) {
          # Es una cadena con fecha y hora, extraer solo hora
          partes <- strsplit(valor, " ")[[1]]
          # Tomar la parte que parece hora (normalmente la segunda parte)
          for (parte in partes) {
            if (grepl(":", parte)) {
              valor <- parte
              break
            }
          }
        }
        
        # Limpiar sufijos a.m./p.m.
        valor <- gsub(" a\\. m\\.", "am", valor, ignore.case = TRUE)
        valor <- gsub(" p\\. m\\.", "pm", valor, ignore.case = TRUE)
        valor <- gsub("\\.000", "", valor)
        
        # Intentar convertir a formato de hora
        tryCatch({
          if (grepl("am|pm", valor, ignore.case = TRUE)) {
            # Formato 12 horas
            hora_obj <- strptime(valor, "%I:%M:%S%p")
            if (is.na(hora_obj)) hora_obj <- strptime(valor, "%I:%M%p")
            if (is.na(hora_obj)) hora_obj <- strptime(valor, "%I%p")
          } else {
            # Formato 24 horas
            hora_obj <- strptime(valor, "%H:%M:%S")
            if (is.na(hora_obj)) hora_obj <- strptime(valor, "%H:%M")
          }
          
          if (!is.na(hora_obj)) {
            hora_extraida[i] <- format(hora_obj, formato_salida)
          }
        }, error = function(e) {
          # Si falla, dejar como NA
        })
      }
      
      # Si no queremos como caracter, convertir a POSIXct con fecha ficticia
      if (!como_caracter) {
        fecha_ficticia <- as.Date("1970-01-01")
        hora_extraida <- as.POSIXct(paste(fecha_ficticia, hora_extraida), format = "%Y-%m-%d %H:%M:%S")
      }
      
      # Asignar hora extraída
      datos[[nombre_df]][[columna_hora]] <- hora_extraida
    } else {
      message(paste("AVISO: Tipo de datos no reconocido en", nombre_df, "-", clase_hora))
    }
  }
  
  return(datos)
}
