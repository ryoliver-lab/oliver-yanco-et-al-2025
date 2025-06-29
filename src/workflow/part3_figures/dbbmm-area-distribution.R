# Produce a figure that shows the dBBMM area sizes, similar to the census block 
# group size figure. This will be a response to reviewers, not a supp figure. 
# Use the area attribute, units = square meters and convert to square km, 
# of dbbmm_size.csv

library(tidyverse)
library(patchwork)
options(scipen = 999)

.wd <- getwd()
.datPF <- file.path(.wd, "out")
.outPF <- file.path(.wd, "out/figures")

ud <- read_csv(file.path(.datPF, "dbbmm_size.csv")) %>% 
  mutate(area_km2 = area/1000000)

med <- round(median(ud$area_km2), 1)
text <- paste0("Median utilization distribution area: ", med, " km²")

min(ud$area_km2)
max(ud$area_km2)

# Plot the distribution of the unique utilization distributions 
# areas used in our analysis

distrib <- ggplot(ud, 
                  aes(x = area_km2)) +
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
  # add median area as floating text
  annotate("label",
           x = 8500,
           y = 94000,
           label = text,
           size = 4,
           color = "black",
           fill = "white") +
  theme_gray() +
  labs(title = "Utilization distribution area sizes for COVID-19 wildlife movement analysis",
       subtitle = "Areas calculated per individual-year-week, 2019-2020\nValues above bars represent count of utilization distributions within size bin",
       x = "Utilization Distribution Area (kilometers²)",
       y = "Count")

print(distrib)

inset <- ggplot(ud %>% 
                  filter(area_km2 <= 50), 
                aes(x = area_km2)) +
  geom_histogram(bins = 50, 
                 fill = "lightblue", 
                 color = "black") +
  theme_minimal() +
  theme(plot.background = element_rect(fill = "white", color = "black"),
        plot.margin = margin(5, 5, 5, 5)) +
  labs(title = "Area sizes <50 kilometers²",
       x = NULL,
       y = NULL) +
  theme(plot.title = element_text(size = 10))

print(inset)


distrib + inset_element(inset, left = 0.4, bottom = 0.16, right = 1, top = 0.8) + theme_gray()

ggsave(filename = file.path(.outPF, "figS6.pdf"))
