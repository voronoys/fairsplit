ui_examples <- shiny::tagList(
  # Examples
  shinymaterial::material_row(
    shinymaterial::material_column(
      width = 12,
      shinymaterial::material_card(
        title = "Select a toy example",
        depth = 2, 
        divider = TRUE, 
        shiny::br(),
        shinymaterial::material_row(
          shinymaterial::material_column(
            width = 2,
            tab_voronoys(
              text = "Nossa pelada", 
              text_color = text_color, 
              background_color = color_box, 
              icon = "bola-icon.png", 
              id = "real_example"
            )
          ),
          shinymaterial::material_column(
            width = 2,
            tab_voronoys(
              text = "FIFA20", 
              text_color = text_color, 
              background_color = color_box, 
              icon = "fifa-icon.png", 
              id = "fifa_example"
            )
          ),
          shinymaterial::material_column(
            width = 2,
            tab_voronoys(
              text = "Pokémon attributes", 
              text_color = text_color, 
              background_color = color_box, 
              icon = "pokemon-icon.png", 
              id = "pokemon_example"
            )
          ),
          shinymaterial::material_column(
            width = 2,
            tab_voronoys(
              text = "Company attributes", 
              text_color = text_color, 
              background_color = color_box, 
              icon = "ca-icon.png", 
              id = "ca_example"
            )
          ),
          shinymaterial::material_column(
            width = 2,
            tab_voronoys(
              text = "RStudio toy example", 
              text_color = text_color, 
              background_color = color_box,
              icon = "rstudio-icon.png",
              id = "rstudio_example"
            )
          ),
          shinymaterial::material_column(
            width = 2,
            tab_voronoys(
              text = "Upload", 
              text_color = text_color, 
              background_color = color_box,
              icon = "upload-icon.png", 
              id = "upload_data"
            )
          )
        )
      )
    )
  ),
  shiny::conditionalPanel(
    condition = "input.run_example",
    # Teams
    shinymaterial::material_row(
      shinymaterial::material_column(
        width = 12,
        shinymaterial::material_card(
          title = "Teams",
          divider = TRUE,
          shiny::br(),
          shinymaterial::material_checkbox(input_id = "scaled_attrs", label = "Scaled attributes", initial_value = FALSE),
          shinymaterial::material_row(
            shiny::br(),
            # Boxplot
            shinymaterial::material_column(
              width = 8,
              shinymaterial::material_card(
                title = "Skills",
                divider = TRUE,
                br(),
                shinycssloaders::withSpinner(ui_element = plotly::plotlyOutput(outputId = "plot_groups_skills"), type = 8)
              )
            ),
            # Radar
            shinymaterial::material_column(
              width = 4,
              shinymaterial::material_card(
                title = "Comparison",
                divider = TRUE,
                br(),
                shinycssloaders::withSpinner(ui_element = echarts4r::echarts4rOutput(outputId = "plot_teams_radar"), type = 8)
              )
            ),
            # Table
            shinymaterial::material_column(
              width = 12, 
              shinymaterial::material_card(
                title = "Teams",
                divider = TRUE,
                br(),
                shinycssloaders::withSpinner(ui_element = reactable::reactableOutput(outputId = "tab_groups"), type = 8)
              )
            )
          )
        )
      )
    ),
    # Individuals
    shinymaterial::material_row(
      shinymaterial::material_column(
        width = 12, 
        shinymaterial::material_card(
          title = "Individuals",
          divider = TRUE,
          shinymaterial::material_card(
            shinymaterial::material_row(
              shinymaterial::material_column(
                width = 4,
                shinymaterial::material_dropdown(
                  input_id = "selected_teams", 
                  label = "Select the teams to filter and display",
                  choices = "All",
                  selected = "All", 
                  multiple = FALSE
                )
              ),
              shinymaterial::material_column(
                width = 4,
                shinymaterial::material_dropdown(
                  input_id = "selected_attrs", 
                  label = "Select two attributes to display",
                  choices = NULL,
                  selected = NULL, 
                  multiple = TRUE
                )
              ),
              shinymaterial::material_column(
                width = 4,
                shinymaterial::material_dropdown(
                  input_id = "selected_ids", 
                  label = "Select the individuals to display",
                  choices = NULL,
                  selected = NULL, 
                  multiple = TRUE
                )
              )
            ),
            shinymaterial::material_row(
              shiny::br(),
              # Distance
              shinymaterial::material_column(
                width = 4, 
                shinymaterial::material_card(
                  title = "Distance between individuals",
                  divider = TRUE,
                  shiny::br(),
                  shinycssloaders::withSpinner(ui_element = plotly::plotlyOutput(outputId = "plot_id_distance"), type = 8)
                )
              ),
              # Dispersion
              shinymaterial::material_column(
                width = 4, 
                shinymaterial::material_card(
                  title = "Individuals dispersion",
                  divider = TRUE,
                  shiny::br(),
                  shinycssloaders::withSpinner(ui_element = plotly::plotlyOutput(outputId = "plot_id_dispersion"), type = 8)
                )
              ),
              # Radar
              shinymaterial::material_column(
                width = 4, 
                shinymaterial::material_card(
                  title = "Comparison",
                  divider = TRUE,
                  shiny::br(),
                  shinycssloaders::withSpinner(ui_element = echarts4r::echarts4rOutput(outputId = "plot_id_radar"), type = 8)
                )
              )
            )
          )
        )
      )
    ),
    # Algorithm
    shinymaterial::material_row(
      shinymaterial::material_column(
        width = 12, 
        shinymaterial::material_card(
          title = "Algorithm",
          divider = TRUE,
          shinymaterial::material_row(
            shiny::br(),
            # Metric
            shinymaterial::material_column(
              width = 4, 
              shinymaterial::material_card(
                title = "Metric over iterations",
                divider = TRUE,
                shiny::br(),
                shinycssloaders::withSpinner(ui_element = plotly::plotlyOutput(outputId = "plot_metric"), type = 8)
              )
            ),
            # Distance matrix
            shinymaterial::material_column(
              width = 4, 
              shinymaterial::material_card(
                title = "Distance matrix",
                divider = TRUE,
                shiny::br(),
                shinycssloaders::withSpinner(ui_element = plotly::plotlyOutput(outputId = "plot_distance"), type = 8)
              )
            ),
            # Probability
            shinymaterial::material_column(
              width = 4,
              shinymaterial::material_card(
                title = "Probability per team",
                divider = TRUE,
                shiny::br(),
                shinycssloaders::withSpinner(ui_element = plotly::plotlyOutput(outputId = "plot_probs"), type = 8)
              )
            )
          )
        )
      )
    )
  )
)