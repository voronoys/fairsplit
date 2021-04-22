# Packages
library(dplyr)
library(stringr)

# Source: "https://github.com/jbkunst/highcharter/blob/master/data/pokemon.rda"
url_images <- "https://raw.githubusercontent.com/phalt/pokeapi/master/data/Pokemon_XY_Sprites/" 

load("data/pokemon.rda")

pokemon <- pokemon %>%
  mutate(photo = paste0(url_images, url_image)) %>%
  select(pokemon, photo, height, weight, base_experience, attack, defense, hp, special_attack, special_defense, speed) %>%
  rename(id = pokemon)

# Saving file
write.table(x = pokemon, file = "data/pokemon.txt", sep = ";", row.names = FALSE)
