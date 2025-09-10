# Create species specific figures that show:
# 1. the area of the census block groups that were used in the analysis 
# 2. the utilization distribution areas
# with aligned x axes for comparison

library(tidyverse)
library(patchwork)
library(DBI)
library(RSQLite)
options(scipen = 999)

# PART 1: CBG DATA LOAD AND PREP

# Read in the CSV that is output from the intersection operation between the 
#   event and CBG polygons in the workflow. 
# Use the attribute `cbg_2010` for the code.

# Note: As noted in the README of the OSF archive and the figure workflow
# script, the event_id attribute of the event-cbg-intersection CSV has been 
# omitted from the public data, as is the event database, for data owner's 
# privacy. As a result, users will not be able to access the version of the 
# CSV necessary to join the species names to the CBGs

int <- read_csv(here::here("out/event-cbg-intersection/event-cbg-intersection_w_eventID.csv"))
int$event_id <- factor(int$event_id)
# check number of census blocks groups that intersected points
n_distinct(int$cbg_2010)

# Read in the `cbg-area.csv` to get areas for all CBGs
area <- read_csv(here::here("out/event-annotation/cbg-area.csv"))

# load cleaned event table from db
db <- dbConnect(RSQLite::SQLite(), 
                here::here("processed_data/intermediate_db_copies/mosey_mod_clean-movement_complete.db"),
                `synchronous` = NULL)
event_clean <- tbl(db, 'event_clean') %>% collect()
event_clean$event_id <- factor(event_clean$event_id)

# assign the species to each event based on the event ID
int_sp <- left_join(int, 
                      select(event_clean, event_id, species), 
                      by = "event_id") %>% 
          mutate(species = case_when( # standardize species names
            species == "Anser" ~ "Anser caerulescens",
            species == "Spilogale putorius" ~ "Spilogale interrupta",
            TRUE ~ species))

rm(event_clean)
gc()

# Join the area, in square meters, to the CBGs that intersected events. 
int_area_sp <- left_join(int_sp, 
                         area, 
                         by = "cbg_2010") %>%
              # add column for km2
              mutate(cbg_area_km2 = cbg_area_m2/1000000) %>% 
              filter(!is.na(species))

species_cbg <- unique(int_area_sp$species)

# PART 2: UD DATA LOAD AND PREP

# load in utilization distribution areas

ud <- read_csv("~/Documents/covid/human_mobility_wildlife/out/dbbmm_size.csv") %>% 
  mutate(area_km2 = area/1000000) %>%
  mutate(species = case_when( # correct species names
    study_id == 1442516400 ~ "Anser caerulescens",
    study_id == 1631574074 ~ "Ursus americanus",
    study_id == 1418296656 ~ "Numenius americanus",
    study_id == 474651680  ~ "Odocoileus virginianus",
    study_id == 1044238185 ~ "Alces alces",
    TRUE ~ species
  ))%>% 
  mutate(species = case_when(
    species == "Chen caerulescens" ~ "Anser caerulescens",
    species == "Spilogale putorius" ~ "Spilogale interrupta",
    species == "Chen rossii" ~ "Anser rossii",
    TRUE ~ species))

species_ud <- unique(ud$species)

# ensure species lists are the same
setdiff(species_ud, species_cbg)
setdiff(species_cbg, species_ud)

for (sp in species_cbg){
  
  # PART 1: CBG PLOT
  
  int_area_sp_subset <- int_area_sp %>% 
                        filter(species == sp)
  
  # remove duplicate CBG areas
  int_area_sp_subset_unique <- int_area_sp_subset[!duplicated(int_area_sp_subset$cbg_area_km2), ]
  
  ud_subset <- ud %>% filter(species == sp)
  
  # pull the max x val of the last bin, using ggplots natural binning
  tmp_cbg <- ggplot_build(ggplot(int_area_sp_subset_unique,
                                 aes(x = cbg_area_km2)) +
                            geom_histogram(bins = 25))
  
  tmp_ud <- ggplot_build(ggplot(ud_subset,
                                aes(x = area_km2)) +
                           geom_histogram(bins = 25))
  
  xlim <- max(max(tmp_cbg$data[[1]]$xmax), max(tmp_ud$data[[1]]$xmax))
  xmin <- min(min(tmp_cbg$data[[1]]$xmin), min(tmp_ud$data[[1]]$xmin))
  
  breaks <- seq(xmin, xlim, by = (xlim-xmin)/25)
  
  # plot distribution of CBGs used by this species 
  cbg_plot <- ggplot(int_area_sp_subset_unique, 
                     aes(x = cbg_area_km2)) +
    geom_histogram(breaks = breaks,
                   fill = "lightblue", 
                   color = "black") +
    # print counts per bin above bars
    geom_text(stat = "bin", 
              breaks = breaks,
              aes(y = after_stat(count), 
                  label = ifelse(after_stat(count) > 0, 
                                 after_stat(count), 
                                 "")),
              vjust = -0.5,
              size = 3) +
    theme_gray() +
    labs(title = paste(sp, "census block group area sizes"),
         subtitle = "Includes 2010 census block groups that contain GPS points\nValues above bars represent count of census block groups within size bin",
         x = "Census Block Group Area (kilometers²)",
         y = "Count") +
    coord_cartesian(xlim = c(NA, xlim))
  
  # PART 2: UD PLOT
  
  ud_plot <- ggplot(ud_subset,
                    aes(x = area_km2)) +
    geom_histogram(breaks = breaks,
                   fill = "lightblue", 
                   color = "black") +
    # print counts per bin above bars
    geom_text(stat = "bin", 
              breaks = breaks,
              aes(y = after_stat(count), 
                  label = ifelse(after_stat(count) > 0, 
                                 after_stat(count), 
                                 "")),
              vjust = -0.5,
              size = 3) +
    theme_gray() +
    labs(title = paste(sp, "utilization distribution area sizes"),
         subtitle = "Areas calculated per individual-year-week",
         x = "Utilization Distribution Area (kilometers²)",
         y = "Count") +
    coord_cartesian(xlim = c(NA, xlim))
  
  # stack plots and add margin so values above bars are not clipped by titles
  cbg_plot_exp <- cbg_plot + scale_y_continuous(expand = expansion(mult = c(0, 0.1)))
  ud_plot_exp <- ud_plot + scale_y_continuous(expand = expansion(mult = c(0, 0.1)))
  combined_fig <- (cbg_plot_exp / ud_plot_exp) + plot_annotation(title = paste0(sp, ": COVID-19 wildlife movement analysis, 2019-2020"))

  ggsave(combined_fig, filename = here::here("out/figures/sp_cbg_ud/", paste0(sp, ".png")))

}
