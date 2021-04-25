# Packages
library(dplyr)
library(stringr)
library(tidyr)
library(rhandsontable)
library(reactable)
library(plotly)
library(shiny)
library(shinyjs)
library(shinycssloaders)
library(shiny.semantic) # remotes::install_github("Appsilon/shiny.semantic@develop")
library(shiny.router)
library(shinyWidgets)

color_box <- "#313131"

source("R/utils.R")
source("tabs/ui_home.R")
source("tabs/ui_split.R")

# Router
router <- shiny.router::make_router(
  shiny.router::route("home", ui_home),
  shiny.router::route("teams", ui_split)
)
