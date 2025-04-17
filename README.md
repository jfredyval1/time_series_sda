# Diseño e implementación de una base de datos espacio-temporal para información hidrogeológica SDA

El flujo de trabajo que a continuación se describe, presenta las princiaples acciones que se han desarrollado para convertir infrmación asilada en diversos formatos, en una base de datos relacional y estructurada que permita la inspección, descripción, análisis y escalabilidad de los datos asociados a captciones subterráneas monitoreadas por la **Secretaría Distrital de Ambiente de Bogotá**, en adelante **SDA**.



Con este propósito se han diseñado diferentes estapas de trabajo para la consecución de este fin, estas son:

- [ ] Contrucción de tabla **Puntos de agua SDA** con sus variables, localización y llaves primarias

- [ ] Construcción de tablas independientes para cara variables observada con la intrumentación de los pozos, cada una de ellas se relacionará con la tabla **Puntos de agua SDA** a partir de su llave primaria
  
  - [ ] teIdentificación de número total de archivos por: tipo y peso en disco
  
  - [ ] Identificación de estructura común en los archivos para su manipulación, previa al proceso de estandarización *ETL* 

- [ ] Indexación de información en base de datos para su consumo eficiente por parte del usuario a partir de PostgreSQL

Los pasos anteriormente mencionados conforman la *etapa 1* del proceso.



## Etapa 1: Insepcción y estandarización de información

La carpeta **Dispositivos Usuarios 2025** que ha sido proporcionada tiene un peso en disco de *10.6 GB* , en ella se encuentran 1975 carpetas y un total de 7138 archivos

Una mirada detallada tanto al tipo de archivo, cantidad, peso y cantidad de subcarpetas se realizaó haciendo uso de una rutina *bash*  ejecutando el archivo **inspeccion.sh**, el cual está compuesto de las siguientes instrucciones

```shell
echo "=== ANÁLISIS DE TIPOS DE ARCHIVO Y CANTIDAD ==="
echo "Buscando DISPOSITIVOS USUARIOS 2025 y subcarpetas..."
find /media/disk1/DISPOSITIVOS_USUARIOS_2025 -type f | rev | cut -d. -f1 | rev | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -nr

echo -e "\n=== ARCHIVOS MÁS GRANDES (TOP 15) ==="
find /media/disk1/DISPOSITIVOS_USUARIOS_2025 -type f -exec du -h {} \; | sort -hr | head -15

echo -e "\n=== TAMAÑO DE SUBCARPETAS ==="
du -h --max-depth=2 /media/disk1/DISPOSITIVOS_USUARIOS_2025 | sort -hr
```

El resultado inicial que permitió contextualizar la naturaleza de la infomración compartida se resume a continuación:

| Extensión          | Cantidad de archivos | Tamaño (MB) |
| ------------------ | -------------------- | ----------- |
| .pdf               | 4142                 | 6870,86     |
| .xlsx              | 1491                 | 654,52      |
| .csv               | 609                  | 149,16      |
| .jpg               | 198                  | 19,55       |
| .xls               | 141                  | 39,87       |
| .xml               | 92                   | 61,23       |
| .zip               | 87                   | 170,60      |
| .png               | 86                   | 1,94        |
| .xle               | 83                   | 54,45       |
| .docx              | 68                   | 27,38       |
| .dat               | 44                   | 2,23        |
| .mon               | 43                   | 17,33       |
| .txt               | 12                   | 12,51       |
| .db                | 7                    | 1,58        |
| .dwg               | 6                    | 0,90        |
| .doc               | 5                    | 1,33        |
| .bmp               | 5                    | 4,86        |
| .ppt               | 4                    | 2,59        |
| .hyt               | 4                    | 0,01        |
| .hobo              | 4                    | 0,03        |
| .ds_store          | 4                    | 0,03        |
| .nitg              | 3                    | 0,17        |
| .xlsx#             | 2                    | 0,00        |
| .mp4               | 2                    | 1673,58     |
| .hproj             | 2                    | 0,27        |
| .gif               | 2                    | 0,01        |
| .crdownload        | 2                    | 5,20        |
| .mpg               | 1                    | 248,40      |
| .lnk               | 1                    | 0,00        |
| .ini               | 1                    | 0,00        |
| .html              | 1                    | 0,00        |
| .51359429 7edbfc00 | 1                    | 48,98       |
| .162 ~$dbfc00      | 1                    | 0,00        |



Esto fue posible gracias a al ejecución de esta sentencia



```shell
find "/media/disk1/DISPOSITIVOS_USUARIOS_2025" -type f -printf "%s %f\n" | awk -F. '{ext=tolower($NF); count[ext]++; size[ext]+=$1} END {for (e in count) printf "%d archivos con extensión .%s - %.2f MB\n", count[e], e, size[e]/1048576}' | sort -nr

```



### Inspección de información para su preprocesamiento



Dada la heterogeneidad y volumen de información disponible, se ha generado una jerarquización de extensiones, con el fin de priorizar su inspección en función de su naturaleza, privilegiando así los datos que, con mayor probabilidad, contienen información alfanumérica estructurada.

Esta jerarquización de ha relaizado de la siguiente manera:



#### Prioridades para la inspección de datos

1. **Archivos de datos estructurados (primer nivel)**
   - **CSV (609 archivos, 149.16 MB)**: Prioridad alta por ser ya estructurados y fáciles de importar.
   - **XLSX/XLS (1632 archivos, 694.39 MB)**: Contienen datos estructurados importantes.
   - **XML (92 archivos, 61.23 MB)**: Pueden contener datos y definiciones estructurales.
2. **Archivos de bases de datos existentes (segundo nivel)**
   - **DB (7 archivos, 1.58 MB)**: Pueden tener esquemas y datos ya organizados.
   - **DAT (44 archivos, 2.23 MB)**: Posiblemente contengan datos en formato específico.
3. **Archivos especializados (tercer nivel)**
   - **XLE (83 archivos, 54.45 MB)**: Formatos específicos que podrían contener datos valiosos.
   - **MON (43 archivos, 17.33 MB)**: Posibles datos de monitoreo o series temporales.
4. **Documentos con posibles datos tabulares (cuarto nivel)**
   - **PDF (4142 archivos, 6870.86 MB)**: Puede contener tablas, pero requerirá extracción.
   - **DOCX/DOC (73 archivos, 28.71 MB)**: Pueden contener tablas estructuradas.



Una vez definidos los tipos de archivos a priorizar, se iniciío con aquellos de mayor volumen, idnetificando su peso en disco por extensión priorizada a  partir de la siguiente sentencia

```shell
find "/media/disk1/DISPOSITIVOS_USUARIOS_2025" -name "*.xls*" -type f -exec du -h {} \; | sort -hr

```


