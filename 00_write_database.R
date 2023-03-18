#' Smoke Detector Prediction for Fire Alarm


# load library ------------------------------------------------------------

library(tidyverse)
library(caret)
library(odbc)
library(RPostgres)
library(RSQLite)

# read data & wrangling ---------------------------------------------------

read_csv("./raw data/smoke_detection_iot.csv") %>%
  mutate(
    index = `...1`,
    UTC = as_datetime(UTC)
  ) %>% 
  select(-`...1`) %>%
  glimpse() -> raw_df

#' Open connection to database

pg_con <- dbConnect(
  Postgres(),
  host = "rosie.db.elephantsql.com",
  port = 5432,
  dbname = "qnkipzon",
  user = "qnkipzon",
  password = "K-BYc1HQmPQKLHGGiJquQNWGcluKKuZ0"
)



dbListTables(pg_con)

# write data to database
# write raw data into database
dbWriteTable(
  pg_con,
  name = "smoke_detection",
  value = raw_df,
  overwrite = TRUE,
  temporary = FALSE
)


# drop table

# dbRemoveTable(
#   pg_con,
#   name = "smoke_predict_knn"
# )

# Close connection with PostGreSQL
dbDisconnect(pg_con)
