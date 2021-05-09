#' @title Cosine weighted distance matrix
#' 
#' @param x matrix to calculate columns distance
#' @param weights Weights for each attribute in the dataset
#' 
#' @return Cosine distance matrix

cosine <- function(x, weights) {
  weights <- matrix(rep(weights, nrow(x)), ncol = ncol(x))
  dist_mat <- (x*weights)/sqrt(rowSums(x*x*weights))
  dist_mat <- as.dist(1 - dist_mat%*%t(dist_mat))
  
  return(dist_mat)
}

#' @title Euclidean weighted distance matrix
#' 
#' @param x matrix to calculate columns distance
#' @param weights Weights for each attribute in the dataset
#' 
#' @return Euclidean distance matrix

euclidean <- function(x, weights) {
  comps <- expand.grid(1:nrow(x), 1:nrow(x))
  dist_vec <- mapply(function(i,j) sqrt(sum((weights*(x[i,] - x[j,]))^2)), comps[, 1], comps[, 2])
  dist_mat <- as.dist(matrix(dist_vec, nrow(x), nrow(x)))
  
  return(dist_mat)
}

#' @title Objective function to minimize
#' 
#' @param data data.frame with ids in the rows and attributes in the columns
#' @param groups n_ids by n_teams matrix composed by zeros and ones
#' @param weights Weights for each attribute in the dataset
#' @param dist_metric Distance metric to compute the dissimilarities 
#' 
#' @return metric: the summary metric
#' @return means: attributes means by team
#' @return dist: distance matrix between teams

f_obj <- function(data, groups, weights = 1, dist_metric = "cosine") {
  means <- t(apply(X = groups, MARGIN = 2, FUN = function(x) colMeans(data[x == 1, ][-1])))
  means <- rbind(means, colMeans(means))
  means <- rbind(means, colMeans(data[rowSums(groups) == 0, -1]))
  
  n_teams <- (nrow(means)-2)
  rownames(means) <- c(paste0("Team ", 1:n_teams), "Overall", "Out")
  
  if(as.character(dist_metric) == "cosine") dist_mat <- cosine(x = means[1:(n_teams + 1), ], weights = weights)
  if(as.character(dist_metric) == "euclidian") dist_mat <- euclidean(x = means[1:(n_teams + 1), ], weights = weights)
  
  dist_mat <- as.matrix(dist_mat)
  out <- mean(x = dist_mat[nrow(dist_mat), ]) + sd(dist_mat[nrow(dist_mat), ])
  
  return(list(metric = out, means = means, dist = dist_mat))
}

#' @title Split individuals into fair teams
#' 
#' @param data data.frame with ids in the rows and attributes in the columns
#' @param n_teams n_ids by n_teams matrix composed by zeros and ones
#' @param team_size Distance metric to compute the dissimilarities 
#' @param weights Weights for each attribute in the dataset
#' @param n_it Number of iterations
#' @param buffer Number of iterations to have just random samples
#' @param dist_metric Distance metric to compute the dissimilarities 
#' @param seed To make the results reproducible
#' 
#' @return best_setting: Best team configuration found
#' @return groups: Array containing all configurations
#' @return out: Individuals not included in any team (just if n_ids != n_teams*team_size)
#' @return probs: Array containing all probabilities during the optimization

split_team <- function(data, n_teams, team_size, weights, n_it, buffer, dist_metric, seed = 4815162342) {
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
      samp <- sample(x = ids_aux, size = team_size, prob = probs_aux[ids_aux, j] + tol)
      group_aux[samp, j] <- 1
      
      ids_aux <- ids_aux[!ids_aux %in% samp]
    }
    
    metric_i <- f_obj(data = data, groups = group_aux, weights = weights, dist_metric = dist_metric)$metric
    
    if(metric_i < metric) {
      metric <- metric_i
      metrics[i] <- metric_i
      groups[, , i] <- group_aux
      probs[, , i] <- probs_aux
    } else {
      metrics[i] <- metric
      groups[, , i] <- groups[, , (i-1)]
      probs[, , i] <- probs[, , (i-1)]
    }
  }
  
  out <- f_obj(data = data, groups = groups[, , i], weights = weights, dist_metric = dist_metric)
  out$groups <- apply(groups[, , i], 2, function(x) data[which(x == 1), 1])
  colnames(out$groups) <- paste("Team", 1:n_teams)
  
  return(
    list(
      best_setting = out, 
      without_team = subset(data, !id %in% out$groups)[, 1],
      groups = groups, 
      out = ids_aux, 
      probs = probs,
      metrics = metrics,
      dist_mat = out$dist
    )
  )
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
  bar <- shiny::div(style = list(background = fill, width = width, height = height))
  chart <- shiny::div(style = list(flexGrow = 1, marginLeft = "8px", background = background), bar)
  shiny::div(style = list(display = "flex", alignItems = "center"), label, chart)
}

#' @title Stars to rate each individual
#' 
#' @param rating Value between 0 and max_rating
#' @param max_rating Maximum value
#' 
#' @return max_rating stars

rating_stars <- function(rating, max_rating = 5) {
  star_icon <- function(half = FALSE, empty = FALSE) {
    if(half) {
      htmltools::tagAppendAttributes(
        shiny::icon("star-half-alt"), style = paste("color:", if (empty) "#edf0f2" else "#ffd17c"), "aria-hidden" = "true"
      )
    } else {
      htmltools::tagAppendAttributes(
        shiny::icon("star"), style = paste("color:", if (empty) "#edf0f2" else "#ffd17c"), "aria-hidden" = "true"
      )
    }
  }
  
  full_star <- round(rating)
  half_star <- as.integer((rating - full_star) > 0)
  empty_star <- max_rating - full_star - half_star
  
  stars <- lapply(
    seq_len(max_rating), 
    function(i) {
      if(i <= full_star) {
        star_icon() 
      } else if(i <= full_star + half_star) {
        star_icon(half = TRUE)
      } else {
        star_icon(empty = TRUE)
      }
    }
  )
  
  label <- sprintf("%s out of %s stars", rating, max_rating)
  shiny::div(title = label, role = "img", stars)
}

#' @title Attributes column definition
#' 
#' @param x Attribute columns
#' @param maxWidth Columns maxWidth
#' 
#' @return colDef for reactable

attr_column_def <- function(x, max) {
  reactable::colDef(
    name = x, 
    align = "center", 
    minWidth = 130,
    maxWidth = 500,
    aggregate = "mean",
    format = reactable::colFormat(digits = 2),
    cell = function(value) {
      width <- paste0(round((value/max) * 100, 2), "%")
      bar_chart(formatter(value), width = width, fill = "#764567", background = "#e1e1e1")
    },
    html = TRUE,
    style = "display: 'flex'; flexDirection: 'column'; justifyContent: 'center'"
  )
}

#' @title Find the next beauty number (under my definition of beauty)
#' 
#' @param x A number
#' 
#' @return Next beauty number

next_beauty_number <- function(num) {
  num <- round(num)
  num <- num - 1
  order <- 10^(nchar(num) - 1)
  
  fd <- as.integer(num/order)
  sd <- as.integer((num - fd*order)/(order/10))
  
  if(order < 100) {
    possibilities <- c(1, 3, 5, 10, 15, 25, 50, 75, 100)
    beauty_number <- possibilities[num+1 <= possibilities][1]
    
    fd <- as.integer(beauty_number/order)
    sd <- as.integer((beauty_number - fd*order)/(order/10))
  } else if(sd >= 5) {
    sd <- 0
    fd <- fd + 1
  } else {
    sd <- 5
  }
  
  beauty_number <- fd*order + sd*(order/10)
  
  return(beauty_number)  
}

#' @title Format numbers to display
#' 
#' @param x A data.frame column
#' 
#' @return Formated number

formatter <- function(x) {
  dplyr::case_when(
    x < 1e3 ~ as.character(round(x)),
    x < 1e6 ~ paste0(as.character(round(x/1e3, 1)), "K"),
    x < 1e9 ~ paste0(as.character(x/1e6, 1), "M"),
    x < 1e12 ~ paste0(as.character(x/1e9, 1), "B"),
    TRUE ~ as.character(x)
  )
}

#' @title Radar plot
#'
#' @param data data.frame with the first column storing the attributes, and the other columns with values to be visualized.
#' @param cols column names used to plot the radar
#' @param theme see \code{\link[echarts4r]{e_theme}}
#'
#' @import echarts4r
#' @return

plot_radar <- function(data, name_col = "name", cols, theme = "roma") {
  data_plot <- data %>%
    dplyr::select(!!name_col, !!cols)
  
  p_base <- data_plot %>% 
    echarts4r::e_charts(name) 
  
  max_rate <- next_beauty_number(num = max(data[, -1]))
  
  for(i in seq_along(cols)) {
    p_base <- p_base %>%
      echarts4r::e_radar_(
        serie = names(data_plot)[-1][i], 
        max = max_rate,
        name = names(data_plot)[-1][i]
      ) 
  }
  
  p_final <- p_base %>%
    echarts4r::e_tooltip(trigger = "item") %>%
    echarts4r::e_labels(show = FALSE, position = "top") %>%
    echarts4r::e_theme(theme)
  
  return(p_final)  
}

#' @title Scale a number to 0-1 scale
#'
#' @param x a number between min and max
#' @param min minimum value in the scale
#' @param max maximum value in the scale
#'
#' @return the number in the 0-1 scale

to_01 <- function(x, min = 0, max = 1) {
  if(any(x < min) | any(x > max)) stop("The number must be something between min and max")
  out <- (x-min)/(max-min)
  
  return(out)
}

#' @title Rescale a number to min-max scale
#'
#' @param x a number between 0 and 1
#' @param min minimum value in the scale
#' @param max maximum value in the scale
#'
#' @return the number in the min-max scale

to_minmax <- function(x, min = 0, max = 1) {
  if(x < 0 | x > 1) stop("The number must be something between 0 and 1")
  out <- (max-min)*x + min
  
  return(out)
}

#' @title Theme for reactable (copy from https://glin.github.io/reactable/articles/spotify-charts/spotify-charts.html)
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
  
  reactable::reactableTheme(
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
      "&:focus" = list(backgroundColor = "#3c4e82", border = "none"),
      "&:hover, &:focus" = list(backgroundImage = search_icon(text_color)),
      "::placeholder" = list(color = text_color_lighter),
      "&:hover::placeholder, &:focus::placeholder" = list(color = text_color)
    ),
    paginationStyle = list(color = text_color_light),
    pageButtonHoverStyle = list(backgroundColor = "hsl(0, 0%, 20%)"),
    pageButtonActiveStyle = list(backgroundColor = "hsl(0, 0%, 24%)")
  )
}

#' @title Box for the examples
#' 
#' @return Box in HTML format

tab_voronoys <- function(text, text_color, background_color, icon, id) {
  shiny::HTML(
    paste0(
      '<a id="', id, '" href="#" class="action-button" style="margin-left: 5px; margin-right: 5px">
       <div class = "voronoys-block" style = "background-color:', background_color, ';"> 
          <span class = "name" style = "color:', text_color, '">', text, '</span>
          <div class="img_block">
             <div class="img_block_conteiner">
                <img src="img/', icon,'" style="width: 6em; margin: 10px 10px 10px 20px; opacity: 0.9;">
             </div>
          </div>
       </div></a>'
    )
  )
}


fileInput2 <- function(inputId, label = NULL, accept = NULL, width = NULL, 
                       buttonLabel = "Browse...", placeholder = "No file selected") {
  
  restoredValue <- restoreInput(id = inputId, default = NULL)
  
  if (!is.null(restoredValue) && !is.data.frame(restoredValue)) {
    warning("Restored value for ", inputId, " has incorrect format.")
    restoredValue <- NULL
  }
  
  if (!is.null(restoredValue)) {
    restoredValue <- toJSON(restoredValue, strict_atomic = FALSE)
  }
  
  inputTag <- tags$input(
    id = inputId, 
    name = inputId, 
    type = "file", 
    style = "position: absolute !important; top: -99999px !important; left: -99999px !important;", 
    `data-restore` = restoredValue
  )
  
  if (length(accept) > 0) 
    inputTag$attribs$accept <- paste(accept, collapse = ",")
  
  div(
    class = "form-group shiny-input-container", 
    div(
      class = "input-group", 
      tags$label(
        class = "input-group-btn input-group-prepend",
        span(
          "",
          inputTag
        )
      ),
      tags$input(
        type = "text",
        class = "form-control", 
        style = "border: 1px dotted rgba(0,0,0,0.42) !important; padding: 10px !important;", 
        placeholder = placeholder, 
        readonly = "readonly"
        )
    ), 
    tags$div(
      id = paste(inputId, "_progress", sep = ""), 
      class = "progress active shiny-file-input-progress", 
      tags$div(class = "progress-bar")
    )
  )
}