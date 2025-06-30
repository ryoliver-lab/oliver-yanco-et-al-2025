# Create CSV of all species in the analysis based on model results outptus
# to be used by other scripts to produce figures

library(data.table)
library(tidyverse)

rm(list = ls())
.wd <- getwd()
.datPF <- file.path(.wd, "out/covid_results")

# species results
area_ghm_new <- read_csv(list.files(path = .datPF, 
                                    pattern = "^area_ghm_effects_.*\\.csv$", 
                                    full.names = TRUE)) %>%
                dplyr::select(species)

area_sg_new <- read_csv(list.files(path = .datPF, 
                                   pattern = "^area_sg_effects_.*\\.csv$", 
                                   full.names = TRUE)) %>%
                mutate(response = rep("area_sg", nrow(.))) %>%
                dplyr::select(species)

niche_ghm_new <- read_csv(list.files(path = .datPF, 
                                     pattern = "^niche_ghm_effects_.*\\.csv$", 
                                     full.names = TRUE)) %>%
                  mutate(response = rep("niche_ghm", nrow(.))) %>%
                  dplyr::select(species)

niche_sg_new <- read_csv(list.files(path = .datPF, 
                                    pattern = "^niche_sg_effects_.*\\.csv$", 
                                    full.names = TRUE)) %>%
                mutate(response = rep("niche_sg", nrow(.))) %>%
                dplyr::select(species)

species_list <- data.frame(scientific_name = unique(c(
                                     area_ghm_new$species,
                                     area_sg_new$species,
                                     niche_ghm_new$species,
                                     niche_sg_new$species))) %>%
  mutate(common_name = rep(NA, n()),
         taxa = rep(NA, n())) %>%
  mutate(common_name = case_when(scientific_name == "Alces alces" ~ "Moose",
                                 scientific_name == "Accipiter gentilis" ~ "American goshawk",
                                 scientific_name == "Anas acuta" ~ "Northern pintail",
                                 scientific_name == "Anas americana" ~ "American wigeon",
                                 scientific_name == "Anas clypeata" ~ "Northern shoveler",
                                 scientific_name == "Anas crecca" ~ "Green-winged teal",
                                 scientific_name == "Anas cyanoptera" ~ "Cinnamon teal",
                                 scientific_name == "Anas discors" ~ "Blue-winged teal",
                                 scientific_name == "Anas platyrhynchos" ~ "Mallard",
                                 scientific_name == "Anas strepera" ~ "Gadwall",
                                 scientific_name == "Anser albifrons" ~ "GWF goose",
                                 scientific_name == "Anser caerulescens" ~ "Snow goose",
                                 scientific_name == "Antilocapra americana" ~ "Pronghorn",
                                 scientific_name == "Aquila chrysaetos" ~ "Golden eagle",
                                 scientific_name == "Ardea alba" ~ "Great egret",
                                 scientific_name == "Canis latrans" ~ "Coyote",
                                 scientific_name == "Canis lupus" ~ "Grey wolf", # new
                                 scientific_name == "Canis latrans" ~ "Coyote",
                                 scientific_name == "Cathartes aura" ~ "Turkey vulture", # new
                                 scientific_name == "Coragyps atratus" ~ "Black vulture", # new
                                 scientific_name == "Cervus elaphus" ~ "Elk",
                                 scientific_name == "Anser rossii" ~ "Ross's goose", # updated genus from Chen to Anser
                                 scientific_name == "Circus cyaneus" ~ "Northern harrier",
                                 scientific_name == "Corvus corax" ~ "Common raven",
                                 scientific_name == "Grus canadensis" ~ "Sandhill crane",
                                 scientific_name == "Haliaeetus leucocephalus" ~ "Bald eagle",
                                 scientific_name == "Lynx rufus" ~ "Bobcat",
                                 scientific_name == "Meleagris gallopavo" ~ "Wild turkey", # new
                                 scientific_name == "Numenius americanus" ~ "Long-billed curlew",
                                 scientific_name == "Odocoileus hemionus" ~ "Mule deer",
                                 scientific_name == "Odocoileus virginianus" ~ "White-tailed deer",
                                 scientific_name == "Ovis canadensis" ~ "Bighorn sheep",
                                 scientific_name == "Procyon lotor" ~ "Raccoon", # new
                                 scientific_name == "Puma concolor" ~ "Cougar",
                                 scientific_name == "Spilogale putorius" ~ "Plains spotted skunk", # new
                                 scientific_name == "Spilogale interrupta" ~ "Plains spotted skunk", # new
                                 scientific_name == "Sus scrofa" ~ "Wild pig", # new
                                 scientific_name == "Ursus americanus" ~ "Black bear",
                                 scientific_name == "Ursus arctos" ~ "Brown bear")) %>% # new
  mutate(taxa = case_when(scientific_name %in% c("Anas acuta",
                                                 "Anas americana",
                                                 "Anas clypeata",
                                                 "Anas crecca",
                                                 "Anas cyanoptera",
                                                 "Anas platyrhynchos",
                                                 "Anas strepera",
                                                 "Anser albifrons",
                                                 "Anser caerulescens",
                                                 "Aquila chrysaetos",
                                                 "Ardea alba",
                                                 "Aquila chrysaetos",
                                                 "Cathartes aura",
                                                 "Anser rossii", # updated genus from Chen to Anser
                                                 "Circus cyaneus",
                                                 "Corvus corax",
                                                 "Grus canadensis",
                                                 "Haliaeetus leucocephalus",
                                                 "Meleagris gallopavo", # new
                                                 "Numenius americanus",
                                                 "Rallus longirostris",
                                                 "Anas discors",
                                                 "Antigone canadensis",
                                                 "Accipiter gentilis", # new
                                                 "Coragyps atratus") ~ "birds", # new
                          scientific_name %in% c("Alces alces",
                                                 "Antilocapra americana",
                                                 "Canis latrans",
                                                 "Canis lupus", # new
                                                 "Cervus elaphus",
                                                 "Lynx rufus",
                                                 "Odocoileus hemionus",
                                                 "Odocoileus virginianus",
                                                 "Ovis canadensis",
                                                 "Procyon lotor", # new
                                                 "Puma concolor",
                                                 "Spilogale putorius", # new
                                                 "Sus scrofa", # new
                                                 "Ursus americanus",
                                                 "Ursus arctos") ~ "mammals"))

write_csv(species_list, file.path(.wd, "out/species_list.csv"))
  
