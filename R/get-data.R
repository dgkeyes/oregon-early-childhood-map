
# Packages ----------------------------------------------------------------

library(tidyverse)
library(here)
library(sf)
library(ggmap)
library(janitor)


# Child Care Facilities ---------------------------------------------------

child_care_facilities <- read_csv(here("data", "child-care-facilities.csv")) %>% 
  clean_names() %>% 
  drop_na(facility_name) %>% 
  select(-objectid) %>% 
  sample_n(100) %>% 
  mutate(location = str_glue("{address} {city}, {state} {zip_code}")) %>% 
  mutate_geocode(location) %>% 
  view()

write_csv(child_care_facilities, here("data", "child-care-facilities-geocoded.csv"))
