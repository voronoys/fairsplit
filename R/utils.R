#' @title Cosine distance matrix
#' 
#' @param x matrix to calculate columns distance
#' 
#' @return Cosine distance matrix

cosine <- function(x) {
  dist_mat <- x/sqrt(rowSums(x*x))
  dist_mat <- as.dist(1 - dist_mat%*%t(dist_mat))
  
  return(dist_mat)
}

#' @title Objective function to minimize
#' 
#' @param data data.frame with ids in the rows and attributes in the columns
#' @param groups n_ids by n_teams matrix composed by zeros and ones
#' @param dist_metric Distance metric to compute the dissimilarities 
#' 
#' @return metric: the summary metric
#' @return means: attributes means by team
#' @return dist: distance matrix between teams

f_obj <- function(data, groups, dist_metric = "cosine") {
  means <- t(apply(X = groups, MARGIN = 2, FUN = function(x) colMeans(data[x == 1, ][-1])))
  means <- rbind(means, colMeans(means))
  
  rownames(means) <- c(paste0("Team ", 1:n_teams), "Overall")
  
  if(dist_metric == "cosine") dist_mat <- cosine(x = means)
  if(dist_metric == "euclidian") dist_mat <- dist(x = means)
  
  dist_mat <- as.matrix(dist_mat)
  out <- mean(dist_mat[nrow(dist_mat),]) + sd(dist_mat[nrow(dist_mat),])
  
  return(list(metric = out, means = means, dist = dist_mat))
}

#' @title Split individuals into fairly teams
#' 
#' @param data data.frame with ids in the rows and attributes in the columns
#' @param n_teams n_ids by n_teams matrix composed by zeros and ones
#' @param team_size Distance metric to compute the dissimilarities 
#' @param n_it Number of iterations
#' @param buffer Number of iterations to have just random samples
#' @param dist_metric Distance metric to compute the dissimilarities 
#' @param seed To make the results reproducible
#' 
#' @return best_setting: Best team configuration found
#' @return groups: Array containing all configurations
#' @return out: Individuals not included in any team (just if n_ids != n_teams*team_size)
#' @return probs: Array containing all probabilities during the optimization

split_team <- function(data, n_teams, team_size, n_it, buffer, dist_metric, seed = 1) {
  # Seed 
  set.seed(seed)
  
  # Preparing for the loop
  n_ids <- nrow(data)
  tol <- 10e-10
  
  groups <- probs <- array(NA, dim = c(n_ids, n_teams, n_it))
  ids <- 1:n_ids
  
  metric <- Inf
  metrics <- rep(NA, n_it)
  
  for(i in 1:n_it) {
    group_aux <- matrix(0, nrow = n_ids, ncol = n_teams)
    probs_aux <- matrix(1/n_teams, nrow = n_ids, ncol = n_teams)
    ids_aux <- ids
    
    for(j in sample(1:n_teams)) {
      if(i > buffer) {
        total <- rowSums(groups[, j, (i-buffer):(i-1)])
        probs_aux[, j] <- total/sum(total)
      }
      group_aux[sample(x = ids_aux, size = team_size, prob = probs_aux[ids_aux, j] + tol), j] <- 1
      
      ids_aux <- ids[-which(group_aux[, j] == 1)]
    }
    
    metric_i <- f_obj(data = data, groups = group_aux, dist_metric = dist_metric)$metric
    metrics[i] <- metric_i
    
    if(metric_i < metric) {
      metric <- metric_i
      groups[, , i] <- group_aux
      probs[, , i] <- probs_aux
    } else {
      groups[, , i] <- groups[, , (i-1)]
      probs[, , i] <- probs[, , (i-1)]
    }
  }
  
  out <- f_obj(data = data, groups = groups[, , i], dist_metric = dist_metric)
  out$groups <- apply(groups[, , i], 2, function(x) data[which(x == 1), 1])
  colnames(out$groups) <- paste("Team", 1:n_teams)
  
  return(list(best_setting = out, groups = groups, out = ids_aux, probs = probs))
}

#' @title Bar chart to display individuals attributes
#' 
#' @param label Label to place before the bar
#' @param width Bar width
#' @param height Bar height 
#' @param fill Color to fill the bar
#' @param background Bar's background color
#' 
#' @return barplot

bar_chart <- function(label, width = "100%", height = "12px", fill = "#fc5185", background = "#e1e1e1") {
  bar <- div(style = list(background = fill, width = width, height = height))
  chart <- div(style = list(flexGrow = 1, marginLeft = "8px", background = background), bar)
  div(style = list(display = "flex", alignItems = "center"), label, chart)
}

#' @title Stars to rate each individual
#' 
#' @param rating Value between 0 and max_rating
#' @param max_rating Maximum value
#' 
#' @return max_rating stars

rating_stars <- function(rating, max_rating = 5) {
  star_icon <- function(empty = FALSE) {
    tagAppendAttributes(
      shiny::icon("star"),
      style = paste("color:", if (empty) "#edf0f2" else "#ffd17c"),
      "aria-hidden" = "true"
    )
  }
  
  rounded_rating <- floor(rating + 0.5)
  stars <- lapply(seq_len(max_rating), function(i) {
    if (i <= rounded_rating) star_icon() else star_icon(empty = TRUE)
  })
  
  label <- sprintf("%s out of %s stars", rating, max_rating)
  div(title = label, role = "img", stars)
}

#' @title Attributes column definition
#' 
#' @param x Attribute columns
#' @param maxWidth Columns maxWidth
#' 
#' @return colDef for reactable

attr_column_def <- function(x, maxWidth = 120) {
  colDef(
    name = x,
    maxWidth = maxWidth, 
    align = "left", 
    aggregate = "mean",
    format = colFormat(digits = 2),
    cell = function(value) {
      width <- paste0(value / 10 * 100, "%")
      bar_chart(value, width = width, fill = "#764567", background = "#e1e1e1")
    },
    html = TRUE
  )
}

#' @title Theme for reactable (copied from https://glin.github.io/reactable/articles/spotify-charts/spotify-charts.html)
#' 
#' @return Theme for reactable

reactable_theme <- function() {
  search_icon <- function(fill = "none") {
    svg <- sprintf('<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24"><path fill="%s" d="M10 18c1.85 0 3.54-.64 4.9-1.69l4.4 4.4 1.4-1.42-4.39-4.4A8 8 0 102 10a8 8 0 008 8.01zm0-14a6 6 0 11-.01 12.01A6 6 0 0110 4z"/></svg>', fill)
    sprintf("url('data:image/svg+xml;base64,%s')", jsonlite::base64_enc(svg))
  }
  
  text_color <- "hsl(0, 0%, 95%)"
  text_color_light <- "hsl(0, 0%, 70%)"
  text_color_lighter <- "hsl(0, 0%, 55%)"
  bg_color <- "hsl(0, 0%, 10%)"
  
  reactableTheme(
    color = text_color,
    backgroundColor = bg_color,
    borderColor = "hsl(0, 0%, 16%)",
    borderWidth = "1px",
    highlightColor = "rgba(255, 255, 255, 0.1)",
    cellPadding = "10px 8px",
    style = list(
      fontFamily = "Work Sans, Helvetica Neue, Helvetica, Arial, sans-serif",
      fontSize = "14px",
      "a" = list(
        color = text_color,
        "&:hover, &:focus" = list(
          textDecoration = "none",
          borderBottom = "1px solid currentColor"
        )
      ),
      ".number" = list(
        color = text_color_light,
        fontFamily = "Source Code Pro, Consolas, Monaco, monospace"
      ),
      ".tag" = list(
        padding = "2px 4px",
        color = "hsl(0, 0%, 40%)",
        fontSize = "12px",
        border = "1px solid hsl(0, 0%, 24%)",
        borderRadius = "2px"
      )
    ),
    headerStyle = list(
      color = text_color_light,
      fontWeight = 400,
      fontSize = "12px",
      letterSpacing = "1px",
      textTransform = "uppercase",
      "&:hover, &:focus" = list(color = text_color)
    ),
    rowHighlightStyle = list(
      ".tag" = list(color = text_color, borderColor = text_color_lighter)
    ),
    searchInputStyle = list(
      paddingLeft = "30px",
      paddingTop = "8px",
      paddingBottom = "8px",
      width = "100%",
      border = "none",
      backgroundColor = bg_color,
      backgroundImage = search_icon(text_color_light),
      backgroundSize = "16px",
      backgroundPosition = "left 8px center",
      backgroundRepeat = "no-repeat",
      "&:focus" = list(backgroundColor = "rgba(255, 255, 255, 0.1)", border = "none"),
      "&:hover, &:focus" = list(backgroundImage = search_icon(text_color)),
      "::placeholder" = list(color = text_color_lighter),
      "&:hover::placeholder, &:focus::placeholder" = list(color = text_color)
    ),
    paginationStyle = list(color = text_color_light),
    pageButtonHoverStyle = list(backgroundColor = "hsl(0, 0%, 20%)"),
    pageButtonActiveStyle = list(backgroundColor = "hsl(0, 0%, 24%)")
  )
}
