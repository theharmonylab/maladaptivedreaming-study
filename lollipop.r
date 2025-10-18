library(ggplot2)
library(dplyr)
library(tidyr)
library(forcats) # for factor ordering

# Create dataset
# Load dataset from CSV
data <- read.csv("results/themes.csv")
# Reorder Topic so that "Immersive Daydreaming" topics appear first, then "Maladaptive Daydreaming"
data <- data %>%
    arrange(Subreddit, Avg_Beta) %>%
    mutate(
        Topic_Label = paste0(Theme, " (", Count, ")"),
        Subreddit = factor(Subreddit, levels = c("Immersive Daydreaming", "Maladaptive Daydreaming")),
        Topic_Label = factor(Topic_Label, levels = rev(unique(Topic_Label))) # reverse so Immersive is on top
    )

# Set colorblind-friendly palette
theme_colors <- c(
    "Immersive Daydreaming" = "#0072B2", # Blue (colorblind-friendly)
    "Maladaptive Daydreaming" = "#E69F00" # Orange (colorblind-friendly)
)

lollipop <- ggplot(data, aes(x = Avg_Beta, y = Topic_Label, label = Avg_Beta, color = Subreddit)) +
    geom_segment(aes(x = 0, y = Topic_Label, xend = Avg_Beta, yend = Topic_Label, color = Subreddit)) +
    geom_point(aes(size = Prevalence), show.legend = TRUE) +
    scale_color_manual(values = theme_colors) +
    theme_minimal(base_size = 10) +
    theme(
        panel.grid.major = element_blank(), # Remove major gridlines
        panel.grid.minor = element_blank() # Remove minor gridlines
    ) +
    labs(x = "Average Effect Size", y = "Theme (Number of Topics)", size = "Prevalence")

ggsave("plots/lollipop.png", lollipop, width = 7, height = 5, dpi = 300, units = "in")
