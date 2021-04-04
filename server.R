server <- function(input, output, session) {
  # Router pages
  router$server(input, output, session)
  
  split_server("t1")
  split_server("t2")
}