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

####################
# The code here extrapolates the number of women and children who died by observing
# The proportion of women and children who died at the last time women and children
# deaths were updated. The proportion is then multiplied by the increasing total deaths
# as an extrapolated estimate of how the women and children deaths should be increasing

# Extrapolate women's deaths
deathDF$g_dead_womenx <- deathDF$g_dead_women
last_change <- lastchange(deathDF$g_dead_womenx)
extrapolate_prop <- deathDF$g_dead_womenx[last_change]/deathDF$g_dead_total[last_change]
deathDF$g_dead_womenx[last_change:length(deathDF$g_dead_womenx)] <- floor(deathDF$g_dead_total[last_change:length(deathDF$g_dead_womenx)] * extrapolate_prop)
deathDF$g_dead_womenx_flag <- 0  # Establish a flag of which data points have been extrapolated or interpolated
deathDF$g_dead_womenx_flag[last_change:length(deathDF$g_dead_womenx)] <- 1
# Extrapolate children's deaths  
deathDF$g_dead_childx <- deathDF$g_dead_child
last_change <- lastchange(deathDF$g_dead_childx)
extrapolate_prop <- deathDF$g_dead_child[last_change]/deathDF$g_dead_total[last_change]
deathDF$g_dead_childx[last_change:length(deathDF$g_dead_childx)] <- floor(deathDF$g_dead_total[last_change:length(deathDF$g_dead_childx)] * extrapolate_prop)
deathDF$g_dead_childx_flag <- 0  # Establish a flag of which data points have been extrapolated or interpolated
deathDF$g_dead_childx_flag[last_change:length(deathDF$g_dead_childx)] <- 1

#clean up
rm(list = c("extrapolate_prop", "last_change", "lastchange"))
###################

# Model the death count for days without updates
# Calculate the deaths on each day as the difference between one day and the day before
deathDF$g_dailydead_total <- c(deathDF$g_dead_total[1], diff(deathDF$g_dead_total))
# For days with zero daily difference, model the daily deaths
deathDF$mg_dailydead_total <- model_0s(deathDF$g_dailydead_total)
# Calculate the cumulative sum of deaths
deathDF$mg_dead_total <- cumsum(deathDF$mg_dailydead_total)
# Create flags to mark which mg_dailydead_total and mg_dead_total rows are interpolated
deathDF$mg_dailydead_total_flag <- 0
deathDF$mg_dailydead_total_flag[which(deathDF$g_dailydead_total==0)] <- 1
deathDF$mg_dead_total_flag <- 0
deathDF$mg_dead_total_flag[which(deathDF$g_dailydead_total==0)] <- 1 
  
## Model the child deaths (this is an "at least figure")
# Step 1: Model the proportion of dead each day who are children
deathDF$mg_prop_childdeaths <- model_missing_proportions(deathDF$g_dead_childx, deathDF$mg_dead_total)
# Step 2: multiply the proportion by the total dead to estimate child daily deaths
deathDF$mg_dead_child <- deathDF$mg_prop_childdeaths * deathDF$mg_dead_total
# Step 3: Model daily child deaths
deathDF$mg_daily_childdeaths <- c(deathDF$mg_dead_child[1], diff(deathDF$mg_dead_child) )

## Model the women deaths (this is an "at least figure")
# Step 1: Model the proportion of dead each day who are women
deathDF$mg_prop_womendeaths <- model_missing_proportions(deathDF$g_dead_womenx, deathDF$mg_dead_total)
# Step 2: multiply the proportion by the total dead to estimate women daily deaths
deathDF$mg_dead_women <- deathDF$mg_prop_womendeaths * deathDF$mg_dead_total
# Step 3: Model daily women deaths
deathDF$mg_daily_womendeaths <- c(deathDF$mg_dead_women[1], diff(deathDF$mg_dead_women) )

# Clean up
rm(list = c("lininterpol", "model_0s", "model_missing_proportions"))

## Estimate the mortality rate

source("code/denominators.R")

deathDF$mg_mr_total <- deathDF$mg_dead_total/total_pop * 100000
deathDF$mg_mr_child = deathDF$mg_dead_child/child_pop * 100000
deathDF$mg_mr_women = deathDF$mg_dead_women/women_pop * 100000
deathDF$mg_mr_men = (deathDF$mg_dead_total - deathDF$mg_dead_child - deathDF$mg_dead_women)/men_pop * 100000

rm(list = c("child_pop", "men_pop", "total_pop", "women_pop"))


saveRDS(deathDF, file = "data/gaza_data.Rds")
haven::write_sav(deathDF, path = "data/gaza_data.sav")
