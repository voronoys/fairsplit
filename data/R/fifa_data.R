# Packages
library(dplyr)
library(stringr)

fix_photos_link <- function(link) {
  # Inspired by https://github.com/Appsilon/shiny.semantic-hackathon-2020/blob/master/fifa19/utils.R
  id <- str_extract(pattern = "[0-9]{6}", string = link)
  first_3 <- str_sub(string = id, start = 1, end = 3)
  last_3 <- str_sub(string = id, start = 4, end = 6)
  fixed_link <- paste0("https://cdn.sofifa.com/players/", first_3, "/", last_3, "/20_120.png")
  fixed_link
}

# Data source: https://www.kaggle.com/stefanoleone992/fifa-20-complete-player-dataset?select=players_20.csv
fifa <- read.csv(file = "data/fifa20_original.txt", header = TRUE)
clubs <- c("FC Barcelona", "Juventus", "Paris Saint-Germain", "Real Madrid", "Manchester City", "Liverpool")

fifa <- fifa %>%
  mutate(photo = fix_photos_link(player_url)) %>%
  filter(club %in% clubs)

# Downloading images
# apply(
#   X = fifa[, c("photo", "sofifa_id")],
#   MARGIN = 1,
#   FUN = function(x) download.file(url = x[1], sprintf("www/fifa/%s.png", x[2]))
# )

fifa <- fifa %>%
  mutate(photo = sprintf("fifa/%s.png", sofifa_id)) %>%
  select(short_name, photo, age, height_cm, weight_kg, value_eur, wage_eur, pace:gk_positioning, attacking_crossing:goalkeeping_reflexes) %>%
  rename(id = short_name)

# Saving file
write.table(x = fifa, file = "data/fifa20.txt", sep = ";", row.names = FALSE)
