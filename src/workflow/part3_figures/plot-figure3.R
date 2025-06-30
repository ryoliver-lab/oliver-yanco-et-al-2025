#- Libraries
library(tidyverse)
library(brms)
library(glue)
library(patchwork)
library(here)

rm(list = ls())
.wd <- getwd()
.datPF <- file.path(.wd, "out/intra-ind-models")
.outPF <- file.path(.wd, "out/figures")

#- Color palette
pal <- c("#9a7aa0ff","#fcaf58ff")

#-- Load Data --#

#- Niche model
load(list.files(path = .datPF, 
                pattern = "^niche_intra_ind_int_rs_mod_.*\\.rdata$", 
                full.names = TRUE))
niche_int_mod <- out$model

#- Area Model
load(list.files(path = .datPF, 
                pattern = "^size_intra_ind_int_rs_mod_.*\\.rdata$", 
                full.names = TRUE))
area_int_mod <- out$model

#-- Plots --#

#- Niche model
niche_ghmq <- quantile(niche_int_mod$data$ghm_diff, probs = c(0.2, 0.8), na.rm = T)

niche_ce_int <- conditional_effects(x=niche_int_mod,
                                    effects = "sg_diff:ghm_diff",
                                    int_conditions = list(ghm_diff = niche_ghmq),
                                    re_formula = NA,
                                    prob = 0.9,
                                    method = "posterior_linpred")
(niche_int_ce_plot <-  plot(niche_ce_int, 
                            plot = F,
                            rug = F,
                            line_args = list("se" = T))[[1]] + 
    scale_color_manual(name ="Changes in human modification",
                       values = rev(pal),
                       labels = c("high",
                                  "low")) +
    scale_fill_manual(name ="Changes in human modification",
                      values = rev(pal),
                      labels = c("high",
                                 "low")) +
    theme_minimal() +
    geom_vline(aes(xintercept = 0), linetype = "dashed") +
    geom_hline(aes(yintercept = 0), linetype = "dashed") +
    theme_minimal() +
    theme(panel.grid.minor.y = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.border = element_rect(colour = "#4a4e4d", fill=NA, size=0.5),
          legend.position = "none",
          legend.title = element_blank(),
          axis.text = element_text(size = 7),
          axis.title = element_text(size = 7),
          legend.text = element_text(size = 7),
          axis.ticks = element_line(color = "#4a4e4d")) +
    scale_y_continuous(expand = expansion(mult = c(0, 0))) +  
    scale_x_continuous(expand = expansion(mult = c(0, 0)),
                       labels = scales::comma) +  
    labs(x = "Relative change in \n human mobility", y = "Standardized change \n in niche size")
)

#- Area Model

area_ghmq <- quantile(area_int_mod$data$ghm_diff, probs = c(0.2, 0.8), na.rm = T)

area_ce_int <- conditional_effects(x=area_int_mod,
                                  effects = "sg_diff:ghm_diff",
                                  int_conditions = list(ghm_diff = area_ghmq),
                                  re_formula = NA,
                                  prob = 0.9,
                                  method = "posterior_linpred")

(area_int_ce_plot <-  plot(area_ce_int, 
                           plot = F,
                           rug = F,
                           line_args = list("se" = T))[[1]] + 
    scale_color_manual(name ="Changes in human modification",
                       values = rev(pal),
                       labels = c("high",
                                  "low")) +
    scale_fill_manual(name ="Changes in human modification",
                      values = rev(pal),
                      labels = c("high",
                                 "low")) +
    theme_minimal() +
    geom_vline(aes(xintercept = 0), linetype = "dashed", lwd = 0.5) +
    geom_hline(aes(yintercept = 0), linetype = "dashed") +
    theme_minimal() +
    theme(panel.grid.minor.y = element_blank(),
          panel.grid.minor.x = element_blank(),
          
          panel.border = element_rect(colour = "#4a4e4d", fill=NA, size=0.5),
          legend.position = "none",
          legend.title = element_blank(),
          axis.text = element_text(size = 7),
          axis.title = element_text(size = 7),
          legend.text = element_text(size = 7),
          axis.ticks = element_line(color = "#4a4e4d")) +
    scale_y_continuous(expand = expansion(mult = c(0, 0))) +  
    scale_x_continuous(expand = expansion(mult = c(0, 0)),
                       labels = scales::comma) +  
    labs(x = "Relative change in \n human mobility", y = "Standardized change \n in area size")
)

#- Combine plots

(comb_plot <- area_int_ce_plot + niche_int_ce_plot + plot_layout(guides = "collect"))

ggsave(comb_plot, file = file.path(.outPF, "fig3.pdf"), height = 45, width = 90, units = "mm")



####----    Summarize effects Size ----####


library(emmeans)
library(bayestestR)
##-- Niche  --##

#- Get Marginal Effects at Median -#
niche_med_sg <- median(niche_out$data$sg_diff, na.rm = T)
niche_med_ghm <- median(niche_out$data$ghm_diff, na.rm = T)


# Stash df in out lists
(niche_ghm_effects <- emtrends(niche_int_mod, ~ "sg_diff", var = "ghm_diff", 
                               at = list("sg_diff" = niche_med_sg))  %>% 
    as.data.frame() %>% 
    rename("Estimate" = "ghm_diff.trend",
           "LCL" = "lower.HPD",
           "HCL" = "upper.HPD") 
)

(niche_sg_effects <- emtrends(niche_int_mod, ~ "ghm_diff", var = "sg_diff", 
                              at = list("ghm_diff" = niche_med_ghm))  %>% 
    as.data.frame() %>% 
    rename("Estimate" = "sg_diff.trend",
           "LCL" = "lower.HPD",
           "HCL" = "upper.HPD") 
)

parameters::parameters(niche_int_mod)

##-- Area  --##

#- Get Marginal Effects at Median -#
area_med_sg <- median(area_out$data$sg_diff, na.rm = T)
area_med_ghm <- median(area_out$data$ghm_diff, na.rm = T)

# Stash df in out lists
(area_ghm_effects <- emtrends(area_int_mod, ~ "sg_diff", var = "ghm_diff", 
                              at = list("sg_diff" = area_med_sg))  %>% 
    as.data.frame() %>% 
    rename("Estimate" = "ghm_diff.trend",
           "LCL" = "lower.HPD",
           "HCL" = "upper.HPD") )

(area_sg_effects <- emtrends(area_int_mod, ~ "ghm_diff", var = "sg_diff", 
                             at = list("ghm_diff" = area_med_ghm))  %>% 
    as.data.frame() %>% 
    rename("Estimate" = "sg_diff.trend",
           "LCL" = "lower.HPD",
           "HCL" = "upper.HPD") )

parameters::parameters(area_int_mod)
