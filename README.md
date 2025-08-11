# Immersive vs Maladaptive Daydreaming Study

## Project Structure and File Descriptions

- **preprocessing.r**: Contains modular R functions for text cleaning and preprocessing using spaCy (via `spacyr`), including tokenization, lemmatization, and part-of-speech (POS) filtering. Use this script to prepare raw text data for further analysis.

- **topicPlots.r**: Implements topic modeling and visualization. Loads preprocessed data, applies topic modeling (LDA), evaluates and visualizes topic distributions, and saves plots and results. Includes custom stopword handling and advanced plotting options for topic prevalence and valence analysis.

- **imports.r**: Loads all required R packages and sets up the environment for the project, including memory options and initialization for text processing libraries. Source this file at the start of your R session to ensure all dependencies are loaded.

- **parallel_predictions.r**: Efficiently computes word embeddings and valence predictions in parallel batches using the `parallel` package. This script splits text data into batches, processes each batch in parallel, saves embeddings, and combines valence predictions for downstream analysis.

- **custom_stopwords.txt**: Custom stopword list (one word per line) used for topic modeling and text cleaning.

## Typical Workflow

1. **Set up the environment**: Source `imports.r` to load all required packages.
2. **Preprocess data**: Use functions from `preprocessing.r` to clean and prepare your text data.
3. **Generate embeddings and predictions**: Run `parallel_predictions.r` to batch and parallelize word embedding and valence prediction tasks.
4. **Topic modeling and visualization**: Run `topicPlots.r` to perform topic modeling, evaluate results, and generate plots.

## Requirements

- R (4.0 or higher recommended)
- R packages: `spacyr`, `stringr`, `quanteda`, `topics`, `stopwords`, `tibble`, `ggplot2`, `ggforce`, `crayon`, `text`, `reticulate`, `tidyverse`, `dplyr`, `parallel`, `purrr`, `future`

## Notes

- For large datasets, batching and parallelization (see `parallel_predictions.r`) are recommended for efficient processing.
- Update `custom_stopwords.txt` to tailor stopword removal for your analysis.

## License

MIT
