# Packages
library(rvest)

# Reading names and image locations
url <- "https://www.rstudio.com/about/"

team <- read_html(url) %>%
  html_nodes(css = "body > div > div > div > div > div > div > div")

names <- team %>%
  html_nodes(css = "h3") %>%
  html_text()

imgs <- team %>%
  html_nodes(css = "div") %>%
  html_attr("style") %>%
  str_extract(pattern = "/about.+\\.(jpg|jpeg|png)") %>%
  paste0("https://www.rstudio.com", .)

# Creating a fake dataset
rstudio <- data.frame(id = names, photo = imgs)

attrs <- c("dplyr", "ggplot2", "tidyr", "stringr", "purrr", "shiny", "rmarkdown", "sparklyr", "reticulate")
rstudio[attrs] <- matrix(rbinom(n = nrow(rstudio)*length(attrs), size = 10, prob = 0.8), ncol = length(attrs))

# Saving file
write.table(x = rstudio, file = "data/rstudio.txt", sep = ";", row.names = FALSE)
