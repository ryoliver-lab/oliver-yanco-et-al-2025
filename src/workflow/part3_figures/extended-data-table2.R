# This is a supplementary figure to show the number of individuals, weeks, and 
# individual-years per species, which are pulled from the model files. The model
# diagnostics PDFs show whether the interactive or additive model was selected 
# per species.

library(tidyverse)
library(here)
library(glue)
library(janitor)
options(scipen = 999)

### Area

# Define a list of the 9 species for which the interactive area model was 
# selected. This was created by looking at all 37 model diagnostic PDFs. The 
# species not listed had the additive model selected.

# Note that for species that had name changes (skunk, elk, goshawk) these name 
# changes were not made to the species-specific model files, hence we do not 
# update the names until the end when we create the df for the figure. 

species_df <- read_csv(here("src", "species_list.csv"))
all_species <- species_df$scientific_name

interactive_spp <- c("Anas acuta",
                     "Anas discors",
                     "Canis lupus",
                     "Cervus elaphus",
                     "Lynx rufus",
                     "Meleagris gallopavo",
                     "Numenius americanus",
                     "Odocoileus hemionus",
                     "Puma concolor")

# Loop through all 37 species and load the selected model file to extract the 
# number of individuals, weeks, and individual-years. These values are stored in 
# a dataframe that is saved out to a CSV.

area_all <- data.frame()

area_additive_prefix <- file.path(here("src", "extended-data-table2", "single_species_models_final", "area_additive"))
area_interactive_prefix <- file.path(here("src", "extended-data-table2", "single_species_models_final", "area_interactive"))

for (sp in all_species){
  
  print(paste0("Processing ", sp))
  
  # Load either the interactive or additive model,
  # depending on which was selected
  if (sp %in% interactive_spp){
    
    mod <- list.files(area_interactive_prefix, 
                      pattern = paste0("^", sp), 
                      full.names = TRUE)
    
  } else {
    mod <- list.files(area_additive_prefix, 
                      pattern = paste0("^", sp), 
                      full.names = TRUE)
  }
  
  print(paste0("Loading model ", mod))
  
  load(mod)
  data_1 <- out$data
  
  # calc number of individuals and weeks of data, 
  # limiting each week count to be from one study only
  data_sum_tbl <- data_1 %>% 
    group_by(study_id) %>% 
    summarize(num_inds = n_distinct(ind_f),
              num_weeks = n_distinct(wk)) %>%
    adorn_totals()
  
  n_inds <- data_sum_tbl %>%
    filter(study_id == "Total") %>%
    pull(num_inds)
  
  n_weeks <- data_sum_tbl %>%
    filter(study_id == "Total") %>%
    pull(num_weeks)
  
  n_ind_yrs <- n_distinct(data_1$grp)
  
  # species specific values
  sp_out <- data.frame("species" = sp,
                       "n_ind" = n_inds,
                       "n_weeks" = n_weeks,
                       "n_ind_yrs" = n_ind_yrs)
  
  # append to area model values for all species
  area_all <- rbind(area_all, sp_out)
  
}

# add common names to area model output for all species
area_all <- area_all %>% 
  left_join(species_df, by = join_by("species" == "scientific_name")) %>% 
  select(-taxa) %>% 
  relocate(common_name, .after = species)

### Niche

# Repeat the same process for niche models, but since all niche models selected 
# additive, there's no need to bother with loading any interactive models.

niche_all <- data.frame()

niche_additive_prefix <- file.path(here("src", "extended-data-table2", "single_species_models_final", "niche_additive"))

for (sp in all_species){
  
  print(paste0("Processing ", sp))
  
  mod <- list.files(niche_additive_prefix, 
                    pattern = paste0("^", sp), 
                    full.names = TRUE)
  
  print(paste0("Loading model ", mod))
  load(mod)
  
  data_1 <- out$data
  
  # calc number of individuals and weeks of data, 
  # limiting each week count to be from one study only
  data_sum_tbl <- data_1 %>% 
    group_by(studyid) %>% 
    summarize(num_inds = n_distinct(ind_f),
              num_weeks = n_distinct(week)) %>%
    adorn_totals()
  
  n_inds <- data_sum_tbl %>%
    filter(studyid == "Total") %>%
    pull(num_inds)
  
  n_weeks <- data_sum_tbl %>%
    filter(studyid == "Total") %>%
    pull(num_weeks)
  
  n_ind_yrs <- n_distinct(data_1$grp)
  
  sp_out <- data.frame("species" = sp,
                       "n_ind" = n_inds,
                       "n_weeks" = n_weeks,
                       "n_ind_yrs" = n_ind_yrs)
  
  niche_all <- rbind(niche_all, sp_out)
  
}

# add common names
niche_all <- niche_all %>% 
  left_join(species_df, by = join_by("species" == "scientific_name")) %>% 
  select(-taxa) %>% 
  relocate(common_name, .after = species)

# Join Area and Niche dataframes

combined <- area_all %>% 
  left_join(niche_all, 
            by = "species", 
            suffix = c("_area", "_niche")) %>%
  # remove redundant col
  select(-common_name_niche) %>%
  rename(common_name = common_name_area) %>% 
  # update species names so they match those in the fixrate df
  mutate(species = case_when(
    species == "Spilogale putorius" ~ "Spilogale interrupta",
    species == "Cervus elaphus" ~ "Cervus canadensis",
    species == "Accipiter gentilis" ~ "Astur atricapillus",
    TRUE ~ species)) %>% 
  mutate(common_name = case_when(
    common_name == "E. spotted skunk" ~ "Plains spotted skunk",
    TRUE ~ common_name))

# Fix rate

# Add a column for fix rate by joining the fix rate medians dataframe to the
# combined df. This table with fix rate should be formatted for the PDF.

med_fixrates <- read_csv(here("src/fixrate/fixrate_sp_median.csv")) %>% 
  select(species, med_fixrate_hours) %>% 
  mutate(med_fixrate_hours = round(med_fixrate_hours, 2))

combined_w_fix <- merge(combined, med_fixrates, by = "species")

write_csv(combined_w_fix, here("figures", "extended_data_table_2.csv"))
