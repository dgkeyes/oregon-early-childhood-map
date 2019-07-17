
# Packages ----------------------------------------------------------------

library(tidyverse)
library(tigris)
library(janitor)
library(sf)
library(tidycensus)
library(leaflet)
library(glue)

# Load Data ---------------------------------------------------------------

community_attributes_vector <- read_csv("data-clean/community-attributes.csv") %>% 
  distinct(measure) %>% 
  arrange(measure) %>% 
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
  mutate(tract_id = as.character(tract_id)) %>%
  right_join(oregon_census_tracts, by = c("tract_id" = "geoid")) %>%
  # mutate(plot_label = glue("{plot_label}")) %>% 
  st_as_sf()



# community_attributes <- st_read(community_attributes_geodata, "data-clean/community-attributes.shp")



# Child Care Facilities ---------------------------------------------------



child_care_facilities <- read_csv("data-clean/child-care-facilities-geocoded.csv") %>%
  drop_na(lon, lat) %>%
  replace_na(list(facility_name = "Name not public",
                  qris_stars = "No Rating")) %>%
  mutate(regulation_status = case_when(
    regulation_status == "Register" ~ "Registered",
    TRUE ~ regulation_status
  )) %>%
  mutate(popup_content = glue("<h2>{facility_name}</h2>
                              <p>{location}</p>
                              <p>Capacity: {capacity}</p>
                              <p>Spark Rating: {qris_stars}</p>")) %>% 
  st_as_sf(coords = c("lon", "lat"))



