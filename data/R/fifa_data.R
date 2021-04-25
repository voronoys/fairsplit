# Packages
library(dplyr)
library(stringr)

fix_photos_link <- function(link) {
  # Inspired by https://github.com/Appsilon/shiny.semantic-hackathon-2020/blob/master/fifa19/utils.R
  id <- stringr::str_extract(pattern = "[0-9]{6}", string = link)
  first_3 <- stringr::str_sub(string = id, start = 1, end = 3)
  last_3 <- stringr::str_sub(string = id, start = 4, end = 6)
  fixed_link <- paste0("https://cdn.sofifa.com/players/", first_3, "/", last_3, "/20_120.png")
  fixed_link
}

# Data source: https://www.kaggle.com/stefanoleone992/fifa-20-complete-player-dataset?select=players_20.csv
fifa <- read.csv(file = "data/fifa20_original.txt", header = TRUE)
clubs <- c("FC Barcelona", "Juventus", "Paris Saint-Germain", "Real Madrid", "Manchester City", "Liverpool")

fifa <- fifa %>%
  dplyr::mutate(photo = fix_photos_link(player_url)) %>%
  dplyr::filter(club %in% clubs)

# Downloading images
# apply(
#   X = fifa[, c("photo", "sofifa_id")],
#   MARGIN = 1,
#   FUN = function(x) download.file(url = x[1], sprintf("www/fifa/%s.png", x[2]))
# )

lback_pos <- c("LB", "LWB")
rback_pos <- c("RB", "RWB")
back_pos <- "CB"
middle_pos <- c("CDM", "CM", "CAM", "RM", "LM", "RW", "LW")
attack_pos <- c("RF", "LF", "CF", "ST")

fifa <- fifa %>%
  dplyr::mutate(position = stringr::str_extract_all(string = player_positions, pattern = "([A-Z]{2,3})")) %>%
  tidyr::unnest(cols = "position") %>%
  dplyr::mutate(
    position = dplyr::case_when(
      position == "GK" ~ "goalkeeper",
      position %in% lback_pos ~ "left wing-back",
      position %in% rback_pos ~ "right wing-back",
      position %in% back_pos ~ "back",
      position %in% middle_pos ~ "midfielder",
      position %in% attack_pos ~ "striker"
    )
  ) %>%
  dplyr::filter(position != "goalkeeper") %>%
  dplyr::mutate(photo = sprintf("fifa/%s.png", sofifa_id)) %>%
  #dplyr::select(short_name, photo, position, age, height_cm, weight_kg, value_eur, wage_eur, pace:gk_positioning, attacking_crossing:goalkeeping_reflexes) %>%
  dplyr::select(short_name, photo, position, pace, shooting, passing, dribbling, defending, physic) %>%
  dplyr::rename(id = short_name)

fifa <- fifa %>%
  group_by(id, position) %>%
  slice(1) %>%
  ungroup %>%
  dplyr::mutate(ones = 1) %>%
  tidyr::pivot_wider(names_from = position, values_from = ones, values_fill = 0)

# Saving file
write.table(x = fifa, file = "data/fifa20.txt", sep = ";", row.names = FALSE)
