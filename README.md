# Web Scraping using R: Extracting and Analyzing Journal Article Data

This **Molecular Brain Journal Web Scraper** course project of DS-636 is an R-based project designed to extract, clean, and analyze article data from the *Molecular Brain* journals.  
It enables users to retrieve research metadata such as titles, authors, abstracts, and keywords for articles published in a given year, and visualize key insights such as keyword frequency.

## Features

- Scrape articles from the *Molecular Brain* journals based on a user-specified year.
- Extract essential metadata: Title, Authors, Corresponding Author & Email, Publish Date, Abstract, and Keywords.
- Clean and preprocess the data for consistency and readability.
- Visualize the most frequently used keywords in a bar chart using `ggplot2`.
- Export cleaned data and charts for reporting and presentation.

## Technologies Used

- **Language**: R
- **Web Scraping**: rvest, httr, xml2
- **Data Cleaning & Manipulation**: dplyr, stringr, tidyverse, lubridate
- **Visualization**: ggplot2
- **Data Export**: readr (write_csv)

## Prerequisites

Before running the project, ensure you have the following installed:

- **R**: [Download R](https://cran.r-project.org/)
- **RStudio** (recommended IDE): [Download RStudio](https://www.rstudio.com/products/rstudio/download/)
- **R Packages**:  
  Install these packages from your R console:

```r
install.packages(c("rvest", "httr", "xml2", "dplyr", "stringr", "ggplot2", "tidyverse", "lubridate"))
```

## Screenshots

### 📊 Top 10 keywords of 2025

This chart shows the top keywords extracted from the articles in the selected year.

<img src="/images/Rplot02.png" height="350"></img>

### 📊 Total Number of Journals published

This chart shows the total number of journals published across the years 2008-2025.

<img src="/images/numberofarticles.png" height="350"></img>

### 📊 Top 10 Corresponding authors

This chart shows the top 10 corresponding authors by article count 

<img src="/images/Rplot02.png" height="350"></img>


## Setup and Installation

### 1. Clone the Repository

Clone this repository to your local machine using the following command:

```bash
git clone https://github.com/your-username/web_scraping_project_r.git
cd molecular-brain-web-scraper
```

### 2. Open in RStudio

Launch RStudio and open the project folder. Then run the scripts.




