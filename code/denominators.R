### To estimate rates, the population data are required

## Background data on the 2023 population of Gaza
# Data were obtained from the US Census Bureau 
# International Database.
# https://www.census.gov/data-tools/demo/idb/#/pop?COUNTRY_YEAR=2024&COUNTRY_YR_ANIM=2023&CCODE_SINGLE=XG&CCODE=XG&ANIM_PARAMS=2023,2024,1&menu=popViz&quickReports=CUSTOM&CUSTOM_COLS=POP,MPOP,FPOP,CDR&popPages=BYAGE&POP_YEARS=2023
# The data were downloaded as an excel file (IDB_02-26-2024.xlsx)

### Load and manage the US Census Bureau Gaza population data
popDF <- readxl::read_excel("data/IDB_02-26-2024.xlsx") %>%
  filter (Year == 2023) %>%
  select(age = GROUP, 
         pop_total = Population,
         pop_male = `Male Population`,
         pop_female = `Female Population`)

total_pop <- popDF$pop_total[popDF$age == "TOTAL"]

popDF <- popDF %>% filter(age != "TOTAL")
popDF$age[popDF$age == "100+"] <- "100"
popDF$age <- as.integer(popDF$age)

child_pop <- sum(popDF$pop_total[popDF$age < 18])
women_pop <-  sum(popDF$pop_female[popDF$age >= 18])
men_pop <-  sum(popDF$pop_male[popDF$age >= 18])

rm(popDF)
