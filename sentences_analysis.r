sent_ID <- readRDS("data/sentences_dfID.rds")
sent_MD <- readRDS("data/sentences_dfMD.rds")

clean_sent <- c(
    sent_ID$cleaned_sentence,
    sent_MD$cleaned_sentence
)

sentences <- c(
    sent_ID$sentence,
    sent_MD$sentence
)

origin <- c(
    as.numeric(rep(0, length(sent_ID$sentence))),
    as.numeric(rep(1, length(sent_MD$sentence)))
)

valence <- c(sent_ID$valence, sent_MD$valence)
sent_dataset <- tibble(clean_sent, sentences, origin, valence)

sent_preds_LDA <- topicsPreds(
    model = MODEL_LDA,
    data = clean_sent,
    burn_in = 100,
    num_iterations = 1000,
    sampling_interval = 25
)

saveRDS(sent_preds_LDA, "results/sentences_preds_LDA.rds")


#---------------------------------------------------
get_examples <- function(search_terms) {
    found <- grep(search_terms, topTerms$top_terms)
    if (length(found) == 0) {
        cat(red("No sentences found for this topic \n"))
        return()
    } else {
        cat(blue("Selecting first match", found[1]), "\n")
    }
    name <- paste("t_", found[1], sep = "")
    topic_index <- sort(preds[[name]], decreasing = TRUE, index.return = TRUE)
    ix <- topic_index$ix[1:30]
    imm_indexes <- ix[origin[ix] == 0]
    print_sentences(imm_indexes, "Immersive")
    md_indexes <- ix[origin[ix] == 1]
    print_sentences(md_indexes, "Maladaptive")
    cat(yellow("Immersive = ", length(imm_indexes), "\n"))
    cat(yellow("Maladaptive = ", length(md_indexes), "\n"))
}


get_index <- function(search_terms) {
    found <- grep(search_terms, topTerms$top_terms)
    if (length(found) == 0) {
        cat(red("No sentences found for this topic \n"))
        return()
    } else {
        cat(blue("Selecting first match", found[1]), "\n")
    }
    name <- paste("t_", found[1], sep = "")
    topic_index <- sort(preds[[name]], decreasing = TRUE, index.return = TRUE)
    ix <- topic_index$ix[1:1000]
    return(ix)
}

print_sentences <- function(indexes, name) {
    if (length(indexes) == 0) {
        cat(red("No ", name, " sentences found for this topic \n"))
    } else {
        print(indexes)
        examples <- lapply(indexes, function(i) {
            sentence <- sentences[i]
            # sentence <- anonymize(sentence)
            return(sentence)
        })
        cat(blue(name, " sentences: "), "\n")
        print(unlist(examples))
    }
}

anonymize <- function(t) {
    # Define a regex pattern to match all names
    t <- unlist(t)
    t <- str_replace_all(t, "\n", "")
    t_parsed <- spacy_parse(t, dependency = TRUE, lemma = FALSE, pos = FALSE)
    entities <- entity_extract(t_parsed, type = "named")
    entities <- entities[entities$entity_type == "PERSON", ]$entity
    persons <- unique(entities)
    t_new <- t
    for (i in persons) {
        t_new <- str_replace_all(t_new, i, "PERSON")
    }
    return(str_trim(t_new))
}
#--------------------------------------
# Extract sentence examples for result tables
preds <- readRDS("results/sentences_preds_LDA.rds")
topTerms <- read.csv("results/topic_terms.csv")

search <- "car, driving"
get_examples(search)

indexes <- get_index(search)

# Create a new dataframe from sent_dataset using the selected indexes
selected_sent_df <- sent_dataset[indexes, ]
saveRDS(selected_sent_df, "data/topic_data/car_df.rds")
