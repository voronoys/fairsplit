ui <- shinymaterial::material_page(
  title = "<span><span style = 'color: #3EB8F4'>Fair</span><span style = 'color: #FFA024'>Split</span></span>",
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
  shinyjs::useShinyjs(),
  shinymaterial::material_side_nav(
    # fixed = FALSE, 
    image_source = "img/background.jpeg",
    material_side_nav_tabs(
      side_nav_tabs = c(
        "Home" = "home",
        "Examples" = "examples",
        "About" = "about"
      ),
      icons = c("home", "explore", "question_answer")
    )
  ),
  shinymaterial::material_side_nav_tab_content(
    side_nav_tab_id = "home",
    ui_home  
  ),
  material_side_nav_tab_content(
    side_nav_tab_id = "examples",
    ui_examples,
    # Modal for the examples
    shinymaterial::material_modal(
      modal_id = "params_modal", 
      display_button = FALSE,
      button_text = "",
      title = shiny::htmlOutput(outputId = "title"),
      
      shiny::p("Change the description, weight in the algorithm, and the maximum value for each attribute."),
      shinycssloaders::withSpinner(ui_element = rhandsontable::rHandsontableOutput(outputId = "df_attr", height = "15em"), type = 8),
      
      shiny::p("Select the number of individuals and number of teams. You can also change the number of iterations."),
      shinycssloaders::withSpinner(ui_element = rhandsontable::rHandsontableOutput(outputId = "df_params"), type = 8),
      
      shiny::br(),
      shinymaterial::material_button(input_id = "run_example", label = "Run!", icon = NULL),
    ),
    
    # Modal for the user data
    shinymaterial::material_modal(
      modal_id = "upload_modal",
      display_button = FALSE,
      button_text = "",
      title = "Upload your own dataset",
      
      shiny::p(
        shiny::HTML(
          sprintf(
            "The file must contain: 'id' and 'photo' columns, and one column for each attribute. Click %s to download a file to serve as an example.",
            downloadLink(outputId = "data_example", label = "here", style = "font-color: #FF0000")
          )
        )
      ),
      
      fileInput2(inputId = "user_data", accept = c(".txt", ".csv"), placeholder = "Drop a file here!"),
      shiny::h5("Acceptable extensions: txt and csv.", style = "font-size: 1em"),
      
      shiny::br(),
      shinymaterial::material_button(input_id = "upload_file", label = "Upload", icon = NULL)
    )
  ),
  shinymaterial::material_side_nav_tab_content(
    side_nav_tab_id = "about",
    ui_about
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
             transition: none 0s ease 0s;
             background-color: rgba(249, 250, 253, 0.3);
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
  ),
  div(class = "footer",
      div(includeHTML("html/google_analytics.html"))
  )
)