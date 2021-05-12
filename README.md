
# FairSplit

## About the app

**FairSplit**: Wouldn’t it be nice to have an approach to fairly split
teams? We did it!.

## Links

-   Live version: [FairSplit - Live
    app](https://voronoys.shinyapps.io/fairsplit/)
-   RStudio cloud: [FairSplit - RStudio
    cloud](https://rstudio.cloud/project/2544357)
-   GitHub: [FairSplit - Github](https://github.com/voronoys/fairsplit)

## Quick reading: Highlights

Soccer is the most popular sport in Brazil and before every
(non-professional) match, a task is necessary: split the teams. A common
way to do it is to choose as many captains as the number of teams. They
have the role to select their teams based on their previous knowledge
about the players’ skills. The algorithm starts with one of these
captains selecting one player among all available ones. After that, it
is time for the next captain to start selecting their team and again
another player is selected among all available players. The algorithm
keeps going until all the players are allocated to a team.

Usually, the last captain has a less strong team as the others captains
have already selected the best players before. Also, the ‘best player’
can be someone good in one specific position and the concept itself is
completely subjective. The same situation is rapidly applicable to other
sports as volleyball, handball, basketball and so on. However, the task
of creating teams is not just applied to sports. It is common to have
teams in a company, for example. In such a case, the teams are defined
based on the needs of each project and as a consequence their allocated
employees’ skills.

## Algorithm

We implemented a simple and useful iterative method. For each
individual, a set of attributes is collected, and, based on them, teams
are created ensuring that the overall teams’ metrics are similar. To do
so, individuals are splitted into teams and teams’ similarity is
calculated. After this, new settings are proposed and we keep the one in
which the similarity is the biggest.

As a result, we have competitive teams with similar characteristics
which can ensure a more enjoyable match.

## Examples

-   Nossa Pelada:

-   Fifa:

-   Pokémon:

-   Company:

-   Rstudio:

-   Upload your own data:
