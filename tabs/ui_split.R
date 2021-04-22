ui_split <- shiny::tagList(
  shinyjs::useShinyjs(),
  shinyjs::hidden(numeric_input(input_id = "phantom_input", label = NULL, value = 1)),
  conditionalPanel(
    condition = "input.real_example | input.rstudio_example | input.fifa_example | input.pokemon_example | input.ca_example | input.upload_data",
    div(class = "ui raised segment",
        style = "padding-left: 20px",
        div(
          a(class="ui grey ribbon label", "Teams"),
          h1("Fair team configuration", style = "color: #1a1a1a"),
          br(), br(),
          shinycssloaders::withSpinner(ui_element = reactableOutput(outputId = "tab_groups", width = "100%"), type = 8),
          style = "min-height: 20em"
        )
    ),
    br(), br(), br(), br(), br(), br()    
  ),
  conditionalPanel(
    condition = "!input.real_example & !input.rstudio_example & !input.fifa_example & !input.pokemon_example & !input.ca_example & !input.upload_data",
    h1("Please select a toy example in Home!", style = "align: center")
  )
)