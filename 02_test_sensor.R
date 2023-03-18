#### Read and Append sensor data in Google drive or database
#### secondary plan due to unsuccessful telemetry system

# load library ------------------------------------------------------------

library(tidyverse)
library(googledrive)
library(httr)
library(googlesheets4)

# read data from gdrive ---------------------------------------------------

# Authenticate with Google Drive API
gs4_auth()

# Download the file from Google Drive
# temp_file <- tempfile()
# drive_download("~/DB_Smoke/db_ppm/PPM_DB.xlsx", path = temp_file)

sheet <- gs4_get("17hO1dIDPxdeKR5NEoPdn6wqeUpTRsXX2imEZ6ps6F7I")
data <- read_sheet(sheet, col_names = FALSE)

# function to compare voltage to CO2 PPM
# calc <- function(x) {
#   return(((x - min(x))*(600-50)/max(x)-min(x)) + 50)
# }


# read_delim(temp_file, delim = "|", col_names = FALSE) %>%
#   select(
#     data = X2
#   ) %>%
#   filter(
#     str_detect(data, "AIN")
#   ) %>%
#   mutate(
#     data = str_replace_all(data, "[[:space:]]", ""),
#     voltage = gsub("\\).*", "", gsub(".*\\(", "", data)),
#     voltage = parse_number(voltage),
#     co2 = calc(voltage)
#   ) %>% glimpse() -> data_sensor

data %>%
  select(
    UTC = `...1`,
    co2 = `...2`
  ) -> data_sensor

# processing data ---------------------------------------------------------

now <- Sys.time()

num_rows <- nrow(data_sensor)

data_sensor %>%
  mutate(
    CreatedAt = as_datetime(UTC, format = "%B %d, %Y at %I:%M%p"),
    temp_c = sample(sample(seq(from = 18, to = 60, by = 0.001), size = num_rows), replace=TRUE),
    humidity = sample(sample(seq(from = 10, to = 100, by = 0.01), size = num_rows), replace=TRUE),
    tvoc = sample(sample(seq(from = 0, to = 60000, by = 1), size = num_rows), replace=TRUE),
    h2 = sample(sample(seq(from = 10000, to = 14000, by = 1), size = num_rows), replace=TRUE),
    ethanol = sample(sample(seq(from = 15000, to = 22000, by = 1), size = num_rows), replace=TRUE),
    pressure = sample(sample(seq(from = 931, to = 939, by = 0.001), size = num_rows), replace=TRUE),
    pm1 = sample(sample(seq(from = 0, to = 13000, by = 0.01), size = num_rows), replace=TRUE),
    pm2_5 = sample(sample(seq(from = 0, to = 13000, by = 0.01), size = num_rows), replace=TRUE),
  ) %>% glimpse() -> df_sensor


# create prediction -------------------------------------------------------

# using random forest model

model_rf <- readRDS(here::here("finalModel_rf.rds"))

df_sensor %>%
  select(-c(CreatedAt, UTC)) %>%
  glimpse() -> pred_df

pred_fire <- predict(model_rf, pred_df)

df_sensor %>%
  mutate(fire_alarm = pred_fire) -> df_predicted

# write data --------------------------------------------------------------
# Authenticate with Google Drive API
drive_auth()

# Define the name of the Google Sheets file and the folder ID
folder_id <- "1jU5SuhAkHMNno1Fx-XqgJx26PBdABCW5"

# Write the data frame to a temporary file
temp_file <- tempfile()
write.csv(df_predicted, file = temp_file, row.names = FALSE)

# Upload the file to Google Drive and add it to the target folder
drive_upload(temp_file, name = "pred_fire.csv", type = "csv", parents = folder_id, overwrite = TRUE)
