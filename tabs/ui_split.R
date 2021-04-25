ui_split <- shiny::tagList(
  shinyjs::useShinyjs(),
  shinyjs::hidden(numeric_input(input_id = "phantom_input", label = NULL, value = 1)),
  shiny::conditionalPanel(
    condition = "input.real_example | input.rstudio_example | input.fifa_example | input.pokemon_example | input.ca_example | input.upload_data",
    segment(
      h1("Overall", style = "color: #1a1a1a"),
      segment(
        h2("Overall rates"),
        div(
          shinycssloaders::withSpinner(ui_element = plotly::plotlyOutput(outputId = "boxplot_groups", width = "33%"), type = 8),
          shinycssloaders::withSpinner(ui_element = plotly::plotlyOutput(outputId = "boxplot_groups_skills", width = "33%"), type = 8)
        )
      ),
      segment(
        h2("Skills rates")
      )
    ),
    segment(
      h1("Fair team configuration", style = "color: #1a1a1a"),
      shinycssloaders::withSpinner(ui_element = reactable::reactableOutput(outputId = "tab_groups", width = "100%"), type = 8)
    ),
    br(), br(), br(), br(), br(), br()    
  ),
  shiny::conditionalPanel(
    condition = "!input.real_example & !input.rstudio_example & !input.fifa_example & !input.pokemon_example & !input.ca_example & !input.upload_data",
    h1("Please select a toy example in Home!", style = "align: center")
  )
)