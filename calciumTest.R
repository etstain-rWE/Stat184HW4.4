library(tidyverse)

calcium <- read.csv("calcium.csv", header = TRUE)

calcium <- calcium %>%
  mutate(subject_id = row_number())

colnames(calcium) <- c(
  "control_0","control_1","control_2","control_3",
  "treat_0","treat_1","treat_2","treat_3",
  "subject_id"
)


calcium_long <- calcium %>%
  pivot_longer(
    cols = -subject_id,
    names_to = c("group","year"),
    names_sep = "_",
    values_to = "calcium"
  ) %>%
  mutate(
    group = if_else(group == "control", "Control", "Treatment"),
    year = as.numeric(year)
  )

calcium_long %>%
  group_by(group, year) %>%
  summarise(mean_calcium = mean(calcium, na.rm = TRUE)) %>%
  ggplot(aes(x = year, y = mean_calcium, color = group)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  labs(
    title = "Mean Calcium Levels Over Time",
    x = "Year",
    y = "Calcium Level"
  ) +
  theme_minimal()

ggplot(calcium_long, aes(x = year, y = calcium, group = subject_id)) +
  geom_line(alpha = 0.3) +
  facet_wrap(~group) +
  theme_minimal()

ggplot(calcium_long, aes(x = factor(year), y = calcium, fill = group)) +
  geom_boxplot() +
  labs(x = "Year", y = "Calcium") +
  theme_minimal()
