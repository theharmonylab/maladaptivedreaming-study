# Load required libraries
library(spacyr)
library(stringr)
library(quanteda)

#' Initialize spaCy Environment
#'
#' @param model_name Character string specifying the spaCy model to use
#' @return NULL
#' @examples
#' initialize_spacy()
initialize_spacy <- function(model_name = "en_core_web_sm") {
    tryCatch(
        {
            spacy_initialize(model = model_name)
        },
        error = function(e) {
            stop(paste("Failed to initialize spaCy:", e$message))
        }
    )
}

#' Clean Text Using spaCy
#'
#' @param text Character string to clean
#' @param min_word_length Minimum word length to keep (default: 5)
#' @return Character string of cleaned text
#' @examples
#' clean_text_spacy("This is a sample text with URLs http://example.com")
clean_text_spacy <- function(text, min_word_length = 5) {
    if (!is.character(text) || length(text) == 0) {
        stop("Input must be a non-empty character string")
    }

    # Parse and clean text with spaCy
    parsed_text <- spacy_tokenize(text,
        remove_punct = TRUE,
        remove_url = TRUE,
        remove_separators = TRUE,
        remove_numbers = TRUE,
        remove_symbols = TRUE,
        lemma = TRUE
    ) %>% as.tokens()

    # Filter tokens based on word length
    pattern <- paste0("^.{", min_word_length, ",}$")
    filtered_tokens <- tokens_select(parsed_text, pattern = pattern, valuetype = "regex")

    # Convert filtered tokens back to text
    cleaned_text <- paste(unlist(filtered_tokens), collapse = " ")
    return(cleaned_text)
}

#' Parse Text into Sentences
#'
#' @param row Dataframe row containing 'selftext' and 'id' columns
#' @param min_words Minimum number of words per sentence (default: 5)
#' @return Tibble with id, original sentences, and cleaned sentences
#' @examples
#' parse_sentences(data.frame(id = 1, selftext = "This is a sentence. Another one."))
parse_sentences <- function(row, min_words = 5) {
    if (!all(c("selftext", "id") %in% names(row))) {
        stop("Input row must contain 'selftext' and 'id' columns")
    }

    # Split text into sentences
    sentences <- as.list(strsplit(row$selftext, "[.]")[[1]])

    # Filter sentences by word count
    valid_sentences <- sentences[str_count(sentences, " ") > min_words]

    if (length(valid_sentences) == 0) {
        return(tibble::tibble())
    }

    # Clean sentences and create dataset
    cleaned_sentences <- unlist(lapply(valid_sentences, parse_pos_spacy))
    ids <- rep(row$id, length(valid_sentences))

    return(tibble::tibble(
        id = ids,
        sentence = valid_sentences,
        cleaned_sentence = cleaned_sentences
    ))
}

#' Parse Parts of Speech Using spaCy
#'
#' @param text Character string to parse
#' @param min_word_length Minimum word length to keep (default: 5)
#' @return Character string with selected POS tags cleaned
#' @examples
#' parse_pos_spacy("The quick brown fox jumps over the lazy dog")
parse_pos_spacy <- function(text, min_word_length = 5) {
    if (!is.character(text) || length(text) == 0) {
        stop("Input must be a non-empty character string")
    }

    # Parse text with spaCy
    entity_text <- spacy_parse(text,
        remove_punct = TRUE,
        remove_separators = TRUE,
        remove_url = TRUE,
        lemma = TRUE,
        dependency = TRUE,
        entity = TRUE,
        pos = TRUE,
        tag = FALSE
    ) %>%
        as.tokens(include_pos = "pos") %>%
        tokens_select(pattern = c("*/NOUN", "*/VERB", "*/ADJ"))

    # Filter by word length
    pattern <- paste0("^.{", min_word_length, ",}$")
    filtered_tokens <- tokens_select(entity_text, pattern = pattern, valuetype = "regex")

    # Clean POS tags and return text
    cleaned_text <- paste(unlist(filtered_tokens), collapse = " ") %>%
        str_replace_all("/NOUN|/VERB|/ADJ", "")

    return(cleaned_text)
}

#' Example Usage
if (FALSE) { # Set to TRUE to run examples
    # Sample text
    text_data <- "The cat (Felis catus), also referred to as the domestic cat or house cat, is a small domesticated carnivorous mammal. It is the only domesticated species of the family Felidae. Advances in archaeology and genetics have shown that the domestication of the cat occurred in the Near East around 7500 BC."

    # Initialize spaCy
    initialize_spacy()

    # Clean and parse text
    cleaned_text <- clean_text_spacy(text_data)
    pos_text <- parse_pos_spacy(text_data)

    # Display results
    print(cleaned_text)
    print(pos_text)

    # Clean up
    spacy_finalize()
}
