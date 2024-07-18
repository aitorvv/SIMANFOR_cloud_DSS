#------------------------------------------------------------------------------------------#
####                            Graph inventory plot locations                          ####
#                                                                                          #
#                            Aitor Vázquez Veloso, 26/07/2023                              #
#                              Last modification: 01/11/2023                               #
#------------------------------------------------------------------------------------------#


#### Basic steps ####

library(ggplot2)
library(dplyr)
library(sf) # geometry
library(sp) # some functions for geometry
library(oce) # utm2lonlat
library(eurostat) # maps

setwd('')


#### Load data ####

df <- read.csv('2_simanfor/input/plots.csv')


#### Manage data: arrange coordinates ####

# calculate longitude and latitude
lonlat <- utm2lonlat(easting = df$x_utm,
                     northing = df$y_utm,
                     zone = 30, 
                     hemisphere = 'N',
                     km = FALSE)

# add them to the previous dataset
df$Longitude <- tibble(lonlat$longitude)
df$Latitude <- tibble(lonlat$latitude)

# create a SpatialPointsDataFrame1
coordinates(df) <- c("Longitude", "Latitude")
proj4string(df) <- CRS("+proj=longlat +datum=WGS84")  

# transform to WGS84
my_points <- st_as_sf(df, coords = c("Longitude", "Latitude"), 
                      crs = 4326, # WGS84
                      agr = "constant")


#### Get shape data ####

# shape all Europe
shp_0 <- get_eurostat_geospatial(resolution = 10, 
                                 nuts_level = 1, # big regions
                                 year = 2021,
                                 crs = 4326) # WGS84

# shape Spain
shp_es <- shp_0[shp_0$CNTR_CODE == 'ES', ]

# check it
shp_es %>% 
  ggplot() +
  geom_sf()

# get small regions
shp_regions  <- get_eurostat_geospatial(
  resolution = 10,
  nuts_level = 2, # medium regions
  year = 2021,
  crs = 4326) # WGS84

# get regions from Spain
shp_es_regions <- shp_regions[shp_regions$CNTR_CODE == 'ES', ]

# plot Spain regions
shp_es_regions %>% 
  ggplot() +
  geom_sf(size = 0.2, color = "blue") + # border line
  scale_x_continuous(limits = c(-10, 5)) +
  scale_y_continuous(limits = c(36, 45)) +
  labs(
    title = "Site locations",
    #subtitle = "Annual % of change, 2020 vs 2019",
    #caption = "Data: Eurostat tec00115"
  ) +
  theme_void() # skip borders of the plot


#### Plot points and map ####

# map Spain
map <- ggplot(shp_es_regions) +
  geom_sf(size = 0.2, color = "black", fill = 'lightgray') + # border line
  #geom_sf_text(aes(label = NAME_LATN), size = 3, family = 'sans', # text for each plot
  #             nudge_x = 0.05, nudge_y = - 0.05) + # distance between point and label
  geom_sf(data = my_points, size = 1, shape = 23, fill = "darkred", color = 'darkred') + # points
  labs(title = "Inventory plots location in the Southern Iberian Range (Spain)" # title
       #subtitle = "Annual % of change, 2020 vs 2019",
       #caption = "Data: Eurostat tec00115"
  ) +
  scale_x_continuous(limits = c(-9, 3)) +
  scale_y_continuous(limits = c(36, 44)) +
  #theme_void() + # skip borders of the plot
  theme(plot.title = element_text(hjust = 0.5, face = 'bold')) + # center title
  theme(panel.grid.major = element_line(colour = gray(0.5), linetype = "dashed", size = 0.15), 
        panel.background = element_rect(fill = "aliceblue"), # outside map style
        panel.border = element_rect(fill = NA)) 

# watch and save graph
map
ggsave(filename = '4_figures/plots_map_Spain.png', device = 'png', units = 'mm', dpi = 300, width = 300, height = 300)
