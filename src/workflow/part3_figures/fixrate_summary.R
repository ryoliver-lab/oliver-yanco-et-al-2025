# Fix rate median per species was calculated using the workflow script 
# `fix_rate_fig.r` with the cleaned data that made it into our results, meaning 
# we only considered the fix rate for individuals with at least 30 fixes per week 
# during our months of interest in 2019-2020. We further cleaned individual-level 
# data by removing outliers, excluding values that exceeded the 95th quantile for 
# turn angle, bearing, and velocity. To calculate the time between each consecutive 
# fix remaining in the cleaned data, we grouped our event data by individual-year 
# pairings and ordered by timestamp. We calculated the median minutes between each 
# consecutive fix using the R package “move.” We then grouped all individuals by 
# species and determined the median of the median time between fixes. This data 
# will be added to Extended Data Table 2.

library(tidyverse)
options(scipen = 999)

.wd <- getwd()
.datPF <- file.path(.wd, "out")
.outPF <- file.path(.wd, "out/figures")

fixrate_species <- read_csv(file.path(.datPF, "fixrate_sp_median.csv"))

ggplot(fixrate_species, aes(x = species, y = med_fixrate_hours)) +
  geom_point(size = 2) +
  labs(title = "Fix Rate Median by Species, 2019-2020",
       subtitle = "Median number of hours between each consecutive fix within species",
       x = "Species",
       y = "Fix Rate (hours)") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 60, hjust = 1))

ggsave(file.path(.outPF, "fixrate_sp_median.pdf"))