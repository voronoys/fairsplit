ui <- shiny.semantic::semanticPage(
  title = "Fair teams",
  theme = "darkly",
  tags$head(
    tags$link(rel="stylesheet", href="styles.css", type="text/css"),
    tags$script( # https://stackoverflow.com/questions/56770222/get-the-event-which-is-fired-in-shiny
      "$(document).on('shiny:inputchanged', function(event) {
          if (event.name != 'changed') {
            Shiny.setInputValue('changed', event.name);
          }
        });"
    )
  ),
  shiny.semantic::horizontal_menu(
    list(
      list(name = "Home", link = shiny.router::route_link("home"), icon = "globe europe"),
      list(name = "Teams", link = shiny.router::route_link("teams"), icon = "running")
    ),
  ),
  router$ui, 
  tags$footer(
    "Created by Voronoys", 
    align = "center", 
    style = "position:fixed;
             bottom:0;
             right:0;
             left:0;
             background: #313131;
             color: white;
             padding:20px;
             box-sizing:border-box;
             z-index: 1000;
             text-align: left"
  ),
  tags$footer(
    a(href = "https://github.com", icon("github"), style = "color: white"), 
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