split_reactive <- eventReactive(input$phantom_input, {
  data_params <- data_example()
  data <- data_params$scaled_data[, -2]

  if(nrow(data) > 0) {
    n_teams = data_params$params$n_teams
    team_size = data_params$params$team_size
    
    if(n_teams*team_size > nrow(data)) {
      if(n_teams > nrow(data)) n_teams <- 2
      team_size <- floor(nrow(data)/n_teams)
      
      # Should I send a message?
    }
    
    out <- split_team(
      data = data,
      n_teams = n_teams,
      team_size = team_size,
      weights = data_params$weights,
      n_it = data_params$params$n_it,
      buffer = data_params$params$buffer,
      dist_metric = data_params$params$dist_metric,
      seed = 1
    )
  } else {
    out <- max_scale <- NULL
  }
  
  return(
    list(
      data = data_params$original_data, 
      out = out,
      max_scale = data_params$max_scale, 
      description = data_params$description
    )
  )
})

data_full <- reactive({
  out <- split_reactive()
  data <- out$data
  
  df <- data.frame(out$out$best_setting$groups, check.names = FALSE) %>%
    pivot_longer(cols = names(.), names_to = "team", values_to = "id") %>%
    mutate(team = factor(team, levels = unique(.$team))) %>%
    bind_rows(data.frame(team = "Out", id = out$out$without_team)) %>%
    left_join(data, by = "id")
  
  overall <- cbind(df[, 1:3], mapply(df[, -(1:3)], out$max_scale*0, out$max_scale, FUN = to_01)) %>%
    mutate(overall = 5*rowMeans(across(where(is.numeric)))) %>%
    .$overall
  
  df$overall <- overall 
    
  return(list(data = df, max_scale = out$max_scale, description = out$description))
})

observe({
  # Data
  out <- data_full()
  df <- out$data
  max_scale <- out$max_scale
  description = out$description
  
  df <- df %>%
    relocate(photo, .before = id) %>%
    mutate(overall = round(overall, 1))
  
  # Attributes columns
  names(df)[-c(1:3, ncol(df))] <- description
  
  attr_columns <- description
  columns_list <- mapply(attr_columns, max_scale, FUN = attr_column_def, SIMPLIFY = FALSE)
  # names(columns_list) <- attr_columns
  
  # Photo column
  columns_list$photo <- colDef(
    name = "",
    minWidth = 80,
    maxWidth = 80,
    align = "left", 
    cell = function(value) {
      image <- img(src = value, height = "50px", class = "avatar")
      tagList(
        div(style = list(display = "inline-block", width = "70px"), image)
      )
    }
  )
  
  # Overall column
  columns_list$overall <- colDef(
    minWidth = 150,
    align = "left", 
    aggregate = "mean",
    cell = function(value) {
      rating_stars(rating = value/2)
    },
    format = colFormat(suffix = " out of 5", separators = TRUE, digits = 2),
    html = TRUE
  )
  
  # Team column
  columns_list$team <- colDef(
    minWidth = 130
  )
  
  # Id column
  columns_list$id <- colDef(
    name = "",
    minWidth = 100 
  )
  
  # Table
  df <- df %>%
    arrange(team, desc(overall))
  
  tab <- reactable(
    df, 
    resizable = TRUE,
    fullWidth = TRUE, 
    compact = TRUE, 
    paginationType = "simple", 
    showPageInfo = FALSE, 
    onClick = "expand", 
    striped = TRUE, 
    groupBy = "team", 
    theme = reactable_theme,
    columns = columns_list,  
    defaultPageSize = 11
  )
  
  output$tab_groups <- renderReactable(tab)
})
