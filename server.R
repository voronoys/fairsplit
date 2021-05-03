server <- function(input, output, session) {
  # Router pages
  # router$server(input, output, session)
  
  # Home
  source("tabs/server_home.R", local = TRUE)
  
  # Split
  source("tabs/server_split.R", local = TRUE)
}