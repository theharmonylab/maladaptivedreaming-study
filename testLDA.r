# Test results using hold out dataset

md_postsTEST <- shuffled_mddata[10000:20000, ]
md_valenceTEST <- readRDS("valence/MD10to20k.rds")
md_valenceTEST <- md_valenceTEST[1:10001]

PostsTEST <- c(imm_data$pos, md_postsTEST$pos)
SubredditTEST <- c(rep(0, length(imm_data$pos)), rep(1, length(md_postsTEST$pos)))
ValenceTEST <- c(imm_valence$texts__Valencepred, md_valenceTEST)
combined_datasetTEST <- tibble(PostsTEST, SubredditTEST, ValenceTEST)

DTM_LDATEST <- topicsDtm(
    data = combined_datasetTEST$PostsTEST,
    removalword = "removed",
    ngram_window = c(1, 3),
    stopwords = stop_list,
    removal_mode = "frequency",
    removal_rate_most = 2000,
    removal_rate_least = 30
)
# Train LDA
MODEL_LDATEST <- topicsModel(
    dtm = DTM_LDATEST,
    num_topics = 280,
    num_iterations = 1000
)
topicsDtmEval(DTM_LDATEST)
preds_TEST <- topicsPreds(
    model = MODEL_LDA,
    data = combined_datasetTEST$PostsTEST,
    burn_in = 200,
    num_iterations = 1000,
    sampling_interval = 25
)

test_LDATEST <- topicsTest(
    data = combined_datasetTEST,
    model = MODEL_LDA,
    x_variable = "SubredditTEST",
    y_variable = "ValenceTEST",
    preds = preds_TEST,
    test_method = "linear_regression",
    p_adjust_method = "fdr"
)


plots_LDATEST <- topicsPlot(
    model = MODEL_LDA,
    test = test_LDATEST,
    p_alpha = 0.05,
    color_scheme = c(
        "lightgray", "#56B4E9",
        "lightgray", "darkgray",
        "lightgray", "#e4b831",
        "lightgray", "#2B93CE",
        "lightgray", "darkgray",
        "lightgray", "#DE7F00",
        "lightgray", "#0072B2",
        "lightgray", "darkgray",
        "lightgray", "#D55E00"
    ),
    figure_format = "svg",
    p_adjust_method = "fdr",
    save_dir = "plots/test/",
    seed = 5,
    allowed_word_overlap = 3,
    scatter_legend_circles = TRUE,
    grid_legend_title_color = "white",
    grid_legend_y_axes_label = "ValenceTEST",
    grid_legend_x_axes_label = "SubredditTEST"
)
