library(tidyverse)
source("code/helper-functions.R")


### Load and manage the mortality tracker data 
deathDF <- readxl::read_excel("data/mortality_data.xlsx")

# Character to date
deathDF$tracker_date <- dmy(deathDF$tracker_date)
deathDF$report_date <- dmy(deathDF$report_date)

# NA counts to "at least" 0
deathDF$g_dead_women[is.na(deathDF$g_dead_women)] <- 0
deathDF$g_dead_child[is.na(deathDF$g_dead_child)] <- 0

# Model the death count for days without updates
# Calculate the deaths on each day as the difference between one day and the day before
deathDF$g_dailydead_total <- c(deathDF$g_dead_total[1], diff(deathDF$g_dead_total))
# For days with zero daily difference, model the daily deaths
deathDF$mg_dailydead_total <- model_0s(deathDF$g_dailydead_total)
# Calculate the cumulative sum of deaths
deathDF$mg_dead_total <- cumsum(deathDF$mg_dailydead_total)

## Model the child deaths (this is an "at least figure")
# Step 1: Model the proportion of dead each day who are children
deathDF$mg_prop_childdeaths <- model_missing_proportions(deathDF$g_dead_child, deathDF$mg_dead_total)
# Step 2: multiply the proportion by the total dead to estimate child daily deaths
deathDF$mg_dead_child <- deathDF$mg_prop_childdeaths * deathDF$mg_dead_total
# Step 3: Model daily child deaths
deathDF$mg_daily_childdeaths <- c(deathDF$mg_dead_child[1], diff(deathDF$mg_dead_child) )

## Model the women deaths (this is an "at least figure")
# Step 1: Model the proportion of dead each day who are women
deathDF$mg_prop_womendeaths <- model_missing_proportions(deathDF$g_dead_women, deathDF$mg_dead_total)
# Step 2: multiply the proportion by the total dead to estimate women daily deaths
deathDF$mg_dead_women <- deathDF$mg_prop_womendeaths * deathDF$mg_dead_total
# Step 3: Model daily women deaths
deathDF$mg_daily_womendeaths <- c(deathDF$mg_dead_women[1], diff(deathDF$mg_dead_women) )

# Clean up
rm(list = c("lininterpol", "model_0s", "model_missing_proportions"))







