
temperatura <- data.frame()
for (i in list.files("Temperatura47estaciones/")){
  temporal_data <- read.xlsx(paste0("Temperatura47estaciones/", i))
  temperatura <- bind_rows(temperatura, temporal_data)
}

estaciones %>% 
  mutate(Cod_Nacional = as.numeric(Cod_Nacional)) %>% 
  left_join(temperatura, by = c("Cod_Nacional" = "CodigoNacional")) %>% 
  group_by(Cod_Nacional, Nombre, Latitud, Longitud) %>% 
  nest() 
