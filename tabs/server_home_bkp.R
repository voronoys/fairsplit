shiny::observeEvent(input$upload_data, {
  # Open modal
  shiny.semantic::show_modal(id = 'upload_modal', session = session)
})

open_data <- shiny::eventReactive(
  c(input$real_example, 
    input$rstudio_example, 
    input$fifa_example, 
    input$ca_example, 
    input$pokemon_example, 
    input$upload_file), {
      # Who fired the reactive?
      changed <- shiny::req(input$changed)
      
      data <- title <- n_teams <- team_size <- NULL
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
        n_teams <- 17L
        team_size <- 11L
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
      if(changed == "upload_file") {
        ext <- tools::file_ext(input$user_data$datapath)
        
        if(!(ext %in% c("csv", "txt"))) {
          shinyWidgets::sendSweetAlert(
            session = session, 
            title = "It must be a .csv or .txt file", 
            text = sprintf("Sorry, We still not accept %s files!", ext), 
            type = "error", 
          )
          
          data <- NULL
        } else {
          # Trying ;
          data <- read.table(file = input$user_data$datapath, header = TRUE, sep = ";", check.names = FALSE)
          # Trying ,
          if(ncol(data) == 1) data <- read.table(file = input$user_data$datapath, header = TRUE, sep = ",", check.names = FALSE)
          # Trying \t
          if(ncol(data) == 1) data <- read.table(file = input$user_data$datapath, header = TRUE, sep = "\t", check.names = FALSE)
          
          # We could not read the file properly
          if(ncol(data) == 1) {
            shinyWidgets::sendSweetAlert(
              session = session, 
              title = "Which delimiter are you using?", 
              text = "Try ';', ',' or tab as delimiter.",
              type = "error", 
            )
            
            data <- NULL
          } else {
            # Id and photo columns
            names(data)[1:2] <- c("id", "photo")
            
            # We could not read the attributes columns properly
            if(!all(sapply(X = data[, -(1:2)], FUN = is.numeric))) {
              shinyWidgets::sendSweetAlert(
                session = session, 
                title = "There is something wrong with the attributes columns", 
                text = "Please check if it is a number.",
                type = "error", 
              )
              
              data <- NULL
            } else {
              data <- data[, colSums(is.na(data)) == 0]
              
              title <- "Check the information"
              n_teams <- as.integer(floor(sqrt(nrow(data))))
              if(n_teams == 1) n_teams <- 2
              team_size <- as.integer(floor(nrow(data)/n_teams))
            }
          }
        }
        hide_modal('toy_example_modal')
      }
      
      return(list(data = data, title = title, n_teams = n_teams, team_size = team_size))
    })

shiny::observe({
  data_params <- open_data()
  data <- data_params$data
  
  if(!is.null(data)) {
    # Guessing the data sacle
    max_scale <- apply(X = data[, -c(1, 2)], MARGIN = 2, FUN = function(x) next_beauty_number(max(x)))
    min_scale <- max_scale*0
    
    vars <- names(data[, -c(1, 2)])
    
    # Modal title  
    output$title <- renderText(sprintf("<h1 style='color=#C0C0C0 !important'>%s</h1>", data_params$title))
    
    # Attributes table
    output$df_attr <- rhandsontable::renderRHandsontable({
      attrs <- data.frame(
        Variable = vars, 
        Description = stringr::str_to_title(vars), 
        Weight = 1, 
        Maximum = max_scale, 
        row.names = NULL, 
        stringsAsFactors = FALSE
      )
      
      tab <- rhandsontable::rhandsontable(
        data = attrs,
        rowHeaders = FALSE,
        stretchH = "all"
      ) %>% 
        rhandsontable::hot_col(col = "Variable", readOnly = TRUE) %>%
        rhandsontable::hot_validate_numeric(cols = "Weight", min = 0, max = 10000, allowInvalid = FALSE)
    })
    
    # Parameters table
    team_size <- data_params$team_size
    n_teams <- data_params$n_teams
    
    params <- data.frame(
      n_teams = n_teams, 
      team_size = team_size, 
      n_it = 200L, 
      buffer = 100L, 
      dist_metric = "cosine"
    )
    
    output$df_params <- rhandsontable::renderRHandsontable({
      tab <- rhandsontable::rhandsontable(
        data = params, 
        colHeaders = c("# Teams", "Team size", "# Iterations", "Buffer", "Metric"),
        rowHeaders = FALSE,
        stretchH = "all"
      ) %>%
        rhandsontable::hot_validate_character(col = "Metric", choices = c("cosine", "euclidian"), allowInvalid = FALSE) %>%
        rhandsontable::hot_validate_numeric(cols = "# Teams", min = 1L, max = as.integer(nrow(data)), allowInvalid = FALSE) %>%
        rhandsontable::hot_validate_numeric(cols = "Team size", min = 1L, max = as.integer(nrow(data)), allowInvalid = FALSE) %>%
        rhandsontable::hot_validate_numeric(cols = "# Iterations", min = 100L, max = 5000L, allowInvalid = FALSE) %>%
        rhandsontable::hot_validate_numeric(cols = "Buffer", min = 50L, max = 500L, allowInvalid = FALSE)
      
      tab
    })
    
    # Open modal
    shiny.semantic::show_modal(id = 'toy_example_modal', session = session) 
  }
})

data_example <- shiny::eventReactive(input$run_example, {
  params <- rhandsontable::hot_to_r(input$df_params)
  attrs <- rhandsontable::hot_to_r(input$df_attr)
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

shiny::observeEvent(input$run_example, {
  shiny.router::change_page(page = "teams", session = session)
  shiny.semantic::hide_modal('toy_example_modal')
})

shiny::observeEvent(input$run_example, {
  shiny::updateNumericInput(inputId = "phantom_input", session = session, label = NULL, value = input$phantom_input + 1)
})
