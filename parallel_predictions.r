library(parallel)

# Function to split vector into batches
batch_vector <- function(vec, batch_size) {
    split(vec, ceiling(seq_along(vec) / batch_size))
}

embedding_batches <- batch_vector(dataset$pos[10000:15000], batch_size = 1000)
embedding_files <- sprintf("data/embeddings_MD_batch_%d.rds", seq_along(embedding_batches))

# Detect cores and create a cluster
num_cores <- detectCores() - 1
cl <- makeCluster(num_cores)

T1 <- Sys.time()

# Export needed objects and load packages on each worker
clusterExport(cl, c("embedding_batches", "embedding_files"))
clusterEvalQ(cl, library(text))

# Parallel processing
parLapply(cl, seq_along(embedding_batches), function(i) {
    emb <- textEmbed(
        embedding_batches[[i]],
        model = "mixedbread-ai/mxbai-embed-large-v1",
        batch_size = 50,
        tokenizer_parallelism = TRUE
    )
    saveRDS(emb, embedding_files[i])
    NULL
})

stopCluster(cl)

T2 <- Sys.time()
print(T2 - T1)

word_embeddings_loaded <- lapply(embedding_files, readRDS)
valence_results <- vector("list", length(word_embeddings_loaded))
for (i in seq_along(word_embeddings_loaded)) {
    valence_results[[i]] <- textPredict(
        model_info = "valence_facebook_mxbai23_eijsbroek2024",
        word_embeddings = word_embeddings_loaded[[i]]$texts,
        save_dir = "valence/"
    )
}

save.image(file = "data/embeddings.RData")

# Combine valence predictions
md_valence <- unlist(lapply(valence_results, function(x) x$texts__Valencepred))
saveRDS(md_valence, "valence/MD10-15k.rds")
