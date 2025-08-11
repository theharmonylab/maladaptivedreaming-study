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
#-----------------Create input data-----------------

Posts <- c(dataset1$pos, dataset2$pos)
GroupLabel <- c(
    as.numeric(rep(0, length(dataset1$pos))),
    as.numeric(rep(1, length(dataset2$pos)))
)
Valence <- c(dataset1$valence, dataset2$valence)

input_data <- tibble(Posts = Posts, GroupLabel = GroupLabel, Valence = Valence)

#-------------------------------------------------
#-----------------Topics modeling-----------------
DTM_LDA <- topicsDtm(
    data = input_data$Posts,
    removalword = "removed",
    ngram_window = c(1, 3),
    stopwords = stop_list,
    removal_mode = "frequency", removal_rate_most = 2000, removal_rate_least = 50
)

DTM_EVAL_LDA <- topicsDtmEval(DTM_LDA)
DTM_EVAL_LDA$frequency_plot_30_most
DTM_EVAL_LDA$frequency_plot_30_least

MODEL_LDA <- topicsModel(
    dtm = DTM_LDA,
    num_topics = 280,
    num_iterations = 1000
)
write.csv(MODEL_LDA$summary$top_terms, "results/topicTerms.csv")

preds_LDA <- topicsPreds(
    model = MODEL_LDA,
    data = input_data$Posts,
    burn_in = 200,
    num_iterations = 1000,
    sampling_interval = 25
)

#-------------------------------------------------
#----------------- 1D Plot-----------------

test1_LDA <- topicsTest(
    data = input_data,
    model = MODEL_LDA,
    x_variable = "GroupLabel",
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
    allowed_word_overlap = 3,
    save_dir = "plots/",
    ngram_select = "prevalence",
    p_adjust_method = "fdr",
    seed = 5
)

p <- plots1_LDA$distribution + scale_x_continuous(limits = c(-0.5, 0.5))
p <- p + theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    axis.text.x = element_text(size = 12, color = "black", angle = 90),
    plot.margin = margin(1, 1, 1, 1, "cm")
)
ggsave("plots/seed_5/one_dimensional_plot.png", p, width = 10, height = 8.5)
