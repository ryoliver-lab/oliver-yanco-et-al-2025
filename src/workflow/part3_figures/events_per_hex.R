# Using the event_clean data table, sum the events per hex geometry
# in the USA. This sf object will be used to produce Fig 1.

library(tidyverse)
library(patchwork)
library(sf)
library(data.table)
library(proj4)
library(spData)
library(ggspatial)
library(here)
library(DBI)
library(RSQLite)

rm(list = ls())
.wd <- getwd()
.outPF <- file.path(.wd, "out")

# species list + taxonomy
species_list <- fread(file.path(.outPF, "species_list.csv"))
.dbPF <- file.path(.wd,'processed_data/intermediate_db_copies/mosey_mod_clean-movement_complete.db')

# connect to db 
invisible(assert_that(file.exists(.dbPF)))
db <- dbConnect(RSQLite::SQLite(), .dbPF, `synchronous` = NULL)
invisible(assert_that(length(dbListTables(db))>0))

# read in event table
d <- tbl(db, "event_clean") %>% 
  collect()

dbDisconnect(db)

# print summaries
print("number of locations:")
nrow(d)
print("number of individuals:")
length(unique(d$individual_id))

d_cleaned <- d %>%
  select(taxon_canonical_name, lon, lat, event_id) %>%
  mutate(taxon_canonical_name = case_when(taxon_canonical_name == "Anser" ~ "Anser caerulescens",
                                          taxon_canonical_name == "Chen caerulescens" ~ "Anser caerulescens",
                                          taxon_canonical_name == "Chen rossii" ~ "Anser rossii",
                                          TRUE ~ taxon_canonical_name)) 

# convert to sf object
d_sf <- st_as_sf(d_cleaned, coords = c("lon", "lat"), crs = "EPSG:4326")
d_sf <- st_transform(d_sf, crs = "EPSG:6933")

# select US sf object
us <- world %>%
  filter(name_long == "United States")
us <- st_transform(us, crs = "EPSG:6933")

# filter to events in US
d_sf <- d_sf[us,]

# join event table with species list
d_species_joined <- d_sf %>%
  st_set_geometry(NULL) %>%
  left_join(., species_list, by = c("taxon_canonical_name" = "scientific_name"))

# summarize number of locations by taxa
locations_summary <- d_species_joined %>%
  group_by(taxa) %>%
  summarise(n_locations = n())

# summarize number of species by taxa
species_summary <- species_list %>%
  group_by(taxa) %>%
  summarise(n_species = n())

# plot location summary
p1 <- ggplot(data = locations_summary) +
  geom_bar(aes(y = taxa, x = n_locations), 
           stat = "identity",
           fill = "grey45") +
  theme_minimal() +
  theme(axis.line = element_line(colour = "#4a4e4d", linewidth =0.3, linetype='solid'),
        panel.grid.minor.y = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.y  = element_blank(),
        legend.position = "none",
        legend.title = element_blank(),
        axis.text.y = element_blank(),
        axis.title = element_blank(),
        axis.text = element_text(size = 7),
        axis.title.x = element_text(size = 7),
        axis.ticks.x = element_line(color = "#4a4e4d")) +
  scale_y_discrete(expand = expansion(mult = c(0.5, 0.5))) +  
  scale_x_continuous(expand = expansion(mult = c(0, 0.01)),
                     #labels = scales::comma,
                     breaks = seq(0, 8000000, by = 2000000),
                     labels = c("0", "2M", "4M", "6M", "8M")) +
  labs(x = "Locations (n)")


# plot species summary
p2 <- ggplot(data = species_summary) +
  geom_bar(aes(y = taxa, x = n_species), 
           stat = "identity",
           fill = "grey45") +
  theme_minimal() +
  theme(axis.line = element_line(colour = "#4a4e4d", linewidth =0.3, linetype='solid'),
        panel.grid.minor.y = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.y  = element_blank(),
        legend.position = "none",
        legend.title = element_blank(),
        axis.text.y = element_blank(),
        axis.title = element_blank(),
        axis.text = element_text(size = 7),
        axis.title.x = element_text(size = 7),
        axis.ticks.x = element_line(color = "#4a4e4d")) +
  scale_y_discrete(expand = expansion(mult = c(0.5, 0.5))) +  
  scale_x_continuous(expand = expansion(mult = c(0, 0.01)),
                     labels = scales::comma) +
  labs(x = "Species (n)")


# export summary figures
p_inset <- p1 + p2
ggsave(p_inset, file = here::here("figures","fig1-inset.pdf"), width = 1.8, height = 0.9)


######### create hex map ######### 
# create equal area hex grid
hex <- st_make_grid(d_sf, n = c(100,100),
                    what = 'polygons',
                    square = FALSE,
                    flat_topped = TRUE) %>%
  st_sf() %>%
  rowid_to_column('hex_id')

# find number of locations within hex grid cells
d_sf <- d_sf %>%
  select(event_id)

d_sf_hex <- st_join(d_sf, hex, join=st_within) %>%
  st_set_geometry(NULL) %>%
  count(name = "events", hex_id)

# join counts to hex grid
hex <- hex %>%
  left_join(d_sf_hex, by = 'hex_id') %>%
  replace(is.na(.), 0) %>%
  filter(events > 0)

# save intermediate sf object for number of events per hex geometry
st_write(hex, file.path(.outPF, "hex_event_count.gpkg"))
