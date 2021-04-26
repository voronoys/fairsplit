ui <- shinymaterial::material_page(
  title = "Fair teams",
  shiny::tags$head(
    # Styles.css
    shiny::tags$link(rel="stylesheet", href="styles.css", type="text/css"),
    # https://stackoverflow.com/questions/56770222/get-the-event-which-is-fired-in-shiny
    shiny::tags$script(
      "$(document).on('shiny:inputchanged', function(event) {
          if (event.name != 'changed') {
            Shiny.setInputValue('changed', event.name);
          }
        });"
    )
  ),
  # Examples
  shinymaterial::material_row(
    shinymaterial::material_column(
      width = 12,
      shinymaterial::material_card(
        title = "Select a toy example or upload your own data!",
        depth = 2, 
        divider = TRUE, 
        shiny::br(),
        shiny::div(
          style = "display: flex; justify-content: center;",
          tab_voronoys(
            text = "Nossa pelada", 
            text_color = text_color, 
            background_color = color_box2, 
            icon = "bola-icon.png", 
            id = "real_example"
          ),
          tab_voronoys(
            text = "FIFA20", 
            text_color = text_color, 
            background_color = color_box2, 
            icon = "fifa-icon.png", 
            id = "fifa_example"
          ),
          tab_voronoys(
            text = "Pokémon attributes", 
            text_color = text_color, 
            background_color = color_box2, 
            icon = "pokemon-icon.png", 
            id = "pokemon_example"
          ),
          tab_voronoys(
            text = "Company attributes", 
            text_color = text_color, 
            background_color = color_box2, 
            icon = "ca-icon.png", 
            id = "ca_example"
          ),
          tab_voronoys(
            text = "RStudio toy example", 
            text_color = text_color, 
            background_color = color_box2,
            icon = "rstudio-icon.png",
            id = "rstudio_example"
          ),
          tab_voronoys(
            text = "Upload", 
            text_color = text_color, 
            background_color = color_box2,
            icon = "upload-icon.png", 
            id = "upload_data"
          )
        )
      )
    )
  ),
  # Setups
  shinymaterial::material_row(
    shiny::conditionalPanel(
      condition = "input.real_example|input.rstudio_example|input.fifa_example|input.pokemon_example|input.ca_example|input.upload_data",
      shinymaterial::material_column(
        width = 4,
        shinymaterial::material_card(
          title = shiny::htmlOutput(outputId = "title"),
          divider = TRUE, 
          shiny::br(),
          
          shiny::p("You can change the configuration of the attributes"),
          shinycssloaders::withSpinner(ui_element = rhandsontable::rHandsontableOutput(outputId = "df_attr", height = "15em"), type = 8),
          
          shiny::p("You can also change the algorithm settings"),
          shinycssloaders::withSpinner(ui_element = rhandsontable::rHandsontableOutput(outputId = "df_params"), type = 8),
          
          shiny::br(),
          material_button(input_id = "run_example", label = "Run!", icon = NULL),
          
          style = "height: 34em"
        )
      ),
      shiny::conditionalPanel(
        condition = "!input.run_example",
        shinymaterial::material_column(
          width = 8,
          shinymaterial::material_card(
            title = "Algorithm setup",
            divider = TRUE,
            shiny::br(),
            
            p("Here you can bla bla bla")
          )
        )
      ),
      # Boxplot
      shiny::conditionalPanel(
        condition = "input.run_example",
        shinymaterial::material_column(
          width = 8,
          shinymaterial::material_card(
            title = "Overall results",
            divider = TRUE,
            shinymaterial::material_row(
              shiny::br(),
              shinycssloaders::withSpinner(ui_element = plotly::plotlyOutput(outputId = "boxplot_groups_skills"), type = 8)
            ),
            style = "height: 34em"
          )
        )
      )
    )
  ),
  # Table
  shiny::conditionalPanel(
    condition = "input.run_example",
    shinymaterial::material_row(
      shinymaterial::material_column(
        width = 12, 
        shinymaterial::material_card(
          title = "Teams",
          divider = TRUE,
          shinymaterial::material_row(
            shiny::br(),
            shinycssloaders::withSpinner(ui_element = reactable::reactableOutput(outputId = "tab_groups"), type = 8)
          )
        )
      )
    )
  ),
  # About the app
  shinymaterial::material_row(
    shinymaterial::material_column(
      width = 12, 
      shiny::conditionalPanel(
        condition = "!input.real_example&!input.rstudio_example&!input.fifa_example&!input.pokemon_example&!input.ca_example&!input.upload_data",
        material_card(
          title = "About the fair split",
          depth = 2,
          divider = TRUE,
          shiny::br(),
          
          shiny::p(
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit.
           Praesent placerat ex elit, et finibus justo condimentum quis. Aenean iaculis nec nulla sit amet molestie.
           Integer augue diam, vulputate quis vestibulum eu, scelerisque id nulla. Sed semper lacus enim, in semper neque pellentesque a.
           Vestibulum porta faucibus ullamcorper. Nunc vel neque id mi faucibus rutrum. Mauris faucibus orci at sapien pellentesque laoreet.
           Mauris finibus sapien sed ullamcorper feugiat. Mauris accumsan dolor quis rhoncus malesuada. Etiam vestibulum, est nec ornare congue,
           augue felis interdum nisi, eu fringilla felis lacus quis arcu. Cras vulputate purus quis fringilla pulvinar.
           Donec vel neque vitae nisl dictum condimentum. Aenean ut turpis nibh. Proin sit amet orci ligula. Morbi nec dapibus dui.
           \n
           Lorem ipsum dolor sit amet, consectetur adipiscing elit.
           Praesent placerat ex elit, et finibus justo condimentum quis. Aenean iaculis nec nulla sit amet molestie.
           Integer augue diam, vulputate quis vestibulum eu, scelerisque id nulla. Sed semper lacus enim, in semper neque pellentesque a.
           Vestibulum porta faucibus ullamcorper. Nunc vel neque id mi faucibus rutrum. Mauris faucibus orci at sapien pellentesque laoreet.
           Mauris finibus sapien sed ullamcorper feugiat. Mauris accumsan dolor quis rhoncus malesuada. Etiam vestibulum, est nec ornare congue,
           augue felis interdum nisi, eu fringilla felis lacus quis arcu. Cras vulputate purus quis fringilla pulvinar.
           Donec vel neque vitae nisl dictum condimentum. Aenean ut turpis nibh. Proin sit amet orci ligula. Morbi nec dapibus dui.
           \n
           Lorem ipsum dolor sit amet, consectetur adipiscing elit.
           Praesent placerat ex elit, et finibus justo condimentum quis. Aenean iaculis nec nulla sit amet molestie.
           Integer augue diam, vulputate quis vestibulum eu, scelerisque id nulla. Sed semper lacus enim, in semper neque pellentesque a.
           Vestibulum porta faucibus ullamcorper. Nunc vel neque id mi faucibus rutrum. Mauris faucibus orci at sapien pellentesque laoreet.
           Mauris finibus sapien sed ullamcorper feugiat. Mauris accumsan dolor quis rhoncus malesuada. Etiam vestibulum, est nec ornare congue,
           augue felis interdum nisi, eu fringilla felis lacus quis arcu. Cras vulputate purus quis fringilla pulvinar.
           Donec vel neque vitae nisl dictum condimentum. Aenean ut turpis nibh. Proin sit amet orci ligula. Morbi nec dapibus dui.
           \n
           Lorem ipsum dolor sit amet, consectetur adipiscing elit.
           Praesent placerat ex elit, et finibus justo condimentum quis. Aenean iaculis nec nulla sit amet molestie.
           Integer augue diam, vulputate quis vestibulum eu, scelerisque id nulla. Sed semper lacus enim, in semper neque pellentesque a.
           Vestibulum porta faucibus ullamcorper. Nunc vel neque id mi faucibus rutrum. Mauris faucibus orci at sapien pellentesque laoreet.
           Mauris finibus sapien sed ullamcorper feugiat. Mauris accumsan dolor quis rhoncus malesuada. Etiam vestibulum, est nec ornare congue,
           augue felis interdum nisi, eu fringilla felis lacus quis arcu. Cras vulputate purus quis fringilla pulvinar.
           Donec vel neque vitae nisl dictum condimentum. Aenean ut turpis nibh. Proin sit amet orci ligula. Morbi nec dapibus dui.",
            style = "color: grey; padding-left: 50px;text-align: justify; padding-right: 50px;"
          )
        )
      )
    )
  ),
  shiny::br(),
  # Footer
  shiny::tags$footer(
    "Created by Voronoys", 
    align = "center", 
    style = "position:fixed; 
             bottom:0;
             right:0;
             left:0;
             background: #8c77fa;
             color: white;
             padding:20px;
             box-sizing:border-box;
             z-index: 1000;
             text-align: left"
  ),
  shiny::tags$footer(
    a(
      href = "https://github.com", 
      icon("github"), 
      style = "color: white"
    ), 
    align = "center", 
    style = "position:fixed;
             bottom:0;
             right:0;
             left:0;
             color: white;
             padding:20px;
             box-sizing:border-box;
             z-index: 1000;
             text-align: right"
  )
)