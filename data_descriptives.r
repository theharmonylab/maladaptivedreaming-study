imm_desc <- textDescriptives(imm_data$pos)

set.seed(123) # for reproducibility
n_samples <- 5
sample_size <- 3935 # same size as ID
results_list <- vector("list", n_samples)

for (i in 1:n_samples) {
    sample_indices <- sample(nrow(shuffled_mddata), sample_size)
    sample_posts <- shuffled_mddata$pos[sample_indices]
    results_list[[i]] <- textDescriptives(sample_posts)
    print(paste("Sample", i, "completed"))
}

for (i in 1:n_samples) {
    print(paste("Summary for sample", i))
    print(results_list[[i]])
}

results_df <- do.call(rbind, lapply(results_list, as.data.frame))
write.csv(results_df, "results/textDescriptives.csv", row.names = FALSE)
