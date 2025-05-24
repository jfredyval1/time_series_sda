#
# Modulo de lectura
# 

# Lectura de libro excel con datos por hoja en donde cada una corresponde a un
# pozo monitoreado
lectura_excel <- function(ruta_archivo, filas_a_ignorar = 0,hoja_ignorar = NULL) {
  hojas <- excel_sheets(ruta_archivo)
  # Eliminar hoja sin datos
  hojas <- hojas[!hojas %in% hoja_ignorar] # En caso de existir hojas a ignorar
  # Crear lista vacía para almacenar los datos
  datos <- list()
  # Vector que guarda nombre de encabezados 
  encabezado <- vector()
  for (i in 1:length(hojas)) {
    # Estandarizar nombres de df
    name = gsub(' ', '', hojas[i])
    datos[[name]] <- read_excel(ruta_archivo,
                                     sheet = hojas[i], 
                                     skip = filas_a_ignorar[i])
    
    # Reemplazar ',' por '.' en todas las columnas
    datos[[name]] <- datos[[name]] |> 
      mutate(across(everything(), ~ {
        if (is.character(.x)) gsub(",", ".", .x)
        else if (is.factor(.x)) gsub(",", ".", as.character(.x))
        else .x
      }))
    
    # Verificador de lectura
    print(paste('Se ha leído la hoja: ', name))
    # Unificar en un vector los nombres de los encabezados
    encabezado <- append(encabezado, names(datos[[name]]))
  }
  
  # Reemplazar hojas por nombres estandarizados
  hojas <- names(datos)
  # Definir encabezados únicos eliminando repeticiones
  encabezado <- unique(encabezado)
  # Devolver los datos leidos
  return(list(
    datos = datos, # df leidos por hoja del excel
    hojas = hojas, # nombre de los pozos en donde se capturaron los datos
    encabezado = encabezado # Nombre de columnas en cada df
  ))
}