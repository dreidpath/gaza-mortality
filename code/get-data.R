library(tidyverse)
source("code/helper-functions.R")

dDF <- readxl::read_excel("data/raw_data.xlsx")

# Character to date
dDF$tracker_date <- dmy(dDF$tracker_date)
dDF$report_date <- dmy(dDF$report_date)

# NA counts to "at least" 0
dDF$g_dead_women[is.na(dDF$g_dead_women)] <- 0
dDF$g_dead_child[is.na(dDF$g_dead_child)] <- 0

# Model the death count for days without updates
# Calculate the deaths on each day as the difference between one day and the day before
dDF$g_dailydead_total <- c(dDF$g_dead_total[1], diff(dDF$g_dead_total))
# For days with zero daily difference, model the daily deaths
dDF$mg_dailydead_total <- model_0s(dDF$g_dailydead_total)
# Calculate the cumulative sum of deaths
dDF$mg_dead_total <- cumsum(dDF$mg_dailydead_total)

## Model the child deaths (this is an "at least figure")
# Step 1: Model the proportion of dead each day who are children
dDF$mg_prop_childdeaths <- model_missing_proportions(dDF$g_dead_child, dDF$mg_dead_total)
# Step 2: multiply the proportion by the total dead to estimate child daily deaths
dDF$mg_dead_child <- dDF$mg_prop_childdeaths * dDF$mg_dead_total

## Model the women deaths (this is an "at least figure")
# Step 1: Model the proportion of dead each day who are women
dDF$mg_prop_womendeaths <- model_missing_proportions(dDF$g_dead_women, dDF$mg_dead_total)
# Step 2: multiply the proportion by the total dead to estimate women daily deaths
dDF$mg_dead_women <- dDF$mg_prop_womendeaths * dDF$mg_dead_total
