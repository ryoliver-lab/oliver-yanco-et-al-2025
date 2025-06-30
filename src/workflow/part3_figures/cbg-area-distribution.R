# Create a figure that shows the census block groups that were used in the 
# analysis and the area of eacg

# Read in the CSV that is output from the intersection operation between the 
#   event and CBG polygons in the workflow. 
# Use the attribute `cbg_2010` for the code.
# Read in the `cbg-area.csv` to get areas for all CBGs.

library(tidyverse)
options(scipen = 999)

.wd <- getwd()
.datPF <- file.path(.wd, "out")
.outPF <- file.path(.wd, "out/figures")

int <- read_csv(file.path(.datPF, "event-cbg-intersection/event-cbg-intersection.csv"))

# check number of census blocks groups that intersected points
n_distinct(int$cbg_2010)

area <- read_csv(file.path(.datPF, "event-annotation/cbg-area.csv"))

# check number of unique census block groups
n_distinct(area$cbg_2010)

# Join the area, in square meters, to the CBGs that intersected events. 
# Subset the dataframe to just 1 row per unique census block group, because 
# we want to plot the distribution of the CBG areas regardless of how many 
# events ocurred in those CBGs.

int_area <- left_join(int, area, by = "cbg_2010") %>%
  # add column for km2
  mutate(cbg_area_km2 = cbg_area_m2/1000000)

int_area_unique <- int_area[!duplicated(int_area$cbg_area_km2), ]
nrow(int_area_unique) == n_distinct(int$cbg_2010)

# Find the median CBG area value
med <- round(median(int_area_unique$cbg_area_km2), 1)
text <- paste0("Median census block group area: ", med, " km²")

min(int_area_unique$cbg_area_km2)
max(int_area_unique$cbg_area_km2)

# Plot the distribution of the unique CBG areas used in our analysis
ggplot(int_area_unique, 
       aes(x = cbg_area_km2)) +
  geom_histogram(bins = 15, 
                 fill = "lightblue", 
                 color = "black") +
  # print counts per bin above bars
  geom_text(stat = "bin", 
            bins = 15,
            aes(y = after_stat(count), 
                label = ifelse(after_stat(count) > 0, 
                               after_stat(count), 
                               "")),
            vjust = -0.5,
            size = 3) +
  # add median CBG area as floating text
  annotate(
    "label",
    x = 39000,
    y = 16000,
    label = text,
    size = 4,
    color = "black",
    fill = "white") +
  theme_gray() +
  labs(title = "Census block group area sizes for COVID-19 wildlife movement analysis",
       subtitle = "Includes 2010 census block groups that contain GPS points 2019-2020\nValues above bars represent count of census block groups within size bin",
       x = "Census Block Group Area (kilometers²)",
       y = "Count")

ggsave(filename = file.path(.outPF, "figS5.pdf"))


