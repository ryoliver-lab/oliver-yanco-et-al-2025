# Plot figures S3 and S4 that represent the posterior distributions for species
# estimates for effect of human mobility on area size and niche size and 
# interactive effect of human modification and human mobility on area size and
# niche size.

library(brms)
library(tidyverse)
library(tidybayes)
library(ggthemes)
library(ggdist)
library(glue)
library(patchwork)

.wd <- getwd()
.datPF <- file.path(.wd, "out/intra-ind-models")
.outPF <- file.path(.wd, "out/figures")

# load area and niche models
load(list.files(path = .datPF, 
                pattern = "^size_intra_ind_int_rs_mod_.*\\.rdata$", 
                full.names = TRUE))

area_mod <- out$model

load(list.files(path = .datPF, 
                pattern = "^niche_intra_ind_int_rs_mod_.*\\.rdata$", 
                full.names = TRUE))

niche_mod <- out$model

# Function to get posterior of offsets
extract_species_slopes <- function(mod, param) {
  # Convert model draws to data frame
  draws <- as_draws_df(mod)
  
  # Construct full parameter names
  fixed_name <- paste0("b_", param)
  # Construct parameter axes label in plot
  if (param == "sg_diff"){
    param_axis_label <- paste0("Posterior distribution of\neffect of human mobility")
  } else if (param == "sg_diff:ghm_diff")
    param_axis_label <- paste0("Posterior distribution of interactive effect of\nhuman mobility and landscape modification")
  
  # set a pattern based on if the model used species or scientific name for col
  random_pattern <- ifelse(deparse(substitute(mod)) == "area_mod",
                           paste0("r_species\\[.*?,", param, "\\]"),
                           paste0("r_scientificname\\[.*?,", param, "\\]"))
  #random_pattern <- paste0("r_species\\[.*?,", param, "\\]")
  
  print(paste0("pattern is: ", random_pattern))
  
  # Extract fixed effect vector
  fixed <- draws[[fixed_name]]
  
  # Find and extract relevant random effect columns
  random_cols <- grep(random_pattern, colnames(draws), value = TRUE)
  
  # Reshape to long format and compute total slope
  if (deparse(substitute(mod)) == "area_mod") {
    random_long <- draws %>%
      select(all_of(random_cols)) %>%
      mutate(.row = row_number()) %>%
      pivot_longer(-.row, names_to = "param_name", values_to = "r_species") %>%
      mutate(
        species = gsub(paste0("r_species\\[(.*?),", param, "\\]"), "\\1", param_name),
        fixed = fixed[.row],
        total_slope = fixed + r_species)
  } else {
    random_long <- draws %>%
      select(all_of(random_cols)) %>%
      mutate(.row = row_number()) %>%
      pivot_longer(-.row, names_to = "param_name", values_to = "r_scientificname") %>%
      mutate(
        species = gsub(paste0("r_scientificname\\[(.*?),", param, "\\]"), "\\1", param_name),
        fixed = fixed[.row],
        total_slope = fixed + r_scientificname)
  }
  
  # Summarize slope distributions by species
  slopes_sum <- random_long %>%
    group_by(species) %>%
    summarise(
      pd = bayestestR::p_direction(total_slope),
      median_qi(total_slope, .width = 0.95),
      .groups = "drop"
    ) %>%
    arrange(desc(pd))
  
  plt <- ggplot(random_long, aes(x = reorder(species, total_slope), y = total_slope)) +
    stat_halfeye(.width = c(0.9, 0.5), fill = "#3182bd", alpha = 0.7, slab_color = NA) +
    # geom_pointrange(aes(ymin = ymin, ymax = ymax)) +
    geom_hline(yintercept = median(fixed), linetype = "dashed") +
    geom_hline(yintercept = 0)+
    coord_flip() +
    labs(
      x = "Species",
      y = glue("{param_axis_label}"),
      # title = "Posterior of species-specific effects"
    ) +
    theme_minimal()+
    theme(plot.title = element_text(hjust = -1))
  
  # Return both as a list
  list(
    random_long = random_long,
    slopes_sum = slopes_sum,
    fixed = fixed,
    plot = plt
  )
}

# --- fig S3 --- #

area_sg <- extract_species_slopes(mod = area_mod, param = "sg_diff")
area_int <- extract_species_slopes(mod = area_mod, param = "sg_diff:ghm_diff")

(area_plot <- (area_sg$plot + ylim(-3,3)) + (area_int$plot + ylim(-1,1)) + plot_annotation(tag_levels = 'A'))

ggsave(plot = area_plot, 
       filename = file.path(.outPF, "figS3.png"),
       width = 12, height = 12)

# --- fig S4 --- #

niche_sg <- extract_species_slopes(mod = niche_mod, param = "sg_diff")
niche_int <- extract_species_slopes(mod = niche_mod, param = "sg_diff:ghm_diff")

nicheInset_data <- niche_sg$random_long %>%
  filter(species == "Antilocapra.americana")

nicheInset_data$species <- as.factor(nicheInset_data$species)

(nicheInset <- nicheInset_data %>% 
    ggplot(aes(x = reorder(species, total_slope), y = total_slope)) +
    stat_halfeye(.width = c(0.9, 0.5), fill = "#3182bd", alpha = 0.7, slab_color = NA) +
    # geom_pointrange(aes(ymin = ymin, ymax = ymax)) +
    geom_hline(yintercept = median(nicheInset_data$fixed), linetype = "dashed") +
    geom_hline(yintercept = 0)+
    coord_flip() +
    labs(
      # x = "Species",
      # y = glue("Slope: {param}"),
      title = "Antilocapra.americana"
    ) +
    # ylim(-15,15)+
    theme_bw()+
    theme(plot.title = element_text(hjust = 0, size = 10),
          axis.title = element_blank(),
          axis.text.y = element_blank()))

nicheInset_grob <- ggplotGrob(nicheInset)

nicheA1_data <- niche_sg$random_long %>% 
  filter(species != "Antilocapra.americana")

nicheA1_data$species <- as.factor(nicheA1_data$species)

(nicheA1 <- nicheA1_data %>% 
    ggplot(aes(x = reorder(species, total_slope), y = total_slope)) +
    stat_halfeye(.width = c(0.9, 0.5), fill = "#3182bd", alpha = 0.7, slab_color = NA) +
    # geom_pointrange(aes(ymin = ymin, ymax = ymax)) +
    geom_hline(yintercept = median(nicheA1_data$fixed), linetype = "dashed") +
    geom_hline(yintercept = 0)+
    coord_flip() +
    labs(
      x = "Species",
      y = paste0("Posterior distribution of\neffect of human mobility"),
      # title = "Posterior of species-specific effects"
    ) +
    ylim(-15,15)+
    annotation_custom(
      grob = nicheInset_grob,
      xmin = 7, xmax = 9,  # adjust position on x-axis (species rank)
      ymin = -15, ymax = -2  # adjust position on y-axis (total_slope)
    )+
    theme_minimal()+
    theme(plot.title = element_text(hjust = -1)))

(niche_plot <- (nicheA1) + (niche_int$plot + ylim(-1,1)) + plot_annotation(tag_levels = 'A'))

ggsave(plot = niche_plot, 
       filename = file.path(.outPF, "figS4.png"),
       width = 12, height = 12)
