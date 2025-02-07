library(readr)
library(readxl)
library(dplyr)
library(ggplot2)
library(ggpubr)

## Load in antigen metadata
antigens <- read_excel("../../../Experiments.xlsx", sheet = "Antigens") %>% 
  select(antigen_id, antigen_host_class, antigen_host_order, antigen_collection_year)

## Define list of GIRAF output paths
giraf_paths <- list.files(path = "../../../data/ged_tables/", pattern = "__EPI242227\\.tsv$", full.names = TRUE, ignore.case = TRUE)

giraf_data <- data.frame(
  antigen_id = character(0),
  ged = integer(0),
  num_ir = integer(0),
  antibody_id = character(0)
)


## Read in each GIRAF output and append to 
for (giraf_path in giraf_paths){
  print(giraf_path)
  # antibody_id = strsplit(strsplit(giraf_path, "//")[[1]][[2]], "__")[[1]][[1]] ## unix
  antibody_id = strsplit(strsplit(giraf_path, "/")[[1]][[6]], "__")[[1]][[1]] ## windows
  
  giraf_data_iter <- read.csv(giraf_path,
                         sep = "\t",
                         col.names = c(
                           "antigen_id",
                           "ged",
                           "num_ir")
                         ) %>% 
    mutate(antibody_id = antibody_id)
  
  giraf_data <- rbind(giraf_data, giraf_data_iter)
}

## Join back to the antigen metadata
giraf_data_full <- giraf_data %>% 
  full_join(antigens)

# write_csv(giraf_data_full, "giraf_data_full.csv")

## Make scatter plots

## Find all statistically significant spearman correlations 
## of ged/num_ir for pairs of antigen_host_order and antibody_id
ged_correlations <- giraf_data_full %>% 
  filter(
    # antigen_host_order %in% c("Anseriformes", "Galliformes", "Primates"),
    antigen_host_order %in% c("Primates"),
    antigen_collection_year >= 2000
         ) %>% 
  group_by(antigen_host_order, antibody_id) %>% 
  summarise(correlation = cor.test(ged, antigen_collection_year, method = "spearman")$estimate,
            p_value = cor.test(ged, antigen_collection_year, method = "spearman")$p.value) %>% 
  mutate(comparison = paste0(antigen_host_order, "__", antibody_id)) %>% 
  filter(p_value < 0.05)

numir_correlations <- giraf_data_full %>% 
  filter(
    # antigen_host_order %in% c("Anseriformes", "Galliformes", "Primates"),
    antigen_host_order %in% c("Primates"),
    antigen_collection_year >= 2000
    ) %>% 
  group_by(antigen_host_order, antibody_id) %>% 
  summarise(correlation = cor.test(num_ir, antigen_collection_year, method = "spearman")$estimate,
            p_value = cor.test(num_ir, antigen_collection_year, method = "spearman")$p.value) %>% 
  mutate(comparison = paste0(antigen_host_order, "__", antibody_id)) %>% 
  filter(p_value < 0.05)

### GED Plot with all Antibodies
ged_scatter_plot_data <- giraf_data_full %>% filter(#antibody_id %in% c("AVFluIgG01", "FLD194"),
  # antigen_host_order %in% c("Anseriformes", "Galliformes", "Primates")
  antigen_host_order %in% c("Primates")
) %>% mutate(antigen_host_order = "Humans")

ged_scatter_plot <- ggplot(ged_scatter_plot_data,
aes_string(
  x = "antigen_collection_year",
  y = "ged",
  group = "antigen_host_order",
  color = "antigen_host_order",
  alpha = 0.35
)) + 
  geom_point() +
  geom_smooth(method = lm,
              se = TRUE,
              col='black',
              linetype="dashed",
              linewidth=1,
              # fullrange=TRUE
  ) +
  stat_cor(method = "spearman",
           color = "black",
           label.x = 2000,
           label.y = min(giraf_data_full$ged)
  ) +
  annotate("text",
           x = 2020,
           y = min(giraf_data_full$ged),
           label = paste("n = ", nrow(ged_scatter_plot_data))
           ) +
  scale_x_continuous(breaks=c(2000,2005,2010,2015,2020,2024), limits = c(2000, 2024)) +
  # scale_color_manual(values = c("#005035", "#005035", "#802F2D")) + ## UNCC Colors
  scale_color_manual(values = c("#802F2D")) + ## UNCC Colors
  # facet_wrap(antibody_id ~ antigen_host_order, ncol = 3) +
  facet_wrap( ~ antigen_host_order, ncol = 3) +
  labs(y = "Graph Edit Distance (from EPI242227)",
       x = 'Collection Year',
       color = "Host Order") +
  theme_linedraw() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        line = element_line(colour = "grey"),
        axis.line = element_line(color = "grey"),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "grey"),
        legend.position = "none"
  )

## GED Plot with examples
# ged_scatter_plot_fabs <- ggplot(giraf_data_full %>% filter(antibody_id %in% c("AVFluIgG01", "FLD194", "H5.3"),
#   antigen_host_order %in% c("Anseriformes", "Galliformes", "Primates")
# ),

ged_scatter_plot_fabs_data <- giraf_data_full %>% 
  mutate(comparison = paste0(antigen_host_order, "__", antibody_id)) %>% 
  filter(comparison %in% c(ged_correlations$comparison)) %>% mutate(antigen_host_order = "Humans")

ged_scatter_plot_fabs <- ggplot(ged_scatter_plot_fabs_data,
aes_string(
  x = "antigen_collection_year",
  y = "ged",
  group = "antigen_host_order",
  color = "antigen_host_order"#,
  # alpha = 0.35
)) + 
  geom_point() +
  geom_smooth(method = lm,
              se = TRUE,
              col='black',
              linetype="dashed",
              linewidth=1,
              # fullrange=TRUE
  ) +
  stat_cor(method = "spearman",
           color = "black",
           label.x = 2000,
           label.y = min(giraf_data_full$ged) + 5
  ) +
  annotate("text",
           x = 2020,
           y = min(giraf_data_full$ged) + 5,
           label = paste("n = ", nrow(ged_scatter_plot_fabs_data))
  ) +
  scale_x_continuous(breaks=c(2000,2005,2010,2015,2020,2024), limits = c(2000, 2024)) +
  # scale_color_manual(values = c("#005035", "#802F2D")) + ## UNCC Colors
  scale_color_manual(values = c("#802F2D")) + ## UNCC Colors
  facet_wrap(antibody_id ~ antigen_host_order, ncol = 3, labeller = label_wrap_gen(multi_line=FALSE)) +
  # facet_wrap( ~ antigen_host_order, ncol = 3) +
  labs(y = "Graph Edit Distance (from EPI242227)",
       x = 'Collection Year',
       color = "Host Order") +
  theme_linedraw() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        line = element_line(colour = "grey"),
        axis.line = element_line(color = "grey"),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "grey"),
        legend.position = "none"
  )

### Number of Interfacing Residues plot with all antibodies

numir_scatter_plot_data <- giraf_data_full %>% filter(#antibody_id %in% c("AVFluIgG01", "FLD194", "H5.3"),
  # antigen_host_order %in% c("Anseriformes", "Galliformes", "Primates")
  antigen_host_order %in% c("Primates")
) %>% mutate(antigen_host_order = "Humans")

numir_scatter_plot <- ggplot(numir_scatter_plot_data,
aes_string(
  x = "antigen_collection_year",
  y = "num_ir",
  group = "antigen_host_order",
  color = "antigen_host_order",
  alpha = 0.35
)) + 
  geom_point() +
  geom_smooth(method = lm,
              se = TRUE,
              col='black',
              linetype="dashed",
              linewidth=1,
              # fullrange=TRUE
  ) +
  stat_cor(method = "spearman",
           color = "black",
           label.x = 2000,
           label.y = min(giraf_data_full$num_ir)
  ) +
  annotate("text",
           x = 2020,
           y = min(giraf_data_full$num_ir),
           label = paste("n = ", nrow(numir_scatter_plot_data))
  ) +
  scale_x_continuous(breaks=c(2000,2005,2010,2015,2020,2024), limits = c(2000, 2024)) +
  # scale_color_manual(values = c("#005035", "#005035", "#802F2D")) + ## UNCC Colors
  scale_color_manual(values = c("#802F2D")) + ## UNCC Colors
  # facet_wrap(antibody_id ~ antigen_host_order, ncol = 3) +
  facet_wrap( ~ antigen_host_order, ncol = 3) +
  labs(y = "Number of Interfacing Residues",
       x = 'Collection Year',
       color = "Host Order") +
  theme_linedraw() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        line = element_line(colour = "grey"),
        axis.line = element_line(color = "grey"),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "grey"),
        legend.position = "none"
  )

### Number of Interfacing Residues plot with examples
# numir_scatter_plot_fabs <- ggplot(giraf_data_full %>% filter(antibody_id %in% c("AVFluIgG01", "FLD194", "3C11"),
#   antigen_host_order %in% c("Anseriformes", "Galliformes", "Primates")
# ),

numir_scatter_plot_fabs_data <- giraf_data_full %>% 
  mutate(comparison = paste0(antigen_host_order, "__", antibody_id)) %>% 
  filter(comparison %in% c(numir_correlations$comparison)) %>% mutate(antigen_host_order = "Humans")

numir_scatter_plot_fabs <- ggplot(numir_scatter_plot_fabs_data,
aes_string(
  x = "antigen_collection_year",
  y = "num_ir",
  group = "antigen_host_order",
  color = "antigen_host_order"#,
  # alpha = 0.35
)) + 
  geom_point() +
  geom_smooth(method = lm,
              se = TRUE,
              col='black',
              linetype="dashed",
              linewidth=1,
              # fullrange=TRUE
  ) +
  stat_cor(method = "spearman",
           color = "black",
           label.x = 2000,
           label.y = min(giraf_data_full$num_ir) + 2
  ) +
  annotate("text",
           x = 2020,
           y = min(giraf_data_full$num_ir) + 2,
           label = paste("n = ", nrow(numir_scatter_plot_fabs_data))
  ) +
  scale_x_continuous(breaks=c(2000,2005,2010,2015,2020,2024), limits = c(2000, 2024)) +
  # scale_color_manual(values = c("#005035", "#802F2D")) + ## UNCC Colors
  scale_color_manual(values = c("#802F2D")) + ## UNCC Colors
  facet_wrap(antibody_id ~ antigen_host_order, ncol = 2, labeller = label_wrap_gen(multi_line=FALSE)) +
  # facet_wrap( ~ antigen_host_order, ncol = 3) +
  labs(y = "Number of Interfacing Residues",
       x = 'Collection Year',
       color = "Host Order") +
  theme_linedraw() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        line = element_line(colour = "grey"),
        axis.line = element_line(color = "grey"),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "grey"),
        legend.position = "none"
  )

## Combine plots
ggarrange(ged_scatter_plot,
          ged_scatter_plot_fabs,
          numir_scatter_plot,
          numir_scatter_plot_fabs,
          labels = c("a", "b", "c", "d"),
          ncol = 4, nrow = 1, align = "hv")

## Save plot
# ggsave("../../../figures/giraf_scatter_by_year.pdf", width = 12.75, height = 8.25, units = "in")
# ggsave("../../../figures/giraf_scatter_by_year_Primates.pdf", width = 8.5, height = 7.5, units = "in")
# ggsave("../../../figures/giraf_scatter_by_year_Humans.pdf", width = 5, height = 14, units = "in")
ggsave("../../../figures/giraf_scatter_by_year_Humans.pdf", width = 14, height = 5, units = "in")
