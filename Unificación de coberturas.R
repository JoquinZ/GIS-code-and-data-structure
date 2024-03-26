library(data.table)
library(dplyr)
library(readr)
library(reshape2)

# Ruta de la carpeta donde se encuentran los archivos
ruta_carpeta <- "C:/Users/Joaco/Proyecto pampa/Tablas de cobertura/Cuencas Hidrograficas/Oceano Atlantico/"


# Lista de archivos que cumplen con el patrón especificado
archivos_en_carpeta <- list.files(path = ruta_carpeta, pattern = "O_Atlantico_red_\\d{4}\\.csv", full.names = TRUE)

# Leer, procesar y fusionar los archivos
Cuenca_uni <- lapply(archivos_en_carpeta, function(archivo) {
  # Agregar mensaje de depuración
  print(paste("Procesando archivo:", archivo))
  
  # Leer el archivo CSV
  df <- fread(archivo, select = c("bc_anio", "gridcode", "CUENCA", "Shape_Area"))
  
  # Sustituir los valores de gridcode
  df$gridcode <- factor(df$gridcode, levels = c("11", "3", "33", "9", "21", "22", "12", "27", "0"),
                        labels = c("Pastizal_inundable", "Monte_nativo", "Cuerpo_agua", "Forestación", "Agricultura_pastura", 
                                   "No_vegetado", "Pastizal", "No_observado", "Nada"))
  # Transformar las variables bc_anio y Shape_Area a numéricas
  df$Shape_Area <- as.numeric(gsub(",", ".", df$Shape_Area))
  
  # Pivoteo
  df_pivot <- dcast(df, CUENCA + bc_anio ~ gridcode, value.var = "Shape_Area", fun.aggregate = sum)
  
  return(df_pivot)
})

# Unificar los archivos en un solo data frame
Cuenca_uni <- do.call(rbind, Cuenca_uni)

# Eliminar la coma y todo lo que está a la derecha de la coma
Cuenca_uni$bc_anio <- as.numeric(sub(",.*", "", Cuenca_uni$bc_anio))

# Ruta completa del archivo CSV
ruta_guardado <- "C:/Users/Joaco/Proyecto pampa/Tablas de cobertura/Cuencas Hidrograficas/Oceano Atlantico/O_Atlantico_red_tot.csv"

# Guardar el dataframe como un archivo CSV
write.csv(Cuenca_uni, file = ruta_guardado, row.names = FALSE)

###########################################

# Ruta del archivo CSV
ruta_csv <- "C:/Users/Joaco/Proyecto pampa/Tablas de cobertura/Cuencas Hidrograficas/Cuencas_00a21.csv"

# Leer el archivo CSV
datos <- read.csv(ruta_csv, sep = ";")

# Renombrar las categorías de gridcode
datos$gridcode <- factor(datos$gridcode, levels = c("11", "3", "33", "9", "21", "22", "12", "27", "0"),
                         labels = c("Pastizal_inundable", "Monte_nativo", "Cuerpo_agua", "Forestación", "Agricultura_pastura", 
                                    "No_vegetado", "Pastizal", "No_observado", "Nada"))

# Renombrar la variable nombrec1 a CUENCA
datos <- rename(datos, CUENCA = nombrec1)

# Transformar las variables bc_anio y Shape_Area a numéricas
datos$Shape_Area <- as.numeric(gsub(",", ".", datos$Shape_Area))


#Cambiar la forma de la tabla para tener como columnas las categorias de gridcode
datos <- dcast(datos, CUENCA + bc_anio ~ gridcode, value.var = "Shape_Area", fun.aggregate = sum)
# Cambiar la categoría en CUENCA de "Ocoano Atlantico" a "Oceano Atlantico"
datos$CUENCA <- ifelse(datos$CUENCA == "Ocoano Atlantico", "Oceano Atlantico", datos$CUENCA)


# Guardar los datos modificados en un nuevo archivo CSV
write.csv(datos, "C:/Users/Joaco/Proyecto pampa/Tablas de cobertura/Cuencas Hidrograficas/uru_85a21_tot.csv", row.names = FALSE)

# Cambiar la categoría en CUENCA de "Ocoano Atlantico" a "Oceano Atlantico"
datos_00a2021$CUENCA <- ifelse(datos_00a2021$CUENCA == "Ocoano Atlantico", "Oceano Atlantico", datos_00a2021$CUENCA)

datos_00a2021 <- subset(datos, bc_anio > 1999)

names(datos_00a2021)[3:11] <- paste0(names(datos_00a2021)[3:11], "_tot")


# Guardar los datos modificados en un nuevo archivo CSV
write.csv(datos_00a2021, "C:/Users/Joaco/Proyecto pampa/Tablas de cobertura/Cuencas Hidrograficas/uru_00a21_tot.csv", row.names = FALSE)
##################################################
# Ruta de la carpeta que contiene los archivos CSV
carpeta <- "C:/Users/Joaco/Proyecto pampa/Tablas de cobertura/Cuencas Hidrograficas/Uruguay/"

# Lista todos los archivos CSV en la carpeta
archivos_csv <- list.files(path = carpeta, pattern = "\\.csv$", full.names = TRUE)

# Leer todos los archivos CSV en una lista de dataframes
lista_dataframes <- lapply(archivos_csv, read.csv)

# Eliminar la columna "Nada" de todos los dataframes en la lista
lista_dataframes <- lapply(lista_dataframes, function(df) df[, !names(df) %in% "Nada"])

# Unir los dataframes nuevamente
uru_red_espejo <- rbindlist(lista_dataframes)


###############

# Opción 1: Usar la función subset
datos_00a2021 <- subset(datos_00a2021, select = -Nada_tot)

# Realizar left join
resultado <- merge(uru_red_espejo, datos_00a2021, by = c("bc_anio", "CUENCA"), all.x = TRUE)

# Guardar los datos modificados en un nuevo archivo CSV
write.csv(resultado, "C:/Users/Joaco/Proyecto pampa/Tablas de cobertura/Cuencas Hidrograficas/Tot_cuenca.csv", row.names = FALSE)
