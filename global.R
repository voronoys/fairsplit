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
library(shinyWidgets)
library(shinymaterial)

color_box <- "#c3c2c8"
text_color <- "#fff"

roma_palette <- c(
  '#E01F54', '#001852', '#f5e8c8', '#b8d2c7',
  '#c6b38e', '#a4d8c2', '#f3d999', '#d3758f',
  '#dcc392', '#2e4783', '#82b6e9', '#ff6347',
  '#a092f1', '#0a915d', '#eaf889', '#6699FF',
  '#ff6666', '#3cb371', '#d5b158', '#38b6b6'
)

source("R/utils.R")
source("tabs/ui_home.R")
source("tabs/ui_examples.R")
source("tabs/ui_about.R")