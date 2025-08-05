# unstructured-dataset-comparison

## Project Structure and File Descriptions

- **preprocessing.r**: Contains modular R functions for text cleaning and preprocessing using spaCy (via `spacyr`), including tokenization, lemmatization, and part-of-speech (POS) filtering. Use this script to prepare raw text data for further analysis.

- **topicPlots.r**: Implements topic modeling and visualization. Loads preprocessed data, applies topic modeling (LDA), evaluates and visualizes topic distributions, and saves plots and results. Includes custom stopword handling and advanced plotting options for topic prevalence and valence analysis.

- **imports.r**: Loads all required R packages and sets up the environment for the project, including memory options and initialization for text processing libraries. Source this file at the start of your R session to ensure all dependencies are loaded.

## Typical Workflow

## Requirements

- R (4.0 or higher recommended)
- R packages: `spacyr`, `stringr`, `quanteda`, `topics`, `stopwords`, `tibble`, `ggplot2`, `ggforce`, `crayon`, `text`, `reticulate`, `tidyverse`, `dplyr`
- Python with spaCy and the `en_core_web_sm` model (for `spacyr` backend)
