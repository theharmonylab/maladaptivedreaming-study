# Load custom stopwords from file (one word per line)
read_custom_stopwords <- function(filepath) {
    if (file.exists(filepath)) {
        scan(filepath, what = character(), sep = "\n", quiet = TRUE)
    } else {
        character(0)
    }
}
custom_stopwords <- read_custom_stopwords("custom_stopwords.txt")
stop_list <- c(custom_stopwords, stopwords::stopwords("en", source = "snowball"))
#-------------------------------------------------
# 3. Prepare Input Data
#-------------------------------------------------
load("data/posdatasets.RData")
load("data/valence1.RData")
md_valence <- readRDS("valence/MD10k.rds")
shuffled_mddata <- readRDS("data/shuffledmd.rds")
md_subset <- shuffled_mddata[1:10000, ]

Posts <- c(imm_data$pos, md_subset$pos)
Subreddit <- c(rep(0, length(imm_data$pos)), rep(1, length(md_subset$pos)))
Valence <- c(imm_valence$texts__Valencepred, md_valence)

combined_dataset <- tibble(Posts, Subreddit, Valence)

#-------------------------------------------------
# 4. Topic Modeling
#-------------------------------------------------
DTM_LDA <- topicsDtm(
    data = combined_dataset$Posts,
    removalword = "removed",
    ngram_window = c(1, 3),
    stopwords = stop_list,
    removal_mode = "frequency",
    removal_rate_most = 2000,
    removal_rate_least = 50
)

# Inspect term frequency
DTM_EVAL_LDA <- topicsDtmEval(DTM_LDA)
DTM_EVAL_LDA$frequency_plot_30_most
DTM_EVAL_LDA$frequency_plot_30_least

# Train LDA
MODEL_LDA <- topicsModel(
    dtm = DTM_LDA,
    num_topics = 280,
    num_iterations = 1000
)

# Predict topic distribution per document
preds_LDA <- topicsPreds(
    model = MODEL_LDA,
    data = combined_dataset$Posts,
    burn_in = 200,
    num_iterations = 1000,
    sampling_interval = 25
)

#-------------------------------------------------
# 5. 2D Plot: Subreddit vs Valence
#-------------------------------------------------
test_LDA <- topicsTest(
    data = combined_dataset,
    model = MODEL_LDA,
    x_variable = "Subreddit",
    y_variable = "Valence",
    preds = preds_LDA,
    test_method = "linear_regression",
    p_adjust_method = "fdr"
)

plots_LDA <- topicsPlot(
    model = MODEL_LDA,
    test = test_LDA,
    p_alpha = 0.05,
    ngram_select = "prevalence",
    scatter_legend_n = c(20, 0, 3, 0, 10, 2, 5, 0, 40),
    color_scheme = c(
        "#08acd5", "#0f92b2",
        "#a4a3a4", "#887d85",
        "#f9a65d", "#ff7e0c",
        "#a6afcb", "#7288cf",
        "#a4a3a4", "#706a6e",
        "#d88d6d", "#d85218",
        "#a797e0", "#3d10e2",
        "#a4a3a4", "#464345",
        "#b37f7f", "#b21010"
    ),
    figure_format = "png",
    p_adjust_method = "fdr",
    save_dir = "plots/",
    seed = 37,
    allowed_word_overlap = 3,
    grid_legend_title_color = "white",
    grid_legend_y_axes_label = "Valence",
    grid_legend_x_axes_label = "Subreddit"
)

#-------------------------------------------------
# 6. 1D Plot: Valence Distribution
#-------------------------------------------------
test1_LDA <- topicsTest(
    data = combined_dataset,
    model = MODEL_LDA,
    x_variable = "Subreddit",
    preds = preds_LDA
)

plots1_LDA <- topicsPlot(
    model = MODEL_LDA,
    test = test1_LDA,
    scatter_legend_n = c(20, 5, 40),
    scatter_legend_dot_size = c(3, 8),
    scatter_legend_bg_dot_size = c(1, 3),
    color_scheme = c(
        "#a797e0", "#3d10e2",
        "#d0d0d0", "#a4a4a4",
        "#b37f7f", "#b21010"
    ),
    figure_format = "png",
    allowed_word_overlap = 2,
    save_dir = "plots/",
    ngram_select = "prevalence",
    p_adjust_method = "fdr",
    seed = 5
)

# Customize and save
p <- plots1_LDA$distribution +
    scale_x_continuous(limits = c(-0.5, 0.5)) +
    theme(
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_text(size = 12, color = "black", angle = 90),
        plot.margin = margin(1, 1, 1, 1, "cm")
    )

ggsave("plots/scatter.png", p, width = 10, height = 8.5)
