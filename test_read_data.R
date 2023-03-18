library(tidyverse)

calc <- function(x) {
  return(((x - min(x))*(600-50)/max(x)-min(x)) + 50)
}

normalise <- function(x)
{
  return((x-min(x))/(max(x)-min(x)))
  
}

read_delim("E:\\000 Hareka\\03 Balikpapan Hack\\smoke_detection\\raw data\\sensing_data.txt", delim = "|", col_names = FALSE) %>%
  select(
    data = X2
  ) %>%
  filter(
    str_detect(data, "AIN")
  ) %>%
  mutate(
    data = str_replace_all(data, "[[:space:]]", ""),
    voltage = gsub("\\).*", "", gsub(".*\\(", "", data)),
    voltage = parse_number(voltage),
    ppm_h2 = calc(voltage)
  ) %>% View()
  glimpse()

  
