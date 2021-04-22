open_data <- eventReactive(c(input$real_example, input$rstudio_example, input$fifa_example, input$ca_example, input$pokemon_example), {
  # Who fired the reactive?
  changed <- req(input$changed)
  
  # Open data
  if(changed == "real_example") {
    data <- read.table(file = "data/nossa_pelada.txt", header = TRUE, sep = ";", check.names = FALSE)
    title <- "Real game at Brazil"
    
    n_teams <- 3L
    team_size <- 5L
  }
  if(changed == "rstudio_example") {
    data <- read.table(file = "data/rstudio.txt", header = TRUE, sep = ";", check.names = FALSE)
    title <- "RStudio R skils"
    
    n_teams <- 10L
    team_size <- 10L
  }
  if(changed == "fifa_example") {
    data <- read.table(file = "data/fifa20.txt", header = TRUE, sep = ";", check.names = FALSE)
    data <- data[, colSums(is.na(data)) == 0]
    
    title <- "FIFA 2020"
    n_teams <- 10L
    team_size <- 10L
  }
  if(changed == "pokemon_example") {
    data <- read.table(file = "data/pokemon.txt", header = TRUE, sep = ";", check.names = FALSE)
    data <- data[, colSums(is.na(data)) == 0]
    
    title <- "Pokémon"
    n_teams <- 10L
    team_size <- 10L
  }
  if(changed == "ca_example") {
    data <- read.table(file = "data/company.txt", header = TRUE, sep = ";", check.names = FALSE)
    title <- "Company skils"
    n_teams <- 3L
    team_size <- 5L
  }
  
  return(list(data = data, title = title, n_teams = n_teams, team_size = team_size))
})

observe({
  data_params <- open_data()
  data <- data_params$data
    
  # Guessing the data sacle
  max_scale <- apply(X = data[, -c(1, 2)], MARGIN = 2, FUN = function(x) next_beauty_number(max(x)))
  min_scale <- max_scale*0
  
  vars <- names(data[, -c(1, 2)])
  
  # Modal title  
  output$title <- renderText(sprintf("<h1 style='color=#C0C0C0 !important'>%s</h1>", data_params$title))
  
  # Attributes table
  output$df_attr <- renderRHandsontable({
    tab <- rhandsontable(
      data = data.frame(Variable = vars, Description = str_to_title(vars), Weight = 1, Maximum = max_scale, row.names = NULL, stringsAsFactors = FALSE),
      rowHeaders = FALSE,
      stretchH = "all"
    ) %>% 
      hot_col(col = c("Variable", "Maximum"), readOnly = TRUE) %>%
      hot_validate_numeric(cols = "Weight", min = 0, max = 10000, allowInvalid = FALSE)
  })
  
  # Parameters table
  team_size <- data_params$team_size
  n_teams <- data_params$n_teams
  
  params <- data.frame(
    n_teams = n_teams, 
    team_size = team_size, 
    n_it = 200L, 
    buffer = 100L, 
    dist_metric = "euclidian"
  )
  
  output$df_params <- renderRHandsontable({
    tab <- rhandsontable(
      data = params, 
      colHeaders = c("# Teams", "Team size", "# Iterations", "Buffer", "Metric"),
      rowHeaders = FALSE,
      stretchH = "all"
    ) %>%
      hot_col(col = "Metric", type = "dropdown", source = c("cossine", "euclidian"), allowInvalid = FALSE, readOnly = TRUE) %>%
      hot_validate_numeric(cols = "# Teams", min = 1, max = nrow(data), allowInvalid = FALSE) %>%
      hot_validate_numeric(cols = "Team size", min = 1, max = nrow(data), allowInvalid = FALSE) %>%
      hot_validate_numeric(cols = "# Iterations", min = 100, max = 5000, allowInvalid = FALSE) %>%
      hot_validate_numeric(cols = "Buffer", min = 50, max = 100, allowInvalid = FALSE)
    
    tab
  })
  
  # Open modal
  show_modal(id = 'toy_example_modal', session = session)
})

data_example <- eventReactive(input$run_example, {
  params <- hot_to_r(input$df_params)
  attrs <- hot_to_r(input$df_attr)
  data <- open_data()$data
  
  # Transforming the data
  scaled_data <- cbind(data[, c(1, 2)], mapply(data[, -c(1, 2)], attrs$Maximum*0, attrs$Maximum, FUN = to_01))
  
  # Params
  params <- as.list(params)
  
  return(
    list(
      original_data = data, 
      weights = attrs$Weight, 
      scaled_data = scaled_data, 
      max_scale = attrs$Maximum, 
      description = attrs$Description, 
      params = params
    )
  )
})

observeEvent(input$run_example, {
  shiny.router::change_page(page = "teams", session = session)
  hide_modal('toy_example_modal')
})

observeEvent(input$run_example, {
  Sys.sleep(1)
  updateNumericInput(inputId = "phantom_input", session = session, label = NULL, value = input$phantom_input + 1)
})
