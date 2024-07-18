#------------------------------------------------------------------------------------------#
####                           Raw data adaptation to SIMANFOR                          ####
#                                                                                          #
#                            Aitor Vázquez Veloso, 31/03/2022                              #
#                              Last modification: 01/11/2023                               #
#------------------------------------------------------------------------------------------#

#### Cargar librerías y datos ####

detach("package:plyr", unload=TRUE)

library(readr)
library(openxlsx)
library(dplyr)

setwd("")

arboles <- read.csv("1_datos/0_raw/trees.csv")
parcela_2 <- read.csv("1_datos/0_raw/plotdaso.csv")
parcela_1 <- read.csv("1_datos/0_raw/plots.csv")


#### Información descriptiva ####

# Considero que hay 3 mediciones reales (0, 1 y 2) y una calculada con backdating (-1); vamos a usar la primera medición (nroInvent = 0)
# Es importante saber qué información contiene la variable "status" (árboles)?
# Aclarar expan1, expan2 y expanType (árboles)
# SI y SI.2 en parcela_2, con qué se calcularon? He de usar esta variable o la que calcule SIMANFOR?



#### Datos de árboles ####

# renombrar columnas (si falla este proceso, ejecutar la primera línea, comando "detach")
names(arboles)
arboles <- rename(arboles, 
                  ID_Inventario = nroInvent,
                  ID_Parcela = idPlot,
                  ID_arbol = nroTree,
                  especie = sp,
                  estado = status,
                  #coord_y = Y,
                  #coord_x = X,
                  #coord_z = Z,
                  #edad = ,
                  factor_expansion = expan,
                  dbh_1 = dbh1,
                  dbh_2 = dbh2,
                  #dbh = DAP,
                  #circunferencia_normal = Circunferencia,
                  esbeltez = slender,
                  area_basimetrica = ba,
                  #altura_bc = hcb,
                  altura_total = ht
                  #clase_sociologica = socio
                  #area_basimetrica = ,
)

# eliminar información innecesaria y reordenar campos

arboles <- select(arboles, ID_Inventario, ID_Parcela, ID_arbol, 
                  especie, factor_expansion, dbh_1, dbh_2, dbh, altura_total,  
                  area_basimetrica, esbeltez, estado)

# eliminar NAs

arboles <- arboles[!is.na(arboles$ID_arbol), ]


#### Datos parcela ####

# renombrar columnas (si falla este proceso, ejecutar la primera línea, comando "detach")
names(parcela_2)
parcela_2 <- rename(parcela_2, 
                  ID_Inventario = nroInvent,
                  ID_Parcela = idPlot,
                  ID_especie_principal = SP,
                  N = TPH,
                  G = BA,
                  dg = DG,
                  T = AGE,
                  Ho = HD
)

# Completar información

parcela_2$Anho <- 2003

# Ordenar variables de parcela

names(parcela_2)
parcela_2 <- select(parcela_2,
                  ID_Inventario, ID_Parcela, ID_especie_principal, Anho,
                  T, N, dg, G, Ho, SI)


#### Filtrar medición inicial ####

arboles <- arboles[arboles$ID_Inventario == 0, ]
parcela_2 <- parcela_2[parcela_2$ID_Inventario == 0, ]

#### Exportar resultados ####

write_csv(arboles, '2_simanfor/input/arboles_IBERO.csv')
write_csv(parcela_2, '2_simanfor/input/parcelas_IBERO.csv')

wb <- createWorkbook("2_simanfor/input/IBERO.xlsx")
addWorksheet(wb, "Parcelas")
writeData(wb, sheet = "Parcelas", parcela_2)
addWorksheet(wb, "PiesMayores")
writeData(wb, sheet = "PiesMayores", arboles)
saveWorkbook(wb, "2_simanfor/input/IBERO.xlsx", overwrite = TRUE)
