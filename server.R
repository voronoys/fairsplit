server <- function(input, output, session) {
  # Open upload modal
  shiny::observeEvent(input$upload_data, {
    # Open modal
    shinymaterial::open_material_modal(session = session, modal_id = 'upload_modal')
  })
  
  # Open data
  open_data <- shiny::eventReactive(
    c(input$real_example, 
      input$rstudio_example, 
      input$fifa_example, 
      input$ca_example, 
      input$pokemon_example, 
      input$upload_file), {
        # Who fired the reactive?
        changed <- shiny::req(input$changed)
        
        # Updating run button
        shinyjs::reset(id = "run_example")
        
        data <- title <- n_teams <- team_size <- NULL
        # Open data
        if(changed == "real_example") {
          data <- read.table(file = "data/nossa_pelada.txt", header = TRUE, sep = ";", check.names = FALSE)
          title <- "Real game at Brazil"
          
          n_teams <- 4L
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
          team_size <- 6L
        }
        if(changed == "pokemon_example") {
          data <- read.table(file = "data/pokemon.txt", header = TRUE, sep = ";", check.names = FALSE)
          data <- data[, colSums(is.na(data)) == 0]
          
          title <- "Pokémon"
          n_teams <- 10L
          team_size <- 10L
        }
        if(changed == "ca_example") {
          data <- read.table(file = "data/company.txt", header = TRUE, sep = ";", check.names = TRUE)
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
              text = sprintf("Sorry, we do not accept %s files!", ext), 
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
          shinymaterial::close_material_modal(session = session, modal_id = 'upload_modal')
        }
        
        return(list(data = data, title = title, n_teams = n_teams, team_size = team_size))
      }, ignoreInit = TRUE, ignoreNULL = TRUE)
  
  # Settings
  shiny::observe({
    data_params <- open_data()
    data <- data_params$data
    
    if(!is.null(data)) {
      # Guessing the data sacle
      max_scale <- apply(X = data[, -c(1, 2)], MARGIN = 2, FUN = function(x) as.integer(next_beauty_number(max(x))))
      min_scale <- max_scale*0
      
      vars <- names(data[, -c(1, 2)])
      
      # Open modal
      shinymaterial::open_material_modal(session = session, modal_id = "params_modal")
      
      # Modal title  
      output$title <- renderText(data_params$title)
      
      # Attributes table
      output$df_attr <- rhandsontable::renderRHandsontable({
        attrs <- data.frame(
          Variable = vars, 
          Description = stringr::str_to_title(stringr::str_replace_all(string = vars, pattern = "\\.", replacement = " ")), 
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
        n_it = 300L
      )
      
      output$df_params <- rhandsontable::renderRHandsontable({
        tab <- rhandsontable::rhandsontable(
          data = params, 
          colHeaders = c("# Teams", "Team size", "# Iterations"),
          rowHeaders = FALSE,
          stretchH = "all"
        ) %>%
          rhandsontable::hot_validate_numeric(cols = "# Teams", min = 1L, max = as.integer(nrow(data)), allowInvalid = FALSE) %>%
          rhandsontable::hot_validate_numeric(cols = "Team size", min = 1L, max = as.integer(nrow(data)), allowInvalid = FALSE) %>%
          rhandsontable::hot_validate_numeric(cols = "# Iterations", min = 100L, max = 5000L, allowInvalid = FALSE)
        
        tab
      })
    }
  })
  
  # All needed data
  data_example <- shiny::eventReactive(input$run_example, {
    params <- rhandsontable::hot_to_r(input$df_params)
    attrs <- rhandsontable::hot_to_r(input$df_attr)
    data <- open_data()$data
    
    # Close modal
    shinymaterial::close_material_modal(session = session, modal_id = "params_modal")
    
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
  
  # Run algorithm
  split_reactive <- shiny::eventReactive(input$run_example, {
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
        buffer = 200,
        dist_metric = "cosine",
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
  
  # Teams
  ## Full data to use in the table and teams' plots
  data_full <- shiny::reactive({
    out <- split_reactive()
    data <- out$data
    
    df <- data.frame(out$out$best_setting$groups, check.names = FALSE) %>%
      tidyr::pivot_longer(cols = names(.), names_to = "team", values_to = "id") %>%
      dplyr::mutate(team = factor(team, levels = unique(.$team))) 
    
    if(length(out$out$without_team) > 0) df <- df %>% dplyr::bind_rows(data.frame(team = "Out", id = out$out$without_team))
    
    df <- df %>% dplyr::left_join(data, by = "id")
    
    overall <- cbind(df[, 1:3], mapply(df[, -(1:3)], out$max_scale*0, out$max_scale, FUN = to_01)) %>%
      dplyr::mutate(overall = 5*rowMeans(across(where(is.numeric)))) %>%
      .$overall
    
    df$overall <- overall 
    
    return(list(data = df, max_scale = out$max_scale, description = out$description))
  })
  
  ## Crating table
  output$tab_groups <- reactable::renderReactable({
    # Data
    out <- data_full()
    df <- out$data
    max_scale <- out$max_scale
    description = out$description
    
    df <- df %>%
      dplyr::relocate(photo, .before = id) %>%
      dplyr::mutate(overall = round(overall, 1)) %>%
      dplyr::rename(Team = team, Overall = overall)
    
    # Attributes columns
    names(df)[-c(1:3, ncol(df))] <- description
    
    attr_columns <- description
    columns_list <- mapply(attr_columns, max_scale, FUN = attr_column_def, SIMPLIFY = FALSE)
    
    # Photo column
    columns_list$photo <- reactable::colDef(
      name = "",
      minWidth = 80,
      maxWidth = 80,
      align = "left", 
      cell = function(value) {
        image <- img(src = value, height = "50px", class = "avatar")
        tagList(
          shiny::div(style = list(display = "inline-block", width = "70px"), image)
        )
      }
    )
    
    # Overall column
    columns_list$Overall <- reactable::colDef(
      minWidth = 150,
      align = "left", 
      aggregate = "mean",
      cell = function(value) {
        rating_stars(rating = value)
      },
      format = reactable::colFormat(suffix = " out of 5", separators = TRUE, digits = 2),
      html = TRUE
    )
    
    # Team column
    columns_list$Team <- reactable::colDef(
      minWidth = 130
    )
    
    # Id column
    columns_list$id <- reactable::colDef(
      name = "",
      minWidth = 100 
    )
    
    # Table
    df <- df %>%
      dplyr::arrange(Team, desc(Overall))
    
    tab <- reactable::reactable(
      df, 
      resizable = TRUE,
      fullWidth = TRUE, 
      compact = TRUE, 
      paginationType = "simple", 
      showPageInfo = FALSE, 
      onClick = "expand", 
      striped = TRUE, 
      groupBy = "Team", 
      # theme = reactable_theme,
      columns = columns_list,  
      defaultPageSize = 11
    )
    
    return(tab)
  })
  
  ## Skills: boxplot
  output$plot_groups_skills <- plotly::renderPlotly({
    # Data
    out <- data_full()
    description <- out$description
    data <- out$data %>%
      dplyr::select(-overall)
    
    if(input$scaled_attrs) data <- cbind(data[, (1:3)], mapply(data[, -(1:3)], out$max_scale*0, out$max_scale, FUN = to_01))
    
    names(data)[-c(1:3)] <- description
    
    # Plot: Skill ratings
    data <- data %>%
      tidyr::pivot_longer(cols = where(is.numeric), names_to = "skill", values_to = "rate")
    
    plt <- plot_ly(
      data = data, 
      y = ~rate, 
      x = ~skill, 
      color = ~team,
      colors = roma_palette,
      type = "box"
    ) %>% 
      layout(
        xaxis = list(title = "Attributes"), 
        yaxis = list(title = "Rate"), 
        boxmode = "group"
      )
    
    return(plt)
  })
  
  ## Radar
  output$plot_teams_radar <- echarts4r::renderEcharts4r({
    out <- data_full()
    
    data <- out$data %>%
      dplyr::select(-photo, -overall, -id)
    
    if(input$scaled_attrs) data <- cbind(data[, 1], mapply(data[, -1], out$max_scale*0, out$max_scale, FUN = to_01))
    
    data <- data %>%
      dplyr::group_by(team) %>%
      dplyr::summarise(dplyr::across(.cols = everything(), .fns = function(x) round(mean(x), 2))) %>%
      dplyr::ungroup() %>%
      tidyr::pivot_longer(cols = !team) %>%
      tidyr::pivot_wider(id_cols = name, names_from = team, values_from = value) %>%
      dplyr::left_join(rhandsontable::hot_to_r(input$df_attr)[, c("Variable", "Maximum")], by = c("name" = "Variable")) %>%
      dplyr::mutate(name = stringr::str_to_title(name))
    
    data$rank <- rank(rowMeans(data[, -1]), ties.method = "random")
    
    data <- data %>%
      dplyr::arrange(rank) %>%
      select(-rank)
    
    max_vec <- data$Maximum
    data <- data %>% select(-Maximum)
    
    plt <- plot_radar(data = data, cols = names(data)[-1], max = max_vec)
    
    return(plt)
  })
  
  # Available ids and attributes
  observeEvent(c(input$run_example, input$selected_teams), {
    teams <- levels(data_full()$data$team)
    ids <- levels(data_full()$data$id)
    attrs <- names(data_full()$data)[-(1:3)]
    
    changed <- shiny::req(input$changed)
    
    # Update teams
    if(changed != "selected_teams") {
      update_material_dropdown_multiple(
        session = session,
        input_id = "selected_teams",
        choices = c("All", teams),
        value = "All"
      )
    }
    
    # Update ids
    if(input$selected_teams == "All") {
      ids_sel <- ids[1:5]
    } else {
      ids_sel <- data_full()$data %>%
        dplyr::filter(team == input$selected_teams) %>%
        .$id %>%
        as.character()
    }
    
    update_material_dropdown_multiple(
      session = session,
      input_id = "selected_ids",
      choices = ids,
      value = ids_sel
    )
    
    # Update attributes
    update_material_dropdown_multiple(
      session = session,
      input_id = "selected_attrs",
      choices = attrs,
      value = attrs[1:2]
    )
  }, ignoreNULL = TRUE, ignoreInit = TRUE)
  
  ## Distance matrix
  output$plot_id_distance <- renderPlotly({
    ids <- input$selected_ids
    
    if(length(ids) > 1) {
      data <- data_example()$original_data %>%
        dplyr::select(-photo) %>%
        dplyr::filter(id %in% ids)
      
      metric <- "cosine"
      w <- isolate(rhandsontable::hot_to_r(input$df_attr)$Weight)
      
      data_aux <- data[, -1]
      rownames(data_aux) <- data$id
      
      if(nrow(data_aux) > 0) {
        if(metric == "cosine") {
          data <- as.matrix(cosine(x = data_aux, weights = w))
        } else {
          data <- as.matrix(euclidean(x = data_aux, weights = w))
        }
        
        data[upper.tri(data)] <- NA
        
        plt <- plot_ly(
          x = colnames(data),
          y = rownames(data), 
          z = data, 
          colors = roma_palette[c(11, 2)],
          hovertemplate = 'Distance between %{y} and %{x}: %{z:.4f}<extra></extra>',
          type = "heatmap"
        )
        
        return(plt)
      }
    }
  })
  
  ## Individuals dispersion
  output$plot_id_dispersion <- renderPlotly({
    ids <- input$selected_ids
    attrs <- input$selected_attrs
    
    if(length(attrs) == 1) attrs <- c(attrs, attrs)
    if(length(attrs) > 2) attrs <- attrs[1:2]
    
    if(length(ids) > 0 & length(attrs) > 0) {
      max_vec <- rhandsontable::hot_to_r(input$df_attr) %>%
        dplyr::filter(Variable %in% attrs) %>%
        .$Maximum
      
      data <- data_example()$original_data %>%
        dplyr::select(-photo) %>%
        dplyr::filter(id %in% ids) %>%
        dplyr::select(id, !!attrs)
      
      plt <- plot_ly(
        data = data,
        x = ~eval(expr = parse(text = attrs[1])),
        y = ~eval(expr = parse(text = attrs[2])),
        color = ~id, 
        colors = roma_palette,
        text = paste0('<b>', data$id, '</b><br>', attrs[1],': ', data[, attrs[1]], '<br>', attrs[2], ': ', data[, attrs[2]]),
        hoverinfo = 'text',
        type = "scatter", mode = "markers"
      ) %>%
        layout(
          xaxis = list(title = stringr::str_to_title(attrs[1]), range = c(0, 1.01*max_vec[1])),
          yaxis = list(title = stringr::str_to_title(attrs[2]), range = c(0, 1.01*max_vec[2]))
        )
      
      return(plt)
    }
  })
  
  ## Radar
  output$plot_id_radar <- echarts4r::renderEcharts4r({
    ids <- input$selected_ids
    
    if(length(ids) > 0) {
      data <- data_example()$original_data %>%
        dplyr::select(-photo) %>%
        dplyr::filter(id %in% ids)
      
      data <- data %>%
        dplyr::group_by(id) %>%
        dplyr::summarise(dplyr::across(.cols = everything(), .fns = function(x) round(mean(x), 2))) %>%
        dplyr::ungroup() %>%
        tidyr::pivot_longer(cols = !id) %>%
        tidyr::pivot_wider(id_cols = name, names_from = id, values_from = value) %>%
        dplyr::left_join(rhandsontable::hot_to_r(input$df_attr)[, c("Variable", "Maximum")], by = c("name" = "Variable")) %>%
        dplyr::mutate(name = stringr::str_to_title(name))
      
      data$rank <- rank(rowMeans(data[, -1]), ties.method = "random")
      
      data <- data %>%
        dplyr::arrange(rank) %>%
        select(-rank)
      
      max_vec <- data$Maximum
      data <- data %>% select(-Maximum)
      
      plt <- plot_radar(data = data, cols = names(data)[-1], max = max_vec)
      
      return(plt)
    }
  })
  
  # Algorithm
  ## Metric's time series
  output$plot_metric <- renderPlotly({
    data <- data.frame(metric = split_reactive()$out$metric)
    data$iteration <- 1:nrow(data)
    
    # title <- stringr::str_to_title(string = rhandsontable::hot_to_r(input$df_params)$dist_metric)
    title <- "Objective function"
    
    plt <- plotly::plot_ly() %>%
      add_trace(
        data = data,
        y = ~metric, x = ~iteration, 
        line = list(color = roma_palette[2]), 
        hovertemplate = paste('<b>Iteration</b>: %{x} \n',
                              '<b>Metric</b>: %{y:.4f}<extra></extra>'),
        type = 'scatter', 
        mode = 'lines'
      ) %>% 
      layout(
        xaxis = list(title = NULL), 
        yaxis = list(title = title)
      )
    
    return(plt)
  })
  
  ## Distance matrix
  output$plot_distance <- renderPlotly({
    data <- split_reactive()$out$dist
    data[upper.tri(data)] <- NA
    
    plt <- plot_ly(
      x = colnames(data),
      y = rownames(data), 
      z = data, 
      colors = roma_palette[c(11, 2)],
      hovertemplate = 'Distance between %{y} and %{x}: %{z:.4f}<extra></extra>',
      type = "heatmap"
    )
    
    return(plt)
  })
  
  ## Distance probs
  output$plot_probs <- renderPlotly({
    data <- split_reactive()
    probs <- data$out$probs[, , dim(data$out$probs)[3]]
    rownames(probs) <- data$data$id
    colnames(probs) <- paste("Team", 1:ncol(probs))
    
    df_probs <- data.frame(probs, check.names = FALSE) %>% 
      dplyr::mutate(
        rownames = rownames(.),
        total = rowSums(across(where(is.numeric)))
      ) %>%
      dplyr::filter(total > 0) %>%
      dplyr::select(-total) %>%
      dplyr::arrange(dplyr::across(dplyr::starts_with("Team")))
    
    rownames(df_probs) <- df_probs$rownames
    
    probs <- as.matrix(df_probs %>% select(-rownames))
    
    plt <- plot_ly(
      x = colnames(probs),
      y = rownames(probs), 
      z = probs, 
      colors = roma_palette[c(11, 2)],
      hovertemplate = '<b>%{y}</b><br>Probability to be in %{x}: %{z:.2f}<extra></extra>',
      type = "heatmap"
    )
    
    return(plt)
  })
}