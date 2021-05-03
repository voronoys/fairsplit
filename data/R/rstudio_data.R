# Packages
library(rvest)

set.seed(4815162342)

# Reading names and image locations
url <- "https://www.rstudio.com/about/"

team <- xml2::read_html(url) %>%
  rvest::html_nodes(css = "body > div > div > div > div > div > div > div")

names <- team %>%
  rvest::html_nodes(css = "h3") %>%
  rvest::html_text()

imgs <- team %>%
  rvest::html_nodes(css = "div") %>%
  rvest::html_attr("style") %>%
  stringr::str_extract(pattern = "/about.+\\.(jpg|jpeg|png)") %>%
  paste0("https://www.rstudio.com", .)

# Creating a fake dataset
rstudio <- data.frame(id = names, photo = imgs)

attrs <- c("dplyr", "ggplot2", "tidyr", "stringr", "purrr", "shiny", "rmarkdown", "sparklyr", "reticulate")
rstudio[attrs] <- matrix(rbinom(n = nrow(rstudio)*length(attrs), size = 10, prob = 0.8), ncol = length(attrs))

# Saving file
write.table(x = rstudio, file = "data/rstudio.txt", sep = ";", row.names = FALSE)
