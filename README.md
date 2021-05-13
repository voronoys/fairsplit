
# FairSplit

## Links

-   Live version: [FairSplit - Live
    app](https://voronoys.shinyapps.io/fairsplit/)
-   RStudio cloud: [FairSplit - RStudio
    cloud](https://rstudio.cloud/project/2544357)
-   GitHub: [FairSplit - Github](https://github.com/voronoys/fairsplit)

## About the app

Wouldn’t it be nice to have an approach to fairly split teams? We did
it!

## Quick reading: Highlights

Soccer is the most popular sport in Brazil, and before every
(non-professional) match, an important task is required: **split the teams in equal size, and hopefully in balanced power**. 
A common strategy to do it is to choose as many captains as the number of teams. Next, the captains have to select their teams based on their previous knowledge about the players’ skills. The dynamic of picking the players start with one of these captains selecting one player among all available ones. After that,  the next captain picks a player to his/her team. The dynamic keeps going until all the players are designated to a team.

Usually, the last captain has a weaker team as the other captains have
already selected the best players before. Also, the ‘best player’ can be
someone good in one specific position (defence or attack), and the concept itself is entirely subjective. The same situation is rapidly applicable to other sports such as volleyball, handball, basketball, eSports, etc. However, the task of creating teams is not just applied to sports. It is common to have teams in a company, for example. In such a case, the teams are defined based on the needs of each project.

<center>
<img src="docs/radar.png"></img>
</center>

## Algorithm

We have implemented a simple and useful iterative method to generate team splitting fairly. Our approach is based on each person's attributes, ensuring that the overall teams' metrics are similar. First, the method starts breaking the teams randomly and then computes the teams' similarity. The next step is to arrange the teams in a new configuration seeking the maximum similarity between them. Finally, the algorithm keeps looking for the best splitting configuration and chooses the one arrangement that maximizes the similarity.

As a result, we have competitive teams with similar characteristics
which can ensure a more enjoyable matches.

In our app the user can specify algorithm parameters:

-   Number of iterations
-   Number of teams
-   Size of each team.

<center>
<img src="docs/f_obj.png"></img>
</center>

## Examples

-   Nossa Pelada:

This example is based on a weekly match we usually had (before COVID-19
era) in Belo Horizonte, Brazil. People and attributes are real and based
on my perception.

-   Fifa:

This example is based on FIFA 20 scouts. To make it simple we only
selected players from: Barcelona, Juventus, Paris Saint-Germain, Real
Madrid, Manchester City and Liverpool. Also we only selected midfielders
and attacking players. <br> Source:
<https://www.kaggle.com/stefanoleone992/fifa-20-complete-player-dataset?select=players_20.csv>

-   Pokémon:

We used the Pokémon dataset in the highcharts package. It has several
Pokémons and some characteristics.

Source:
<https://github.com/jbkunst/highcharter/blob/master/data/pokemon.rda>

-   Company:

Some data science skills from people in my company.

-   Rstudio:

A fake dataset simulating how we could split the RStudio team based on
their knowledge about some R packages. The attributes are completely
random.

-   Upload your own data:

Try yourself! <br> Download our template and fill it with your data and
split your teams.

## Preview

<center>
<img src="docs/video.gif"></img>
</center>
