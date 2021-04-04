ui <- semanticPage(
  title = "Fairly teams",
  tags$head(
    tags$link(rel="stylesheet", href="styles.css", type="text/css" )
  ),
  horizontal_menu(
    list(
      list(name = "Splitting teams", link = route_link("splitting"), icon = "running"),
      list(name = "Stats", link = route_link("stats"), icon = "globe europe")
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