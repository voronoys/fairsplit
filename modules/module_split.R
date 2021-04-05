ui_split <- function(id) {
  ns <- NS(id)
  shiny::tagList(
    div(class = "ui grid",
        div(class ="row",
            div(class = "twenty wide column",
                div(
                  class = "ui raised segment",
                  a(class="ui purple ribbon label", "Teams"),
                  p("This is a possible fair team's distribution!"),
                  reactableOutput(outputId = ns("tab_groups"), width = "100%") 
                )
            )
        )
    ),
    br(), br(), br(), br(), br(), br()
  )
}

split_server <- function(id) {
  ns <- NS(id)
  moduleServer(id, function(input, output, session) {
    
    split_reactive <- reactive({
      out <- split_team(
        data = data[, -2],
        n_teams = n_teams,
        team_size = team_size,
        n_it = n_it,
        buffer = buffer,
        dist_metric = dist_metric,
        seed = 1
      )
      
      return(out)
    })
    
    data_full <- reactive({
      out <- split_reactive()
      
      df <- data.frame(out$best_setting$groups, check.names = FALSE) %>%
        pivot_longer(cols = names(.), names_to = "Team", values_to = "id") %>%
        left_join(data, by = "id") %>%
        mutate(overall = rowMeans(across(where(is.numeric)))) %>%
        arrange(Team, desc(overall))
      
      return(df)
    })
    
    observe({
      # Data
      df <- data_full() 
      names(df) <- stringr::str_to_title(names(df)) 
      
      df <- df %>%
        relocate(Photo, .before = Id) %>%
        mutate(Overall = round(Overall, 1))
      
      # Attributes columns
      attr_columns <- names(df[-c(1:3, ncol(df))])
      columns_list <- lapply(attr_columns, FUN = attr_column_def)
      names(columns_list) <- attr_columns
      
      # Photo column
      columns_list$Photo <- colDef(
        name = "",
        minWidth = 80,
        maxWidth = 80,
        align = "left", 
        cell = function(value) {
          image <- img(src = value, height = "50px", class = "rounded")
          tagList(
            div(style = list(display = "inline-block", width = "70px"), image)
          )
        }
      )
      
      # Overall column
      columns_list$Overall <- colDef(
        minWidth = 150,
        align = "left", 
        aggregate = "mean",
        cell = function(value) {
          rating_stars(rating = value/2)
        },
        format = colFormat(suffix = " out of 10", separators = TRUE, digits = 2),
        html = TRUE
      )
      
      # Team column
      columns_list$Team <- colDef(
        minWidth = 70,
      )
      
      # Id column
      columns_list$Id <- colDef(
        name = "",
        minWidth = 50,
      )
      
      # Table
      tab <- reactable(
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
        columns = columns_list
      )
      
      output$tab_groups <- renderReactable(tab)
    })
    
  })
}