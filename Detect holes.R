library(sf)  # vector data
library(tictoc)
library(tidyverse)
library(mapview)
library(smoothr)

tic()
##read data
geom <- st_read('C:\\Users\\MCOLOMBINI\\Documents\\Deptos_argentina\\testdata.gpkg')%>% 
  mutate(osm_id = ifelse(is.na(osm_id), 10724,osm_id))


##Set threshold
area_thresh <- units::set_units(300, km^2)

## Fill holes
area_llena <- fill_holes(geom, threshold = area_thresh)


## difference between fill area and geom
tic()
geom.diff <- purrr::map(1:nrow(area_llena), ~st_difference(area_llena[.x,], geom[.x,]))
toc() # 5 min
geom.diff.sf <- do.call(rbind, geom.diff) %>% 
  st_cast()

##mapping
geom %>% 
  st_drop_geometry() %>% 
  right_join(x = ., y = st_drop_geometry(geom.diff.sf), by = 'osm_id') %>% 
  inner_join(x= ., y = geom %>% select(osm_id, geom), by  = 'osm_id') %>% 
  st_as_sf() %>% 
  mapview(x = ., layer.name = 'Holes', col.regions = 'yellow')
toc()