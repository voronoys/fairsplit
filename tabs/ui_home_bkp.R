ui_home <- shiny::tagList(
  shiny::div(
    shiny::h1("Select a toy example or upload your own data!", style = "color: white; padding-left: 30px;"),
    shiny::br(), shiny::br(),
    shiny::div(
      style = "display: flex; position: relative; right: 10%; left: 10%;",
      tab_voronoys(texto = "Nossa pelada", cor = color_box, icon = "bola-icon.png", id = "real_example"),
      tab_voronoys(texto = "FIFA20", cor = color_box, icon = "fifa-icon.png", id = "fifa_example"),
      tab_voronoys(texto = "Pokémon attributes", cor = color_box, icon = "pokemon-icon.png", id = "pokemon_example"),
      tab_voronoys(texto = "Company attributes", cor = color_box, icon = "ca-icon.png", id = "ca_example"),
      tab_voronoys(texto = "RStudio toy example", cor = color_box, icon = "rstudio-icon.png", id = "rstudio_example"),
      tab_voronoys(texto = "Upload", cor = color_box, icon = "upload-icon.png", id = "upload_data")
    ),
    shiny::modalDialog(
      shiny::htmlOutput(outputId = "title"),
      id = "toy_example_modal",
      
      shiny::h3("You can change the configuration of the attributes"),
      # shinycssloaders::withSpinner(ui_element = rhandsontable::rHandsontableOutput(outputId = "df_attr", height = "15em"), type = 8),
      
      shiny::h3("You can also change the algorithm settings"),
      # shinycssloaders::withSpinner(ui_element = rhandsontable::rHandsontableOutput(outputId = "df_params"), type = 8),
      
      shiny::br(),
      
      footer = shiny.semantic::action_button(input_id = "run_example", label = "Run!", icon = NULL, style = "color: white"), 
      style = "color: #464545"
    ),
    shiny::modalDialog(
      shiny::h1("Upload your own dataset"),
      id = "upload_modal",
      
      shiny::h3("The file must follow the following structure: 'id', 'photo', 'attributes'."),
      file_input2(input_id = "user_data", label = NULL, multiple = FALSE, accept = c("txt", "csv"), button_label = "Browse..."),  
      shiny::h5("Read the guidelines for a full explanation.", style = "margin-bottom: 0px"),
      shiny::h5("Acceptable extensions: txt and csv.", style = "margin-top: 0px"),
      
      footer = shiny.semantic::action_button(input_id = "upload_file", label = "Upload", icon = NULL, style = "color: white"), 
      style = "color: #464545"
    ),
    shiny::br(), shiny::br(),
    shiny::h1("About the fair split", style = "color: white; padding-left: 30px;"),
    shiny::h3(
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
       Praesent placerat ex elit, et finibus justo condimentum quis. Aenean iaculis nec nulla sit amet molestie. 
       Integer augue diam, vulputate quis vestibulum eu, scelerisque id nulla. Sed semper lacus enim, in semper neque pellentesque a. 
       Vestibulum porta faucibus ullamcorper. Nunc vel neque id mi faucibus rutrum. Mauris faucibus orci at sapien pellentesque laoreet. 
       Mauris finibus sapien sed ullamcorper feugiat. Mauris accumsan dolor quis rhoncus malesuada. Etiam vestibulum, est nec ornare congue, 
       augue felis interdum nisi, eu fringilla felis lacus quis arcu. Cras vulputate purus quis fringilla pulvinar. 
       Donec vel neque vitae nisl dictum condimentum. Aenean ut turpis nibh. Proin sit amet orci ligula. Morbi nec dapibus dui.", 
      style = "color: white; padding-left: 50px;text-align: justify; padding-right: 50px;"
    )
  )
)
