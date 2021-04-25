ui_home <- shiny::tagList(
  div(
    h1("Select a toy example or upload your own data!", style = "color: white; padding-left: 30px;"),
    br(), br(),
    div(
      style = "display: flex; position: relative; right: 10%; left: 10%;",
      tab_voronoys(texto = "Nossa pelada", cor = color_box, icon = "bola-icon.png", id = "real_example"),
      tab_voronoys(texto = "FIFA20", cor = color_box, icon = "fifa-icon.png", id = "fifa_example"),
      tab_voronoys(texto = "Pokémon attributes", cor = color_box, icon = "pokemon-icon.png", id = "pokemon_example"),
      tab_voronoys(texto = "Company attributes", cor = color_box, icon = "ca-icon.png", id = "ca_example"),
      tab_voronoys(texto = "RStudio toy example", cor = color_box, icon = "rstudio-icon.png", id = "rstudio_example"),
      tab_voronoys(texto = "Upload", cor = color_box, icon = "upload-icon.png", id = "upload_data")
    ),
    shiny.semantic::modal(
      shiny::htmlOutput(outputId = "title"),
      id = "toy_example_modal",
      
      h3("You can change the configuration of the attributes"),
      shinycssloaders::withSpinner(ui_element = rhandsontable::rHandsontableOutput(outputId = "df_attr", height = "15em"), type = 8),
      
      h3("You can also change the algorithm settings"),
      shinycssloaders::withSpinner(ui_element = rhandsontable::rHandsontableOutput(outputId = "df_params"), type = 8),
      
      br(),
      
      footer = shiny.semantic::action_button(input_id = "run_example", label = "Run!", icon = NULL, style = "color: white"), 
      style = "color: #464545"
    ),
    shiny.semantic::modal(
      h1("Upload your own dataset"),
      id = "upload_modal",
      
      h3("The file must follow the following structure: 'id', 'photo', 'attributes'."),
      file_input2(input_id = "user_data", label = NULL, multiple = FALSE, accept = c("txt", "csv"), button_label = "Browse..."),  
      h5("Read the guidelines for a full explanation.", style = "margin-bottom: 0px"),
      h5("Acceptable extensions: txt and csv.", style = "margin-top: 0px"),
      
      footer = shiny.semantic::action_button(input_id = "upload_file", label = "Upload", icon = NULL, style = "color: white"), 
      style = "color: #464545"
    ),
    br(), br(),
    h1("About the fair split", style = "color: white; padding-left: 30px;"),
    h3("Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
        Praesent placerat ex elit, et finibus justo condimentum quis. Aenean iaculis nec nulla sit amet molestie. 
        Integer augue diam, vulputate quis vestibulum eu, scelerisque id nulla. Sed semper lacus enim, in semper neque pellentesque a. 
        Vestibulum porta faucibus ullamcorper. Nunc vel neque id mi faucibus rutrum. Mauris faucibus orci at sapien pellentesque laoreet. 
        Mauris finibus sapien sed ullamcorper feugiat. Mauris accumsan dolor quis rhoncus malesuada. Etiam vestibulum, est nec ornare congue, 
        augue felis interdum nisi, eu fringilla felis lacus quis arcu. Cras vulputate purus quis fringilla pulvinar. 
        Donec vel neque vitae nisl dictum condimentum. Aenean ut turpis nibh. Proin sit amet orci ligula. Morbi nec dapibus dui. 
        Aenean iaculis nulla quam, vel luctus enim maximus in.
        \n
        Pellentesque laoreet eu est id tincidunt. Curabitur sollicitudin orci id fringilla malesuada. Donec at ornare tellus. 
        In blandit id erat ac finibus. Pellentesque massa magna, congue vel volutpat a, iaculis sit amet metus. Suspendisse potenti. 
        Integer sem velit, porttitor eget eros quis, lobortis lobortis enim. Nam vehicula enim massa, dictum venenatis leo convallis in. 
        Duis vestibulum mattis nunc, ut tincidunt lacus rhoncus sit amet. Sed eget enim ac neque fringilla pretium. 
        Interdum et malesuada fames ac ante ipsum primis in faucibus. Morbi venenatis vulputate diam, non accumsan metus ultrices eu. 
        Pellentesque convallis rhoncus egestas. Praesent auctor felis in massa sollicitudin pretium ut at ipsum. 
        Ut rutrum eros nec ante fermentum, eu commodo sem luctus.
        \n
        Phasellus feugiat finibus pulvinar. Aenean vitae arcu auctor, ornare nibh sit amet, ultricies ex. 
        Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. 
        Quisque ac arcu sollicitudin, fermentum quam vel, luctus orci. Fusce ornare risus mi, vitae hendrerit eros mattis id. 
        In faucibus scelerisque tellus, pharetra pellentesque lectus efficitur vitae. Sed mattis iaculis quam, id accumsan lorem tincidunt vel. 
        Phasellus vitae placerat nulla. Quisque eros nulla, sollicitudin quis libero at, convallis mollis tortor. 
        Integer vel porttitor enim, vel luctus arcu. Quisque convallis faucibus maximus.
        \n
        Sed lobortis tellus sed risus porttitor, in porta magna posuere. Pellentesque imperdiet lacus neque, sit amet sollicitudin mi placerat quis. 
        Nulla eu gravida turpis. Etiam diam neque, efficitur imperdiet mi eu, iaculis imperdiet sapien. Integer id diam lectus. 
        Nulla posuere lectus pretium nisi aliquet, in consectetur tortor maximus. Curabitur nunc velit, pretium in sem nec, ullamcorper vulputate libero. 
        Duis ullamcorper lacinia volutpat. Sed massa nisl, pretium vitae aliquam id, lacinia quis tellus.
        \n
        Aenean consequat tortor ut purus dictum, vitae euismod est laoreet. Mauris rutrum volutpat bibendum. 
        Ut ipsum nulla, consectetur vitae leo sit amet, sollicitudin lobortis arcu. Pellentesque vitae tempor arcu, non sodales justo. 
        Nunc ut pharetra felis, id suscipit nulla. Mauris sodales elementum lorem, sed ultrices neque feugiat in.
        Vestibulum vulputate vestibulum vehicula. Suspendisse interdum porta nulla, non consequat quam venenatis non. 
        Proin in luctus ligula. Aliquam condimentum nisi massa, at malesuada sapien tempor quis. Suspendisse rutrum ante sit amet quam aliquam, nec sagittis magna faucibus. 
        Nunc lacinia pretium scelerisque. Ut pretium risus ut lacus faucibus, vel venenatis diam sagittis.", 
       style = "color: white; padding-left: 50px;text-align: justify; padding-right: 50px;"),
  )
)
