# https://climatologia.meteochile.gob.cl/application/historicos/datosDescarga/200006

library(rvest)
library(httr)
library(readr)
library(openxlsx)
library(tidyverse)
library(filesstrings)

# Importar lista de estaciones (47) e información general de estas
estaciones <- read.xlsx("Estaciones47.xlsx")[-1,]
colnames(estaciones) <- c("N", "Cod_Nacional", "Cod_OMM", "Cod_OACI", "Nombre", "Latitud", "Longitud")

# Variables climáticas a extraer 
vars <- c("Temperatura", "PuntoRocio", "Humedad", "Viento", "PresionQFE", "PresionQFF")

# Iteración por variable climática, estación, y años
for (z in vars){
  for (i in estaciones$Cod_Nacional){
    for (j in 2017:2019){
     
      # Descarga de archivos "ZIP" desde web meteochile para variable Z, estación I, y año J
      pg <- paste0("https://climatologia.meteochile.gob.cl/application/productos/gethistoricos/", i, "_", j, "_", z, "_")
      x <- GET(pg)
      writeBin(x$content, paste0(z, "47estaciones/", i, "_", j, "_", z, ".zip"))
      
      # Extraer archivo CSV desde ZIP
      tryCatch(
        unzip(paste0(z, "47estaciones/", i, "_", j, "_", z, ".zip")), 
        error = function(e){cat("ERROR:",conditionMessage(e), "\n")})
      
      # Mover archivo CSV a carpeta que guarda información sobre la variable climática particular
      tryCatch(
        file.move(paste0(i, "_", j, "_", z, "_.csv"), paste0(z, "47estaciones/")), 
        error = function(e){cat("ERROR:",conditionMessage(e), "\n")})
      
      # Eliminar archivo ZIP una vez que se descarga CSV
      tryCatch(
        file.remove(paste0(z, "47estaciones/", i, "_", j, "_", z, ".zip")), 
        error = function(e){cat("ERROR:",conditionMessage(e), "\n")})
      
      print(paste(i, j))
    
    }
    
    # Juntar la información de todos los años en un solo archivo 
    tryCatch(
      tab <- bind_rows(
        read_delim(paste0(z, "47estaciones/", i, "_2017_", z, "_.csv"), delim = ";") %>% 
          mutate_at(vars(contains("Valor")), as.numeric),
        
        read_delim(paste0(z, "47estaciones/", i, "_2018_", z, "_.csv"), delim = ";") %>% 
          mutate_at(vars(contains("Valor")), as.numeric),
        
        read_delim(paste0(z, "47estaciones/", i, "_2019_", z, "_.csv"), delim = ";") %>% 
          mutate_at(vars(contains("Valor")), as.numeric)
        ), 
             
      error = function(e){cat("ERROR:",conditionMessage(e), "\n")})
    
    # Eliminar los archivos CSV de cada año una vez creamos el archivo con todos
    tryCatch(
      file.remove(paste0(z, "47estaciones/", i, "_2017_", z, "_.csv")), 
      error = function(e){cat("ERROR:",conditionMessage(e), "\n")})
    tryCatch(
      file.remove(paste0(z, "47estaciones/", i, "_2018_", z, "_.csv")), 
      error = function(e){cat("ERROR:",conditionMessage(e), "\n")})
    tryCatch(
      file.remove(paste0(z, "47estaciones/", i, "_2019_", z, "_.csv")), 
      error = function(e){cat("ERROR:",conditionMessage(e), "\n")})
    
    # Exportar planilla con todos los años para la estación I y la variable Z
    tryCatch(write.xlsx(tab, paste0(z, "47estaciones/", i, "_201720182019_", z, ".xlsx")), error = function(e){cat("ERROR:",conditionMessage(e), "\n")})
    
    print(paste(i, "listo"))
    
  }
}



  
