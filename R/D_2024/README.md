# Informe Técnico

## Piloto Uno: Estandarización de Datos Colectados para 2024

## 1. Introducción

El presente informe describe el desarrollo de la rutina implementada en el script `lectura_2024.R` y los modulos que para cvada función se han implementado, cuyo objetivo principal es utilizar el archivo `.xlsx` de mayor volumen disponible para diseñar una serie de procesos experimentales orientados a la estandarización de datos y la generación del poblamiento inicial de la base de datos estructurada para el año 2024.

## 2. Metodología

El procedimiento seguido se divide en dos grandes bloques:

---

### 2.1 Lectura y Organización de Datos

- **Identificación de archivo y hojas**: Detección del nombre y número de hojas contenidas en el archivo Excel.
- **Carga individual de hojas**: Lectura de cada hoja de forma independiente y almacenamiento en una lista única.
- **Extracción de encabezados**: Obtención de los encabezados de columna de cada hoja para su posterior clasificación.
- **Agrupación temática**: Clasificación de encabezados en 7 categorías estandarizadas:
  - `hora`
  - `fecha`
  - `profundidad_nivel`
  - `temperatura`
  - `conductividad`
  - `presion_total_mh20`
  - `presion_parcial_pb`

---

### 2.2 Estandarización de Datos

- **Renombrado de columnas**: Homologación de nombres de columnas asociadas a cada una de las 7 variables estándar.
- **Asignación de identificadores**: Incorporación de códigos de pozo en cada dataframe estandarizado.
- **Estimación de días monitoreados**: Cálculo del número de días monitoreados **asumiendo frecuencia horaria** para todos los conjuntos de datos.

#### Resultados preliminares:

| ID Pozo    | Días Monitoreados |
|:----------:| ----------------- |
| pz-01-0004 | 208.4             |
| pz-01-0010 | 1462.8            |
| pz-01-0031 | 98.8              |
| pz-07-0008 | 368.0             |
| pz-09-0059 | 184.0             |
| pz-08-0012 | 425.5             |
| pz-08-0013 | 12.8              |
| pz-08-0023 | 365.2             |
| pz-10-0027 | 117.8             |
| pz-11-012  | 2433.9            |
| pz-11-0028 | 416.6             |
| pz-11-0047 | 56.2              |
| pz-11-0080 | 60.8              |
| pz-11-0108 | 424.8             |
| pz-11-0140 | 9855.4            |
| pz-11-0051 | 729.4             |
| pz-11-0096 | 366.0             |
| pz-11-0195 | 657.3             |
| pz-11-0214 | 487.1             |
| pz-11-0217 | 540.1             |
| pz-11-0190 | 6792.0            |
| pz-11-0222 | 1279.7            |
| pz-11-0221 | 26.2              |
| PZ-16-0001 | 241.8             |
| PZ-16-0002 | 368.2             |
| pz-16-0004 | 184.0             |
| pz-16-0013 | 259.1             |
| pz-16-0014 | 190.0             |
| pz-16-0015 | 212.9             |
| pz-16-0040 | 368.0             |
| pz-16-0041 | 368.0             |
| pz-19-0005 | 156.3             |
| pz-19-0027 | 161.3             |

**Observaciones:**

- Se evidencia que varios pozos presentan un número de días monitoreados que excede el total de días de un año, lo cual sugiere una posible **frecuencia de medición inferior a una hora** (*infrahoraria*).
- Se detectan inconsistencias específicas:
  - El pozo `pz-08-0023` requiere correcciones para estimar adecuadamente la hora de medición.
  - El pozo `pz-11-0190` contiene registros de fecha sin especificación horaria, dificultando su estandarización completa.

---

## 3. Correcciones Pendientes

- [x] Estandarizar valores de hora en el rango de 1 a 24.
- [x] Estandarizar el formato de fecha en el patrón Día-Mes-Año (`DD-MM-AAAA`).
- [ ] Completar la asignación de horas en pozos con datos incompletos.

---

## 4. Exploración Inicial de Valores

Se logró unificar la estructura de los datos, construyendo un único dataframe con igual número y nombre de variables. Sin embargo, se identificaron desafíos importantes:

- Existencia de múltiples formatos de fecha (`DMY`, `YMD`) en las mismas columnas.
- Heterogeneidad considerable en los valores registrados, que dificulta la homogenización automática.

A pesar de ello, se ha conseguido generar resultados preliminares que permiten detectar inconsistencias adicionales y ajustar los módulos de procesamiento de la información.

---

## 5. Conclusiones

- La estructura de lectura y estandarización básica ha sido implementada exitosamente.
- Es necesaria la depuración adicional de formatos de fecha y hora para alcanzar una estandarización total.
- Se recomienda incorporar validaciones automáticas de formatos antes del procesamiento masivo.

---

![](/media/DiscoA/GitLab/time_series_sda/PNG/Nivel_2024.png)
