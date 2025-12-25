id_topic_names <- names(plots1_LDA1$square1)
md_topic_names <- names(plots1_LDA1$square3)
topic_numbers <- as.integer(sub("t_", "", id_topic_names))
topic_df <- do.call(rbind, lapply(topic_numbers, function(i) {
    data.frame(
        topic = i,
        top_terms = paste(test1_LDA$test$top_terms[[i]], collapse = ", "),
        beta = test1_LDA$test$x.Subreddit.estimate_beta[i],
        prevalence = test1_LDA$test$prevalence[i],
        coherence = test1_LDA$test$coherence[i],
        stringsAsFactors = FALSE
    )
}))
4
# -------------------------------------------------------
# Hierarchical Clustering of Topics
# -------------------------------------------------------
# Extract topic-term matrix (beta matrix)
if (!requireNamespace("stats", quietly = TRUE)) stop("Package 'stats' needed for clustering.")

# Only select topic numbers in topic_numbers
topic_term_matrix <- MODEL_LDA$phi
id_matrix <- topic_term_matrix[topic_numbers, ]
# Compute distance between topics (rows)
topic_dist <- dist(id_matrix, method = "maximum")
# Perform hierarchical clustering
topic_hclust <- hclust(topic_dist)
hclust_labels <- lapply(test1_LDA$test$top_terms[topic_numbers], substr, start = 1, stop = 18)
# Plot dendrogram
png("plots/onedim/topic_hclust_dendrogram.png", width = 1000, height = 600)
plot(topic_hclust, labels = hclust_labels, main = "Hierarchical Clustering of Topics", xlab = "Topics", sub = "", cex = 0.7)
dev.off()
clean_data <- na.omit(id_matrix)
kmeans_clust <- kmeans(x = clean_data, 30, iter.max = 1000, nstart = 5)
df <- data.frame(cluster = kmeans_clust$cluster, num = topic_numbers, name = test1_LDA$test$top_terms[topic_numbers])
grouped_data <- df %>%
    group_by(cluster) %>%
    summarise(
        topic_count = n()
    )

grouped_data
clustered_topics <- df %>%
    group_by(cluster) %>%
    summarise(
        topic_count = n(),
        topic_names = paste(substr(name, 1, 20), collapse = " | ")
    )
clustered_topics$topic_names


library(text2vec)

topic_nums <- topic_numbers[topic_numbers != 267]
topic_nums <- topic_nums[topic_nums != 217]
topic_nums <- topic_nums[topic_nums != 102]
beta_matrix <- topic_term_matrix[topic_nums, ]


# 2. Calculate cosine similarity between topics
topic_similarity <- sim2(beta_matrix, method = "cosine", norm = "l2")

# 3. Convert to distance and cluster
distance_matrix <- as.dist(1 - topic_similarity)
hc <- hclust(distance_matrix, method = "average")

k_clusters <- 12 # Choose based on your needs
topic_groups <- cutree(hc, k = k_clusters)

# 5. Create a summary table
topic_summary <- data.frame(
    topic = seq_along(topic_groups),
    group = topic_groups,
    t_num = topic_nums,
    name = test1_LDA$test$top_terms[topic_nums]
)

summ <- topic_summary %>%
    group_by(group) %>%
    summarise(
        topic_count = n(),
        topic_names = paste(substr(name, 1, 20), collapse = " | ")
    )

write.csv(summ, "cluster3.csv")
