# load preprocessing.r functions
df <- data.frame(id = character(), sentence = character(), cleaned_sentence = character())
for (i in 1:5000) {
    print(paste("Processing row:", i))
    t <- parse_sentences((shuffled_mddata[i, ]))
    print(t)
    if (!is.null(t)) {
        df <- rbind(df, t)
    }
}

sentences_ID <- df
sentences_ID <- sentences_ID[sentences_ID$cleaned_sentence != "", ]

sentences_MD <- df
sentences_MD <- sentences_MD[sentences_MD$cleaned_sentence != "", ]
shuffled_sentences_MD <- sentences_MD[sample(nrow(sentences_MD)), ]
shuffled_sentences_MD <- head(shuffled_sentences_MD, n = 10000)

# Run parallel_predictions for shuffled_sentences_MD and sentences_ID

# Add sentence_valenceID to a new column in sentences_ID
sentence_valenceID <- readRDS("valence/SentencesID.rds")
sentences_ID$valence <- sentence_valenceID


sentence_valenceMD <- readRDS("valence/SentencesMD.rds")
shuffled_sentences_MD$valence <- sentence_valenceMD

saveRDS(sentences_ID, "data/sentences_dfID.rds")
saveRDS(shuffled_sentences_MD, "data/sentences_dfMD.rds")
