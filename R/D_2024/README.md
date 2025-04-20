# Piloto uno: Estandarización de datos colectados para 2024

La rutina que desarrolla el script `lectura_2024.R` busca utilizar el archivo `.xlsx` más voluminoso dentro de la información porporcionada, para diseñar una series de procesos experimentales, que lleve a la estandarización de los datos disponibles y generar un poblamiento inicial hacia la base de datos diseñada.

En general el desarrollo puede dividirse en:

- [x] Lectura de datos: Nombre y número de hojas dentro del libro excel
  
  - [x] Lectura de cada hoja por separado en una unica lista
  
  - [x] Carga y extracción de los encabezados de columna en cada una de las hojas
  
  - [x] Agrupación de encabezados por temática, definición de 7 grupos, los cuales serán las columnas estandar: 
  
  Estas columnas son:
  
  - hora
  
  - fecha
  
  - profundidad_nivel
  
  - temperatura
  
  - conductividad
  
  - presion_total_mh20
  
  - presion_parcial_pb

Una vez estos pasos previos han sido exitosamente desarrollados se inicia el segundo gran bloque:

- [x] Función de renombrado y estandarización en datos
  
  - [x] Ejecución de renombrado para las columnas que contienen valores asociados a cada una de las 7 variables estandar definidas
  
  - [x] Asignación de código de pozo a cada dataframe estandarizado
  
  - [x] Cálculo de días totales monitoreados **asumiendo frecuencia horaria** para todos los conjuntos de datos cargados
  
  Sobre este punto conviene revisar los resultados obtenidos
  
  ### Días de Monitoreo por Pozo en 2024
  
  | ID Pozo     | Días Monitoreados |
  |:-----------:| ----------------- |
  | pz-01-0004  | 208.4             |
  | pz-01-0010  | 1462.8            |
  | pz-01-0031  | 98.8              |
  | pz-07-0008  | 368.0             |
  | pz-09-0059  | 184.0             |
  | pz-08-0012  | 425.5             |
  | pz-08-0013  | 12.8              |
  | pz-08-0023  | 365.2             |
  | pz-10-0027  | 117.8             |
  | pz-11-012   | 2433.9            |
  | pz-11-0028  | 416.6             |
  | pz-11-0047  | 56.2              |
  | pz-11-0080  | 60.8              |
  | pz-11-0108  | 424.8             |
  | pz-11-0140  | 9855.4            |
  | pz-11-0051  | 729.4             |
  | pz-11-0096  | 366.0             |
  | pz-11-0195  | 657.3             |
  | pz-11-0214  | 487.1             |
  | pz-11-0217  | 540.1             |
  | pz-11-0190  | 6792.0            |
  | pz-11-0222  | 1279.7            |
  | pz-11-0221  | 26.2              |
  | PZ-16-0001  | 241.8             |
  | PZ-16-0002  | 368.2             |
  | pz-16-0004  | 184.0             |
  | pz-16-0013  | 259.1             |
  | pz-16-0014  | 190.0             |
  | pz-16-0015  | 212.9             |
  | pz-16-0040  | 368.0             |
  | pz-16-0041  | 368.0             |
  | pz-19-0005  | 156.3             |
  | pz-19- 0027 | 161.3             |

Llama la atención que, aunque los datos son del año 2024, muchos superar con creces el número de días de un año, lo que sugiere de entrada una frecuencia de medición *infrahoraria* para algunos pozos. Esto se plantea como hipotesis a verificar.

Se requieren correcciones para estimar correctamente la hora sobre el pozo `pz-08-0023`, además de ello el pozo `pz-11-0190` registra datos por fecha pero no por hora de captura, generando una seria dififucltad para obtener este dato

- [ ] Estandarización de formato para las variables agrupadas
  
  - [x] Estandarizar hora :1 a 24
  
  - [ ] Estandarizar fecha: Día-Mes-Año



## Exploración de valores

Si bien ha sido posible inficar la estructura de los datos, es decir, contruir un unico dataframe con número y nombre igual de variables, ha sido evidente que dentro de las columnas originales existe una heterogeneidad de valores amplia, en algunos casos una misma columna de fecha puede contener formatos `DMY` y `YMD`, hecho que dificulta la esatndarización de valores y ha generado desafios para la contrucción funcional de la rutina de código.

 Esta fase contunúa en desarrollo y exploración.
