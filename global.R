# Packages
library(dplyr)
library(stringr)
library(tidyr)
library(rhandsontable)
library(reactable)
library(shiny)
library(shinyjs)
library(shinycssloaders)
library(shiny.semantic)
library(shiny.router)

color_box <- "#313131"

source("R/utils.R")
source("tabs/ui_home.R")
source("tabs/ui_split.R")

# Router
router <- make_router(
  route("home", ui_home),
  route("teams", ui_split)
)
