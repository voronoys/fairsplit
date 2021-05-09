ui_about <- shiny::tagList(
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
            class = "about",
            "Soccer is the most popular sport in Brazil. Commonly a group of people go to a field to play soccer 
            and at the very beginning, a task is necessary: split the teams. A common way to split the team is to 
            choose as many people as the number of teams. Let's call them captains. They have the role to select 
            the team based on the previous knowledge about the skills of the players. Then one of these people will 
            start selecting their team by choosing one person among all available people. After that, it is time 
            for the next captain to start selecting their team. Again another player is selected among all available players. 
            The algorithm keeps going until all the players are allocated to a team."
          ),
          shiny::br(),
          shiny::p(
            class = "about",
            "Usually the last capitain have the less strong team as the others will select the best players first. 
            Also, the 'best player' may be someone good in one specific task and it is completely subjective. The same situation
            is rapidly applied for other sports as voleiball, handeball, basket and so on. However, the task of create teams is
            not just applied for sports. It is common to have teams in a company, for example. In such case, the teams are defined 
            based on the necessity of each employee profile for a determined project."
          ),
          shiny::br(),
          shiny::p(
            class = "about",
            "Wouldn't be nice to have an approach able to split the teams based on the individuals skills? For each individual,
            a set of attributes are collected and, based on the attributes, a set of teams are created in which the 
            overall teams metrics are similar. To achieve such algorithm we implemented an iterative method. First, individuals are selected for each team and
            then the simmilarity between teams is calculated. Then new configurations are proposed and we keep that which
            the simmilarity is bigger (and the dissimilarity is small)."
          ),
          shiny::br(),
          shiny::p(
            class = "about",
            "For each team, we calculate the mean and standard deviation for each attribute. Then, based on these metrics
            we try to minimize the distance between means and stardards deviations."
          ),
        )
      )
    )
  )
)