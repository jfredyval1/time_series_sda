#
# Estandarización de variables temáticas
#

# datos[[nombre_df]][[columna_fecha]]
#datos[[pozo_nom]][[variable]]
variables_tematicas <- function(datos,pozo_nom,variable) {
  
  # Recorrer variables a estandarizar
  for (var in variable) {
    
    # Recorrer datos estandarizando variables
    for (pozo in pozo_nom) {
      # Reemplazar ',' por '.' en caso de ser tipo caracter
      if (!is.na(datos[[pozo]][[var]][1])) {
        datos[[pozo]][[var]] <- gsub(",", ".", datos[[pozo]][[var]])
      }
      # Incorporar defenza en caso de eror de formato para convertir la hora
      tryCatch({
        # Intentar la conversión directamente
        datos[[pozo]][[var]] <- as.numeric(datos[[pozo]][[var]])
        
      }, error = function(e) {
        # Si ocurre el error de formato, asignar NA y continuar
        if (grepl("formato estándar inequívoco", e$message)) {
          warning(paste("Error de formato de fecha/hora en pozo", pozo, "- Usando NA"))
          datos[[pozo]][[var]] <- NA  # Asignar NA y continuar
          }
        })
      # Verificar imprimiendo algunas fechas
      print(paste("Niveles en pozo", pozo, ":", median(datos[[pozo]][[var]])))
      }
    # Retornar variables estandarizadas
    return(datos)
    }
  }

# Estandarizar nivel
