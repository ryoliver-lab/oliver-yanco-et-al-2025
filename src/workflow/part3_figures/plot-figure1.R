# Read in the sf hex object with number of events summed per USA hex geometry
# Plot Figure 1

library(tidyverse)
library(patchwork)
library(sf)
library(data.table)
library(proj4)
library(spData)
library(ggspatial)
library(here)

.wd <- getwd()
.outPF <- file.path(.wd, "out")

# read in the intermediate sf df with events per hex
# produced using the event_clean table from db
hex <- read_sf(file.path(.outPF, "hex_event_count.gpkg"))

# select US sf object with same CRS as script that created hex sf object
us <- world %>%
  filter(name_long == "United States")
us <- st_transform(us, crs = "EPSG:6933")

# create base map of US
us_map <- ggplot(us) +
  geom_sf(fill = "grey75", color = "grey75") 

# add hex grid
p <- us_map +
  geom_sf(data = hex, aes(fill = events), color = "transparent") +
  annotation_scale(location = "bl", width_hint = 0.2) +
  coord_sf(datum = NA, crs = st_crs("EPSG:5070")) +
  scale_fill_viridis_c(option = "magma",trans = "log10", labels = scales::label_comma()) +
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_blank()) +
  theme(legend.position = "bottom", 
        legend.key.width = unit(.7,"cm"),
        legend.key.height = unit(0.3,"cm"),
        legend.title=element_text(size=7),
        legend.text = element_text(size=7),
        legend.margin=margin(0,0,0,0),
        axis.title = element_blank()) +
  guides(fill = guide_colorbar(title.position = "top")) +
  labs(fill = "Animal locations (n)") 

# export map
ggsave(p, file = file.path(.outPF, "fig1.pdf"), width = 5, height = 5)
