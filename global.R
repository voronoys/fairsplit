# Packages
library(dplyr)
library(stringr)
library(tidyr)
library(reactable)
library(shiny)
library(shiny.semantic)
library(shiny.router)

source("R/utils.R")
source("modules/module_split.R")

# Router
router <- make_router(
  route("splitting", ui_split(id = "t1")),
  route("stats", ui_split(id = "t2"))
)

# Data
data <- read.table(file = "data/attributes.csv", header = TRUE, sep = ";")

# Settings
n_ids <- nrow(data)
team_size <- 5
n_teams <- n_ids/team_size

# Algorithm
n_it <- 10000
buffer <- 100
dist_metric <- "euclidian"
