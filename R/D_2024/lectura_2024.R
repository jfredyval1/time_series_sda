# Lectrua de hojas de datos en hoja de calculo 'Datos 2024'
# Abril 17 de 2025
# R 4.5.0  
# Librerías requeridas
library(readxl)
# Limpiar área de trabajo
rm(list = ls())
# Lectura de hojas en archivo de interés
hojas <- excel_sheets('/media/disk1/DISPOSITIVOS_USUARIOS_2025/DATOS 2024 DISPOSIVOS CONCESIONADOS.xlsx')
# Eliminar hoja sin datos
hojas <- hojas[!hojas == 'Hoja1']

# Definir númeor de filas a ignorar para correcta lectura de datos en cada hoja

row_del <-c(0,21,21,13,0,21,21,0,3,8,9,21,21,9,5,0,0,0,0,21,30,21,21,21,21,21,21,21,21,21,21,21,21)


datos_2024 <- list()
# Vector que guarda nombre de encabezados 
encabezado <- vector()
for (i in 1:length(hojas)) {
  datos_2024[[hojas[i]]] <- read_excel("/media/disk1/DISPOSITIVOS_USUARIOS_2025/DATOS 2024 DISPOSIVOS CONCESIONADOS.xlsx", 
                                                    sheet = hojas[i], skip = row_del[i])
  # Verifivador de lectura
  print(paste('Se ha leido la hoja: ',hojas[i]))
  # Unificar en un vector los nombres de los encabezados
  encabezado <- append(encabezado,names(datos_2024[[hojas[i]]]))
}
# Definir ecabezados unicos eliminando repeticiones
encabezado <- unique(encabezado)
