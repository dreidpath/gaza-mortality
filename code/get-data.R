library(tidyverse)

dDF <- readxl::read_excel("data/raw_data.xlsx")

dDF$tracker_date <- dmy(dDF$tracker_date)
dDF$report_date <- dmy(dDF$report_date)

diff(dDF$g_dead_total)
x<-1
