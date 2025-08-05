T1 <- Sys.time()
word_embeddings <- textEmbed(data,
    model = "mixedbread-ai/mxbai-embed-large-v1",
    batch_size = 50
)
T2 <- Sys.time()


valence <- textPredict(
    model_info = "valence_facebook_mxbai23_eijsbroek2024",
    word_embeddings = word_embeddings$texts,
    save_dir = "valence/"
)

gender <- textPredict(
    model_info = "padmajabfrl/Gender-Classification",
    word_embeddings = word_embeddings$texts,
    save_dir = "results/"
)
