# DS-636 FINAL PROJECT - Web Scraping using R: Extracting and Analyzing Journal Article DATA
# PROJECT DOMAIN - MOLECULAR BRAIN

# TASK - 1) SETTING UP THE R ENVIRONMENT

install.packages(c("rvest", "httr", "xml2", "dplyr", "stringr", "ggplot2", "tidyverse"))
#load them
library(rvest)
library(httr)
library(xml2)
library(dplyr)
library(stringr)
library(ggplot2)
library(tidyverse)


# TASK - 2) SCRAPING ARTICLE DATA

# Function to get article links for a given year
get_article_links <- function(year,max_pages) {
  base_url <- "https://molecularbrain.biomedcentral.com/articles"
  links <- c()
  for (page in 1:max_pages) {
    url <- paste0(base_url, "?searchType=journalSearch&sort=PubDate&page=", page, "&query=&year=", year)
    cat("Accessing page:", page, "\n")
    
    page_html <- tryCatch(read_html(url), error = function(e) return(NULL))
    if (is.null(page_html)) return(data.frame())
    
    article_links <- page_html %>% 
      html_nodes(".c-listing__title a") %>% 
      html_attr("href") %>%
      paste0("https://molecularbrain.biomedcentral.com", .)
    
    if (length(article_links) == 0) break
    links <- c(links, article_links)
  }
  
  return(unique(links))
}

# Function to scrape each article by link
scrape_article <- function(link) {
  cat("Scraping article:", link, "\n")
  page <- tryCatch(read_html(link), error = function(e) NULL)
  if (is.null(page)) return(NULL)
  
  title <- page %>% html_node("h1") %>% html_text(trim = TRUE)
  
  authors <- page %>%
    html_nodes(".c-article-author-list__item") %>%
    html_text(trim = TRUE) %>%
    paste(collapse = ", ")
  
  correspondence_author <- page %>%
    html_nodes("p#corresponding-author-list a") %>%
    html_text(trim = TRUE) %>%
    paste(collapse = ", ")
  
  correspondence_email <- page %>%
    html_nodes("p#corresponding-author-list a") %>%
    html_attr("href") %>%
    str_extract("(?<=mailto:).*") %>%
    paste(collapse = ", ")
  
  publish_date <- page %>%
    html_node("time") %>%
    html_text(trim = TRUE)
  
  abstract <- page %>%
    html_node(".c-article-section__content") %>%
    html_text(trim = TRUE)
  
  keywords <- page %>%
    html_nodes(".c-article-subject-list__subject") %>%
    html_text(trim = TRUE) %>%
    paste(collapse = ", ")
  
  return(data.frame(
    Title = title,
    Authors = authors,
    Correspondence_Author = correspondence_author,
    Correspondence_Email = correspondence_email,
    Publish_Date = publish_date,
    Abstract = abstract,
    Keywords = keywords,
    URL = link,
    stringsAsFactors = FALSE
  ))
}


#Function to scrape all articles for a given year
scrape_year <- function(year, max_pages) {
  article_links <- get_article_links(year, max_pages)
  article_data <- lapply(article_links, scrape_article)
  result_df <- do.call(rbind, article_data)
  return(result_df)
}

#Extract all articles from 2008 to 2025 into a list and label each element by year
article_list <- lapply(2025:2008, function(year) {
  cat("Processing year:", year, "\n")
  result <- scrape_year(year,5)
  if (is.null(result) || nrow(result) == 0) return(NULL)
  result
})


# TASK - 3) DATA CLEANING AND PREPROCESSING

sum(is.na(article_list))
# Remove NULL entries in case of failed scraping attempts
article_list <- Filter(Negate(is.null), article_list)
names(article_list) <- as.character(2025:2008)

# Combine all articles into a single dataframe and add a Publish_Year column
article_final <- bind_rows(article_list, .id = "Year") %>%
  mutate(
    Publish_Date = lubridate::dmy(Publish_Date),
    Publish_Year = as.integer(Year)
  ) %>%
  select(-Year) %>%
  filter(complete.cases(.))

View(article_final)

# Export cleaned data 
write_csv(article_final, "Molecular_Brain.csv")



# TASK - 4 - DATA ANALYTICS AND VISUALIZATION

# a. Get the most frequent keywords for the plot
# Split keywords into separate rows
keywords_long <- article_final %>%
  filter(!is.na(Keywords) & Keywords != "") %>%
  separate_rows(Keywords, sep = ",\\s*")

#Count Keyword frequency
keyword_counts <- keywords_long %>%
  filter(Publish_Year == 2025) %>%
  group_by(Keywords) %>%
  summarise(Frequency = n()) %>%
  arrange(desc(Frequency))

#Define number of top keywords to display
top_n <- 10
top_keywords <- keyword_counts %>% slice_max(Frequency, n = top_n, with_ties = FALSE)
top_keywords

# bar chart for top -10 frequent keywords in all the articles
ggplot(top_keywords, aes(x = reorder(Keywords, Frequency), y = Frequency)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(title = paste("Top", top_n, "Keywords in Molecular Brain Articles(2025)"),
       x = "Keyword",
       y = "Frequency") +
  theme_minimal()


#b. No.of Papers published by year
papers_by_year <- article_final %>%
  group_by(Publish_Year) %>%
  summarise(Count = n()) %>%
  arrange(Publish_Year)


# Bar chart for total number of articles published in each year
ggplot(papers_by_year, aes(x = as.factor(Publish_Year), y = Count)) +
  geom_bar(stat = "identity",fill="steelblue") +
  geom_text(aes(label = Count), vjust = -0.5, size = 3) + 
  labs(title = "Number of Articles Published per Year",
       x = "Year",
       y = "Number of Articles") +
  theme_minimal()




# c. Extracting the count of the number of articles by each Corresponding Author
top_authors <- article_final %>%
  filter(Correspondence_Author != "") %>%       
  count(Correspondence_Author, sort = TRUE) %>%      
  slice_max(n, n = 10)                              

# Horizontal bar chart to visualize top 10 corresponding authors
ggplot(top_authors, aes(x = reorder(Correspondence_Author, n), y = n)) +
  geom_col(fill = "lightgreen") +                    
  coord_flip() +                                
  labs(title = "Top 10 Corresponding Authors (by Article Count)", 
       x = "Author",                                  
       y = "Number of Articles") +                  
  theme_minimal()                                     



