install.packages("patchwork")
library(tidyverse)
library(patchwork)

df_value <- 5
x_min <- 0
x_max <- 20
y_min <- 0
y_max <- 0.16
rectangle_area <- (x_max - x_min) * (y_max - y_min)
mc_simulation <- function(n, x_min, x_max, y_min, y_max) {
  data.frame(
    x = runif(n, min = x_min, max = x_max),
    y = runif(n, min = y_min, max = y_max)
  )
}
make_mc_plot <- function(n_value) {
  sim_data <- mc_simulation(
    n = n_value,
    x_min = x_min,
    x_max = x_max,
    y_min = y_min,
    y_max = y_max
  )
  
  sim_results <- sim_data %>%
    mutate(
      f_x = dchisq(x, df = df_value),
      flag = if_else(y <= f_x, "on/below", "above")
    )
  
  estimated_integral <- sim_results %>%
    summarize(
      p = mean(flag == "on/below"),
      estimate = p * rectangle_area
    ) %>%
    pull(estimate)
  
  ggplot(sim_results, aes(x = x, y = y, color = flag)) +
    geom_point(alpha = 0.6, size = 1) +
    stat_function(
      fun = dchisq,
      args = list(df = df_value),
      linewidth = 1,
      color = "blue",
      inherit.aes = FALSE,
      aes(x = x)
    ) +
    coord_cartesian(xlim = c(0, 20), ylim = c(0, 0.16)) +
    labs(
      title = paste("Monte Carlo Integration, n =", n_value),
      subtitle = paste("Estimated Integral =", round(estimated_integral, 4)),
      x = "x",
      y = "y",
      color = "flag"
    ) +
    theme_minimal()
}

plot10 <- make_mc_plot(10)
plot100 <- make_mc_plot(100)
plot1000 <- make_mc_plot(1000)
plot10000 <- make_mc_plot(10000)

plot10 + plot100 + plot1000 + plot10000