library(tidyverse)
library(rvest)

url <- "https://en.wikipedia.org/wiki/List_of_busiest_airports_by_passenger_traffic"
page <- read_html(url)

tables <- page %>%
  html_table(fill = TRUE)

airport_tables <- tables[1:6]
years <- 2025:2020

airport_data <- map2_dfr(airport_tables, years, ~{
  .x %>%
    rename_with(~ str_trim(.)) %>%
    rename_with(~ str_replace_all(., "\\[.*?\\]", "")) %>%
    select(contains("Airport"), contains("Passengers")) %>%
    rename(
      airport = 1,
      passengers = 2
    ) %>%
    mutate(
      year = .y,
      passengers = passengers %>%
        str_remove_all("\\[.*?\\]") %>%   
        str_remove_all(",") %>%           
        as.numeric()
    )
})

selected_airports <- c(
  "Hartsfield–Jackson Atlanta International Airport",
  "Frankfurt Airport",
  "Beijing Daxing International Airport",
  "Los Angeles International Airport",
  "Dubai International Airport",
  "Tokyo Haneda Airport"
)

airport_data_final <- airport_data %>%
  filter(airport %in% selected_airports) %>%
  select(airport, year, passengers) %>%
  arrange(airport, year)

airport_data_final



library(tidyverse)
library(knitr)

airport_table <- airport_data_final %>%
  mutate(
    passengers = format(passengers, big.mark = ",", scientific = FALSE)
  ) %>%
  arrange(desc(year), airport)

kable(
  airport_table,
  col.names = c("Airport", "Year", "Passengers"),
  caption = "Passenger Traffic for Six Major Airports, 2020-2025"
)

airport_data_final %>%
  ggplot(aes(x = year, y = passengers, color = airport)) +
  geom_line(size = 1) +
  geom_point(size = 2) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Passenger Traffic Trends for Six Major Airports (2020–2025)",
    x = "Year",
    y = "Number of Passengers",
    color = "Airport"
  ) +
  theme_minimal()

install.packages("gt")
library(tidyverse)
library(gt)

selected_airports <- c(
  "Hartsfield–Jackson Atlanta International Airport",
  "Frankfurt Airport",
  "Beijing Daxing International Airport",
  "Los Angeles International Airport",
  "Dubai International Airport",
  "Tokyo Haneda Airport"
)

airport_order <- c(
  "Hartsfield–Jackson Atlanta International Airport",
  "Frankfurt Airport",
  "Beijing Daxing International Airport",
  "Los Angeles International Airport",
  "Dubai International Airport",
  "Tokyo Haneda Airport"
)

airport_labels <- c(
  "Hartsfield–Jackson Atlanta International Airport" = "Hartsfield-Jackson Atlanta Intl",
  "Frankfurt Airport" = "Frankfurt Airport",
  "Beijing Daxing International Airport" = "Beijing Daxing Intl",
  "Los Angeles International Airport" = "Los Angeles Intl",
  "Dubai International Airport" = "Dubai Intl",
  "Tokyo Haneda Airport" = "Tokyo Haneda"
)

summary_table <- airport_data_final %>%
  mutate(
    airport = recode(
      airport,
      "Hartsfield–Jackson Atlanta International Airport" = "Hartsfield-Jackson Atlanta Intl",
      "Frankfurt Airport" = "Frankfurt Airport",
      "Beijing Daxing International Airport" = "Beijing Daxing Intl",
      "Los Angeles International Airport" = "Los Angeles Intl",
      "Dubai International Airport" = "Dubai Intl",
      "Tokyo Haneda Airport" = "Tokyo Haneda"
    ),
    year = factor(year, levels = 2020:2025)
  ) %>%
  pivot_wider(
    names_from = year,
    values_from = passengers
  ) %>%
  select(airport, `2020`, `2021`, `2022`, `2023`, `2024`, `2025`)

summary_table %>%
  gt() %>%
  tab_header(
    title = "Summary Table"
  ) %>%
  fmt_number(
    columns = -airport,
    decimals = 0,
    sep_mark = ","
  ) %>%
  sub_missing(
    columns = everything(),
    missing_text = "Not listed"
  ) %>%
  cols_label(
    airport = "Airport"
  ) %>%
  tab_style(
    style = list(
      cell_fill(color = "#1f4e79"),
      cell_text(color = "white", weight = "bold")
    ),
    locations = cells_column_labels(everything())
  ) %>%
  tab_style(
    style = cell_text(weight = "bold", size = px(28)),
    locations = cells_title(groups = "title")
  ) %>%
  cols_align(
    align = "center",
    columns = -airport
  ) %>%
  cols_align(
    align = "left",
    columns = airport
  ) %>%
  tab_options(
    table.width = pct(95),
    data_row.padding = px(8),
    column_labels.padding = px(10),
    table.font.size = px(14)
  )