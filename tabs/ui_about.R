ui_about <- shiny::tagList(
  shinymaterial::material_row(
    shinymaterial::material_column(
      width = 8, offset = 2, 
      material_card(
        title = "About",
        shinymaterial::material_row(
          shinymaterial::material_column(
            width = 10, offset = 1, 
            title = "About FairSplit",
            includeMarkdown("docs/about.md"),
            br()
          )
        )
      )
    )
  )
)