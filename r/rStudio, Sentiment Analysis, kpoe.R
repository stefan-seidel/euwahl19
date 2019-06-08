# Set the working directory
setwd("/Users/stefan/R/Projekte/EUWAHL-R/BA2R-P1")

library(stringr)    # Textmanipulation
library(tidytext)   # Textmining
library(pdftools)
library(knitr)      # HTML tables
library(htmlTable)  # HTML tables
library(lsa)        # stopwords
library(SnowballC)  # Textmanipulation (truncate)
library(wordcloud)
library(gridExtra)  # Plots
library(dplyr)      
library(ggplot2)    # Visualization
library(tidyverse)

party_raw <- readLines('data/euwahl19-parteiprogramme/txt/clean_text-kpoe.body.txt')
party_raw_length <- length(party_raw)
party_raw_length

# Convert into tidy text dataframe
party_df <- data_frame(Zeile = 1:party_raw_length, 
                       party_raw = party_raw)

# Convert into "one-token-per-row" format (tidytext)
party_df %>% 
  unnest_tokens(token, party_raw) %>% 
  filter(str_detect(token, "[a-z]")) -> party_df

stupid_word_count <- dplyr::count(party_df) 


# SENTIMENT ANALYSIS

# Read negative wordlist
neg_df <- suppressWarnings(read_tsv("data/SentiWS_v1.8c/SentiWS_v1.8c_Negative.txt", col_names = FALSE))
suppressWarnings(names(neg_df) <- c("Wort_POS", "Wert", "Inflektionen"))

neg_df %>% 
  mutate(Wort = str_sub(Wort_POS, 1, regexpr("\\|", .$Wort_POS)-1),
         POS = str_sub(Wort_POS, start = regexpr("\\|", .$Wort_POS)+1)) -> neg_df

# Read positive wordlist
pos_df <- suppressWarnings(read_tsv("data/SentiWS_v1.8c/SentiWS_v1.8c_Positive.txt", col_names = FALSE))
names(pos_df) <- c("Wort_POS", "Wert", "Inflektionen")

pos_df %>% 
  mutate(Wort = str_sub(Wort_POS, 1, regexpr("\\|", .$Wort_POS)-1),
         POS = str_sub(Wort_POS, start = regexpr("\\|", .$Wort_POS)+1)) -> pos_df

bind_rows("neg" = neg_df, "pos" = pos_df, .id = "neg_pos") -> sentiment_df
sentiment_df %>% select(neg_pos, Wort, Wert, Inflektionen, -Wort_POS) -> sentiment_df

# htmlTable(head(sentiment_df))

# Unweighted sentiment 

sentiment_neg <- match(party_df$token, filter(sentiment_df, neg_pos == "neg")$Wort)
neg_score <- sum(!is.na(sentiment_neg))

sentiment_pos <- match(party_df$token, filter(sentiment_df, neg_pos == "pos")$Wort)
pos_score <- sum(!is.na(sentiment_pos))

round(pos_score/neg_score, 1)


# Pos/Neg words in use

party_df %>% 
  mutate(sentiment_neg = sentiment_neg,
         sentiment_pos = sentiment_pos) -> party_df

party_df %>% 
  filter(!is.na(sentiment_neg)) %>% 
  dplyr::select(token) -> negative_sentiments

head(negative_sentiments$token,50)

party_df %>% 
  filter(!is.na(sentiment_pos)) %>% 
  select(token) -> positive_sentiments

head(positive_sentiments$token, 50)


# Pos/Neg word count
party_df %>% 
  filter(!is.na(sentiment_neg)) %>% 
  summarise(n_distinct_neg = n_distinct(token))

party_df %>% 
  filter(!is.na(sentiment_pos)) %>% 
  summarise(n_distinct_pos = n_distinct(token))


# Weighted sentiment 

sentiment_df %>% 
  rename(token = Wort) -> sentiment_df

party_df %>% 
  left_join(sentiment_df, by = "token") -> party_df 

party_df %>% 
  filter(!is.na(Wert)) %>% 
  summarise(Sentimentwert = sum(Wert, na.rm = TRUE)) -> party_sentiment_summe

party_sentiment_summe$Sentimentwert

party_df %>% 
  group_by(neg_pos) %>% 
  filter(!is.na(Wert)) %>% 
  summarise(Sentimentwert = sum(Wert)) %>% 
  htmlTable()


# Tokens with most pos/neg sentiment

party_df %>% 
  filter(neg_pos == "pos") %>% 
  distinct(token, .keep_all = TRUE) %>% 
  arrange(-Wert) %>% 
  filter(row_number() < 11) %>% 
  dplyr::select(token, Wert) %>% 
  htmlTable()

party_df %>% 
  filter(neg_pos == "neg") %>% 
  distinct(token, .keep_all = TRUE) %>% 
  arrange(Wert) %>% 
  filter(row_number() < 11) %>% 
  dplyr::select(token, Wert) %>% 
  htmlTable()


# Relative sentiment

sentiment_df %>% 
  filter(!is.na(Wert)) %>% 
  ggplot() +
  aes(x = Wert) +
  geom_histogram()

sentiment_df %>% 
  filter(!is.na(Wert)) %>% 
  dplyr::count(neg_pos)

sentiment_df %>% 
  filter(!is.na(Wert)) %>% 
  summarise(sentiment_summe = sum(Wert)) -> sentiment_lexikon_sum

sentiment_lexikon_sum$sentiment_summe

sentiment_lexikon_sum$sentiment_summe / party_sentiment_summe$Sentimentwert

