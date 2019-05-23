
# Packages ----------------------------------------------------------------

library(tidyverse)
library(here)
library(sf)
library(ggmap)
library(janitor)


# Geodata -----------------------------------------------------------------

options(tigris_class = "sf")

oregon_counties <- counties(state = "Oregon",
                            cb = TRUE) %>% 
  clean_names()

st_write(oregon_counties, "data-clean/oregon-counties.shp")

oregon_census_tracts <- tracts(state = "Oregon",
                               cb = TRUE) %>% 
  clean_names()

st_write(oregon_census_tracts, "data-clean/oregon-census-tracts.shp")






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



# Schools -----------------------------------------------------------------


# Community Attributes ----------------------------------------------------


diversity_index <- read_csv("data-raw/diversity-index.csv") %>% 
  clean_names() %>% 
  mutate(tract_id = as.character(geoid10)) %>% 
  select(tract_id, county, divindx_cy) %>% 
  rename("value" = "divindx_cy") %>% 
  mutate(measure = "Diversity Index")


median_household_income <- read_csv("data-raw/median-household-income.csv") %>% 
  clean_names() %>% 
  mutate(tract_id = as.character(geoid10)) %>% 
  select(tract_id, county, w_ch18) %>% 
  rename("value" = "w_ch18") %>% 
  mutate(measure = "Median Household Income") 

community_attributes <- bind_rows(diversity_index, median_household_income) %>% 
  view()


write_csv(community_attributes, "data-clean/community-attributes.csv")


