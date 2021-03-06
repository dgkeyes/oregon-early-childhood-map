
# Packages ----------------------------------------------------------------

library(tidyverse)
library(tigris)
library(janitor)
library(sf)
library(tidycensus)
library(leaflet)
library(glue)

# Geodata -----------------------------------------------------------------

options(tigris_class = "sf",
        tigris_use_cache = TRUE)

oregon_counties <- counties(state = "Oregon",
                            cb = TRUE) %>% 
  clean_names()

oregon_census_tracts <- tracts(state = "Oregon",
                               cb = TRUE) %>% 
  clean_names()


# Schools -----------------------------------------------------------------

schools <- read_csv("data-clean/oregon-schools.csv") %>% 
  # Get rid of anything but elementary schools + others with KA scores
  drop_na(institution_name) %>% 
  # Create popup content
  mutate(popup_content = glue("<h2>{name}</h2>
                              # <p>{street_city} {county.x}</p>
                              <p>Approaches to Learning: {approaches_to_learning_total_score_score}</p>
                              <p>Math: {math_avg_number_correct_score}</p>
                              <p>Letter Sounds: {literacy_letter_sounds_number_correct_score}</p>")) %>% 
  st_as_sf(coords = c("lon", "lat"))



# School District Boundaries ----------------------------------------------



school_district_boundaries <- st_read("data-clean/school-district-boundaries.shp")



# Child Care Facilities ---------------------------------------------------

child_care_facilities <- read_csv("data-clean/child-care-facilities-geocoded.csv") %>%
  drop_na(lon, lat) %>%
  replace_na(list(facility_name = "Name not public",
                  qris_stars = "No Rating")) %>%
  mutate(qris_stars = case_when(qris_stars == "2" ~ "C2Q",
                                TRUE ~ qris_stars)) %>% 
  mutate(regulation_status = case_when(
    regulation_status == "Register" ~ "Registered",
    TRUE ~ regulation_status
  )) %>%
  mutate(popup_content = glue("<h2>{facility_name}</h2>
                              <p>{location}</p>
                              <p>Capacity: {capacity}</p>
                              <p>Spark Rating: {qris_stars}</p>")) %>% 
  mutate(facility_location = case_when(
    facility_type == "Center" ~ "Center-Based",
    TRUE ~ "Home-Based")) %>% 
  st_as_sf(coords = c("lon", "lat"))


# Early Learning Hubs -----------------------------------------------------

early_learning_hubs_locations <- read_csv("data-clean/early-learning-hubs-locations.csv")

early_learning_hubs_regions <- st_read("data-clean/early-learning-hubs-regions.shp")


# Community Attributes ----------------------------------------------------


community_attributes_race_ethnicity <- read_csv("data-clean/community-attributes.csv") %>% 
  distinct(measure) %>% 
  arrange(measure) %>% 
  filter(str_detect(measure, "Race/Ethnicity")) %>% 
  pull(measure)

community_attributes_language <- read_csv("data-clean/community-attributes.csv") %>% 
  distinct(measure) %>% 
  arrange(measure) %>% 
  filter(str_detect(measure, "Who Speak")) %>% 
  pull(measure)

community_attributes_non_race_ethnicity <- read_csv("data-clean/community-attributes.csv") %>% 
  distinct(measure) %>% 
  arrange(measure) %>% 
  filter(!str_detect(measure, "Race/Ethnicity")) %>% 
  filter(!str_detect(measure, "Who Speak")) %>% 
  pull(measure)


community_attributes <- read_csv("data-clean/community-attributes.csv") %>%
  mutate(tract_id = as.character(tract_id)) %>%
  right_join(oregon_census_tracts, by = c("tract_id" = "geoid")) %>%
  st_as_sf()

