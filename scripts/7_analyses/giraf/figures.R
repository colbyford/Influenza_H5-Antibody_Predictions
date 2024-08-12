library(readr)
library(readxl)
library(dplyr)
library(ggplot2)
library(ggpubr)

## Load in antigen metadata
antigens <- read_excel("../../../Experiments.xlsx", sheet = "Antigens") %>% 
  select(antigen_id, antigen_host_class, antigen_host_order, antigen_collection_year)

## Define list of GIRAF output paths
giraf_paths <- c("AVFluIgG01__EPI242227.tsv")

giraf_data <- data.frame(
  antigen_id = character(0),
  ged = integer(0),
  num_ir = integer(0),
  antibody_id = character(0)
)


## Read in each GIRAF output and append to 
for (giraf_path in giraf_paths){
  print(giraf_path)
  antibody_id = strsplit(giraf_path, "__")[[1]][[1]]
  
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
antigens <- antigens %>%
  left_join(giraf_data)



## Make scatter plots

ged_scatter_plot <- ggplot(antigens %>% filter(#antigen_collection_year >= 2000,
  antigen_host_order %in% c("Anseriformes", "Galliformes", "Primates")
),
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
           label.y = min(antigens$ged)
  ) +
  scale_x_continuous(breaks=c(2000,2005,2010,2015,2020,2024), limits = c(2000, 2024)) +
  scale_color_manual(values = c("#005035", "#005035", "#802F2D")) + ## UNCC Colors
  facet_wrap(~ antigen_host_order, ncol = 3) +
  labs(y = "Graph Edit Distance (From EPI242227)",
       x = 'Collection Year',
       color = "Host Order") +
  theme_linedraw() +
  # theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        line = element_line(colour = "grey"),
        axis.line = element_line(color = "grey"),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "grey"),
        legend.position = "none"
  )


numir_scatter_plot <- ggplot(antigens %>% filter(#antigen_collection_year >= 2000,
  antigen_host_order %in% c("Anseriformes", "Galliformes", "Primates")
),
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
           label.y = min(antigens$num_ir)
  ) +
  scale_x_continuous(breaks=c(2000,2005,2010,2015,2020,2024), limits = c(2000, 2024)) +
  scale_color_manual(values = c("#005035", "#005035", "#802F2D")) + ## UNCC Colors
  facet_wrap(~ antigen_host_order, ncol = 3) +
  labs(y = "Number of Interfacing Residus",
       x = 'Collection Year',
       color = "Host Order") +
  theme_linedraw() +
  # theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        line = element_line(colour = "grey"),
        axis.line = element_line(color = "grey"),
        panel.grid.minor = element_blank(),
        panel.grid.major = element_line(color = "grey"),
        legend.position = "none"
  )


ggarrange(ged_scatter_plot,
          numir_scatter_plot,
          labels = c("A.", "B."),
          ncol = 1, nrow = 2, align = "hv")
