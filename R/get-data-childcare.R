
# Packages ----------------------------------------------------------------

library(tidyverse)
library(here)
library(sf)
library(ggmap)
library(janitor)
library(tidycensus)
library(scales)
library(tigris)
library(fs)
library(readxl)



# Geocode -----------------------------------------------------------------

# child_care_facilities <- read_csv(here("data-raw", "child-care-facilities.csv"),
#                                   na = ".") %>%
#   clean_names() %>%
#   mutate(location = str_glue("{address} {city}, {state} {zip_code}")) %>%
#   replace_na(list(facility_name = "Name not public")) %>%
#   mutate_geocode(location) %>%
#   view()
# 
# beepr::beep()
# 
# 
# write_csv(child_care_facilities, here("data-clean", "child-care-facilities-geocoded.csv"))


