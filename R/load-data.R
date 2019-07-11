
# Packages ----------------------------------------------------------------

library(tidyverse)
library(tigris)
library(janitor)
library(sf)


# Load Data ---------------------------------------------------------------

community_attributes_vector <- read_csv("data-clean/community-attributes.csv") %>% 
  distinct(measure) %>% 
  pull(measure)

options(tigris_class = "sf",
        tigris_use_cache = TRUE)

oregon_counties <- counties(state = "Oregon",
                            cb = TRUE) %>% 
  clean_names()

oregon_census_tracts <- tracts(state = "Oregon",
                               cb = TRUE) %>% 
  clean_names()

school_district_boundaries <- st_read("data-clean/school-district-boundaries.shp")

community_attributes <- read_csv("data-clean/community-attributes.csv") %>%
  rename("tract_id" = "geoid",
         "value" = "estimate") %>% 
  mutate(tract_id = as.character(tract_id)) %>%
  right_join(oregon_census_tracts, by = c("tract_id" = "geoid")) %>%
  st_as_sf()

# community_attributes <- st_read(community_attributes_geodata, "data-clean/community-attributes.shp")

child_care_facilities <- read_csv("data-clean/child-care-facilities-geocoded.csv") %>%
  drop_na(lon, lat) %>%
  replace_na(list(facility_name = "Name not public")) %>%
  mutate(regulation_status = case_when(
    regulation_status == "Register" ~ "Registered",
    TRUE ~ regulation_status
  )) %>%
  st_as_sf(coords = c("lon", "lat"))

