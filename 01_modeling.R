#' Smoke Detector Prediction for Fire Alarm


# load library ------------------------------------------------------------

library(tidyverse)
library(caret)
library(rpart.plot)
library(odbc)
library(RPostgres)

# read data & wrangling ---------------------------------------------------

#' Open connection to database

pg_con <- dbConnect(
  Postgres(),
  host = "rosie.db.elephantsql.com",
  port = 5432,
  dbname = "qnkipzon",
  user = "qnkipzon",
  password = "K-BYc1HQmPQKLHGGiJquQNWGcluKKuZ0"
)

dbListTables(pg_con) # check tables in database

# query database
res <-
dbSendQuery(
  pg_con,
  'SELECT * FROM smoke_detection'
)

raw_data <- dbFetch(res) # create data table in R from database

dbClearResult(res)

# Close connection with PostGreSQL
dbDisconnect(pg_con)

glimpse(raw_data)


# data processing ---------------------------------------------------------

raw_data %>%
  select(-c(index, cnt)) %>%
    mutate(
      fire_alarm = factor(fire_alarm)
    ) %>%
  glimpse() -> raw_df

# check missing data
summary(raw_df)

raw_df %>%
  summarise_all(~ sum(is.na(.))) # no dataset has missing data