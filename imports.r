options(java.parameters = "-Xmx8000m")
library(topics)
library(stopwords)
library(tibble)
library(ggplot2)
library(ggforce)
library(crayon)
library(text)
library(reticulate)
library(tidyverse)
library(stringr)
library(dplyr)
text::textrpp_initialize(
    virtualenv = "textrpp_virtualenv",
    condaenv = NULL,
    save_profile = TRUE
)
